#' @export
#' @param tbl data.frame with units source_code column
#' @param pathToOrest string absolute path to Orest package
#' @return data.frame with 2 columns: source_code, concept_name
#' @title runMappingPipeline
#' @description Function obtain tbl with source_code and provide 2 steps mapping

runMappingPipeline <- function(
    tbl,
    pathToOrest,
    source_code_field = TRUE
) {
  if(!source_code_field) names(tbl) <- 'source_code'

  ref <- data.table::fread(here::here('inst/csv/map.csv'))
  mappingHardcoded <- ref[tbl,  on=.(source_code), nomatch=NULL] %>% as.data.frame() %>%
    select("source_code",         "concept_name")
  tblPrep <- tbl %>%
    rename_all(tolower) %>%
    filter(!source_code %in% mappingHardcoded$source_code)
  if(nrow(tblPrep) > 0) {
    tblPrep <-  Orest::prepareTable(tblPrep)
    predictions <- Orest::applyCrfModels(tblPrep, pathToOrest)
    tblPrep$pred1 <- predictions$label...1
    tblPrep$pred2 <- predictions$label...3
    tblPrep$pred3 <- predictions$label...5
    tblPrep$pred4 <- predictions$label...7
    tblPrep$pred5 <- predictions$label...9
    tblPrep2 <- tblPrep %>% reframe(
      source_code = paste0(token, collapse =''),
      doc_id,
      .by = doc_id
    ) %>% distinct()
    exportTbl <- tblPrep2 %>%
      inner_join(tblPrep, by = join_by(doc_id)) %>%
      filter(pred1 != 'other') %>%
      select(source_code, pred1, doc_id) %>%
      unique() %>% select(source_code, concept_name = pred1)
  }
  return(rbind(mappingHardcoded, exportTbl))

}
