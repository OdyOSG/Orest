
#' @export
#' @param sqlCohortString sql cohort where there is value_as_number measurement criteia
#' @param orestTmpSchema schema to put Orest temp measurement table
#' @param orestTmpMeasurementTable measurement Orest temp table
#' Prepare sql and concept ids to use Orest measurement temp table
#' @description
#' getCohortDetailsOrest() prepares new sql cohort and concept ids from Atlas or Capr sql
#' @title Get Orest Cohort Details  (sql with replaces measurement info, concept ids)
#'
getCohortDetailsOrest <- function(
  sqlCohortString,
  orestTmpSchema,
  orestTmpMeasurementTable
) {
  newCohortSql <- stringr::str_replace(
    sql,
    '@cdm_database_schema.MEASUREMENT',
    glue::glue('@{orestTmpSchema}.@{orestTmpMeasurementTable}')
    )
  conceptIds <- suppressWarnings(
    as.numeric(
      gsub("([0-9]+).*$", "\\1", unlist(strsplit(newCohortSql, ',')))
      )
    )
  return(
    list(
      newCohortSql = newCohortSql,
      conceptIds = conceptIds[which(!is.na(conceptIds)  & conceptIds  > 1000)]
    )
  )
}
