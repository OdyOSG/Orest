#
#
# cdm <- CDMConnector::cdm_from_con(con, cdm_schema = cdmDatabaseSchema, write_schema = writeDatabaseSchema)
#
# creatinineMeasurementsToBeMapped <- cdm$measurement %>%
#   dplyr::filter(measurement_concept_id %in% c(conceptIdsCreatinine) &
#                   unit_concept_id == 0)
# creatinineMeasurementsMapped <- cdm$measurement %>%
#   dplyr::filter(measurement_concept_id %in% c(conceptIdsCreatinine) &
#                   unit_concept_id != 0)
# unitConceptIds <- cdm$measurement %>%
#   dplyr::filter(measurement_concept_id %in% c(conceptIdsCreatinine) &
#                   unit_concept_id != 0) %>% dplyr::pull(unit_concept_id) %>%
#   unique()
#
#
# mp_dt1 <- purrr::map_dfr(
#   cdm$measurement %>%
#     dplyr::filter(measurement_concept_id %in% c(conceptIdsCreatinine) &
#                     unit_concept_id == 0 & !(is.na(unit_source_value)|
#                                                is.null(unit_source_value))
#     ) %>% dplyr::pull(unit_source_value) %>% unique(),
#   ~data.table(getMp())[source_code == .x,]
# )[concept_id %in% unitConceptIds, ]
# checkValidity <- DatabaseConnector::renderTranslateQuerySql(
#   connction,
#   "select concept_id from @cdm_schema.concept where concept_id in (@concept_ids)
#      and standard_concept = 'S'",
#   concept_ids = mp_dt1$concept_id,
#   cdm_schema = cdmSchema
# )[ ,1]
#
#
#
#
#
#
#
# call <- rlang::call2(ifelse(connectionDetails$dbms == 'postgresql', 'Postgres', 'Redshift'), .ns = 'RPostgres')
# dbname <- strsplit(connectionDetails$server(), '/')[[1]][[2]]
# host <- strsplit(connectionDetails$server(), '/')[[1]][[1]]
# con <- DBI::dbConnect(
#   eval(call),
#   dbname = dbname,
#   host = host,
#   user = connectionDetails$user(),
#   password = connectionDetails$password(),
#   port = connectionDetails$port()
# )
#
# cn <- cdm$concept %>% dplyr::filter(vocabulary_id == 'HemOnc')
# cr <- cdm$concept_relationship %>% dplyr::filter(
#   relationship_id %in% c(
#     'Has cytotoxic chemo', 'Has immunosuppressor', 'Has local therapy',
#     'Has radioconjugate', 'Has pept-drug cjgt', 'Has supportive med' ,
#     'Has targeted therapy'))
# fin <- cn %>% dplyr::inner_join(
#   cr, by = c('concept_id'= 'concept_id_2')) %>%
#   dplyr::select(concept_name, concept_id, concept_id_1) %>%
#   dplyr::inner_join(cn %>% dplyr::inner_join(cr, by = c('concept_id' = 'concept_id_1')) %>%
#                       dplyr::select(concept_id, concept_name), by = c('concept_id_1' = 'concept_id')) %>%
#   dplyr::mutate(ingredients = tolower(concept_name.x)) %>%
#   dplyr::select(ingredients, regimen = concept_name.y, concept_id, tmp_c = concept_id_1) %>%
#   dplyr::distinct() %>%
#   as.data.frame() %>%
#   dplyr::group_by(regimen) %>%
#   dplyr::reframe(concept_id = tmp_c, reg_name = regimen, combo_name = sort(paste(ingredients, collapse = ','))) %>%
#   dplyr::ungroup() %>%
#   dplyr::group_by(combo_name) %>%
#   dplyr::filter(row_number(combo_name) == 1) %>%
#   dplyr::ungroup() %>% dplyr::collect() %>% dplyr::select(-regimen)
# return(fin)
