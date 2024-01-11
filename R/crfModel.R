#' @importFrom data.table shift
#' @import crfsuite
#' @import stringr
#' @import dplyr
#' @importFrom data.table :=
#' @importFrom tidytext unnest_tokens
#' @export
prepareTable <- function(tbl) {
  prepTbl <- tbl %>%
    distinct() %>%
    mutate(
      doc_id = row_number()
    ) %>%
    unnest_tokens(., token, "source_code", strip_punct = FALSE, to_lower = FALSE) %>%
    mutate(
      pos = case_when(
        str_detect(token, "\\d") ~ "digits",
        str_detect(token, "[A-Za-z]") ~ "abbr",
        .default = "other"
      ),
      upperLower = ifelse(grepl("[[:upper:]]", token), "upper", "nonupper")
    )
  x <- data.table::as.data.table(prepTbl)
  tbl <- x[,
    pos_previous := shift(pos, n = 1, type = "lag"),
    by = list(doc_id)
  ][,
    pos_next := shift(pos, n = 1, type = "lead"),
    by = list(doc_id)
  ][,
    token_previous := shift(token, n = 1, type = "lag"),
    by = list(doc_id)
  ][,
    token_next := shift(token, n = 1, type = "lead"),
    by = list(doc_id)
  ][,
    pos_previous := txt_sprintf("pos[w-1]=%s", pos_previous),
    by = list(doc_id)
  ][,
    pos_next := txt_sprintf("pos[w+1]=%s", pos_next),
    by = list(doc_id)
  ][,
    token_previous := txt_sprintf("token[w-1]=%s", token_previous),
    by = list(doc_id)
  ][,
    token_next := txt_sprintf("token[w-1]=%s", token_next),
    by = list(doc_id)
  ]
  return(data.frame(x))
}


#' @export
applyCrfModels <- function(preparedTable, pathToOrest) {
  models <- list.files(here::here(pathToOrest, 'inst/models'), full.names = TRUE)
  pred <- purrr::map_dfc(
    models, ~predict(readRDS(.x),
                      newdata = preparedTable[,
                                              c(
                                                "pos",
                                                "pos_previous",
                                                "pos_next",
                                                "token",
                                                "token_previous",
                                                "token_next",
                                                'upperLower')
                      ],
                      group = preparedTable$doc_id)
  )
  return(pred)
}


