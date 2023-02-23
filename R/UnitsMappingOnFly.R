creatinineUnitsMapping <- function(
  connectionDetails,
  writeDatabaseSchema,
  gfrTmpTable,
  cdmDatabaseSchema
) {
  sql <- glue::glue(
    SqlRender::readSql(here::here('inst/sql/CollectGFRData.sql')),
    write_schema = writeDatabaseSchema,
    gfr_tmp_table = gfrTmpTable,
    cdm_schema = cdmDatabaseSchema
    )
  connection <- suppressMessages(DatabaseConnectior::connect(connectionDetails))
  on.exit(suppressMessages(DatabaseConnectior::disconnect(connection)))
  DatabaseConnector::executeSql(connection = connection, sql = sql)
  units <- tolower(unique(DatabaseConnector::querySql(
    connection = connection,
    sql = glue('select unit_source_value from {write_schema}.{gfr_tmp_table}
               where concept_code is null and unit_source_value is not null',
               write_schema = writeDatabaseSchema,
               gfr_tmp_table = gfrTmpTable),
    snakeCaseToCamelCase = TRUE
    ))[, 'unitSourceValue'])


  # UPDATE Table_Name SET Column_Name = New_Value WHERE Condition;



}




convertCreatinineUnits <- function (creatinine, creatinine_units) {
    creatinine <- ifelse (  creatinine_units == "mg/dl",
                            creatinine, # do nothing
                            ifelse(  creatinine_units == "micromol/l",
                                     creatinine / 88.4,
                                     ifelse(  creatinine_units == "mmol/l",
                                              1000 * creatinine / 88.4,
                                              NA # if any other undefined units is used, assume NA
                                     )
                            )
    )
  return (creatinine)
}
