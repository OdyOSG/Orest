#' @export
#' @title placeTmpMeasurementMappedTable
#' @description This function will create a table with measurements that did not have a unit of measurement and will map source value using the Odysseus Data Services mapping date
#' @param measurementName optional parameter prefix name of tmp measurement talbe
#' @param connectionDetails DatabaseConnector::createConnectionDetails S3 object
#' @param cdmSchema cdm database schema
#' @param writeSchema schema to write
#' @param targetMeasurementConceptIds measurement concept ids to map
#'
#'
placeTmpMeasurementMappedTable <- function(
    measurementName = 'any',
    connectionDetails,
    cdmSchema,
    writeSchema,
    targetMeasurementConceptIds
) {
  separator <- paste(rep('*', 20), collapse = "<*>")
  connection <- suppressMessages(DatabaseConnector::connect(connectionDetails))
  on.exit(DatabaseConnector::disconnect(connection))
  tableName <- 'tmp_units_mapping'
  ParallelLogger::logInfo(
  glue::glue('{separator}
  Collect all potential concept ids for measurement
  {separator}'))
  unitConceptIds <- DatabaseConnector::renderTranslateQuerySql(
    connection = connection,
    sql = "SELECT distinct unit_concept_id FROM @cdm_schema.measurement
          WHERE measurement_concept_id IN (@target_measurement_concept_ids)
          AND measurement_concept_id != 0",
    target_measurement_concept_ids = targetMeasurementConceptIds,
    cdm_schema = cdmSchema
  )[, 1]
  listOfSources <- DatabaseConnector::renderTranslateQuerySql(
    connection = connection,
    sql = "SELECT distinct unit_source_value FROM @cdm_schema.measurement
          WHERE measurement_concept_id IN (@target_measurement_concept_ids)
          AND measurement_concept_id = 0 and value_as_number IS NOT NULL",
    target_measurement_concept_ids = targetMeasurementConceptIds,
    cdm_schema = cdmSchema
  )[, 1]
  preparedMap <- prepareMap(
    listOfSources = listOfSources,
    connection = connection,
    cdmSchema = cdmSchema,
    unitConceptIds = unitConceptIds
    )
  ParallelLogger::logInfo(glue::glue('{separator}
  Place unmapped measurement table part)
  {separator}'))
  DatabaseConnector::renderTranslateExecuteSql(
    connection = connection,
    sql = SqlRender::readSql(here::here('inst/sql/SetUpMapping.sql')),
    write_schema = writeSchema,
    measurement_tmp_tbl = paste0(measurementName , '_measurement_tmp_tbl')
  )
  ParallelLogger::logInfo(glue::glue('
  {separator}
  Map unmapped units
  {separator}'))
  purrr::walk(
    unique(preparedMap$source_code), function(.x) {
      cId <-
        data.table::data.table(preparedMap)[source_code == .x, ][['concept_id']]
      DatabaseConnector::renderTranslateExecuteSql(connection,
      'UPDATE @write_schema.@measurement_tmp_tbl
      SET unit_concept_id = @concept_id
      WHERE unit_source_value = @src',
      concept_id = cId,
      measurement_tmp_tbl = paste0(measurementName , '_measurement_tmp_tbl'),
      src = .x
      )})
}

#' @importFrom data.table data.table
#' @importFrom data.table :=
#' @importFrom arrow to_duckdb
#' @importFrom rlang !!
prepareMap <- function(
    listOfSources,
    connection,
    cdmSchema,
    unitConceptIds
) {
  mp_dt1 <- purrr::map_dfr(
    listOfSources,
    ~data.table(getMp())[source_code == .x,]
  )[concept_id %in% unitConceptIds, ]
  checkValidity <- DatabaseConnector::renderTranslateQuerySql(
    connction,
    "select concept_id from @cdm_schema.concept where concept_id in (@concept_ids)
     and standard_concept = 'S'",
    concept_ids = mp_dt1$concept_id,
    cdm_schema = cdmSchema
  )[ ,1]
  return(mp_dt1[concept_id %in% checkValidity, ])
}
