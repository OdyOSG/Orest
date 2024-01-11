runPredictionPipeline <- function(
    tbl,
    pathToOrest,
    source_code_field = TRUE
) {
  ref <- data.table::fread(here::here('inst/csv/map.csv'))
  mappingHardcoded <- ref[tbl,  on=.(source_code), nomatch=NULL]
  tblPrep <- tbl %>%
    rename_all(tolower) %>%
    filter(!source_code %in% mappingHardcoded$source_code)
    prepareTable()
  predictions <- applyCrfModels(tblPrep, pathToOrest)
  tblPrep$pred1 <- predictions$label...1
  tblPrep$pred2 <- predictions$label...3
  tblPrep$pred3 <- predictions$label...5
  tblPrep$pred4 <- predictions$label...7
  tblPrep$pred5 <- predictions$label...9


}
