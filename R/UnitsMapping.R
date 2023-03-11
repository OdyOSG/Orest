#' @export
#'
#'
placeTmpMeasurementMappedTable <- function(
    connectionDetails,
    cdmSchema,
    writeSchema,
    targetMeasurementConceptIds
  ) {
    connection <- suppressMessages(DatabaseConnector::connect(connectionDetails))
    on.exit(DatabaseConnector::disconnect(connection))
    tableName <- 'tmp_units_mapping'
    ParallelLogger::logInfo('Collect all potential concept ids for measurement')
    unit_concept_ids <- DatabaseConnector::renderTranslateQuerySql(
      connection = connection,
      sql = "SELECT distinct unit_concept_id FROM @cdm_schema.measurement
          WHERE measurement_concept_id IN (@target_measurement_concept_ids)
          AND measurement_concept_id != 0",
      target_measurement_concept_ids = targetMeasurementConceptIds,
      cdm_schema = cdmSchema
    )[, 1]
    readRDS(here::here('R/units_mapped.Rd')) %>%
      dplyr::filter(concept_id %in% unit_concept_ids) %>%
      DatabaseConnector::insertTable(
        connection = connection,
        databaseSchema = write_schema,
        tableName = tableName,
        data = .
      )
    ParallelLogger::logInfo('Map unmapped units')
    DatabaseConnector::renderTranslateExecuteSql(
      connection = connection,
      sql = SqlRender::readSql(here::here('inst/sql/SetUpMapping.sql')),
      write_schema = write_schema,
      measurement_tmp_tbl = 'measurement_tmp_tbl',
      units_mapping = tableName
    )
  }
