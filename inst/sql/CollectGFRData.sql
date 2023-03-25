DROP TABLE {write_schema}.{gfr_tmp_table} IF EXISTS;
CREATE {write_schema}.{gfr_tmp_table}(
  person_id bigint,
  gender varchar(1),
  ethnicity varchar(8),
  age int,
  measurement_id bigint,
  value_as_number float,
  concept_code varchar(50),
  unit_source_value varchar(50)
);
INSERT INTO {write_schema}.{gfr_tmp_table} (person_id, gender, ethnicity, age, measurement_id, value_as_number, concept_code, unit_source_value)
SELECT person_id, gender, ethnicity, year_of_birth  - measurement_date as age, measurement_id, value_as_number, concept_code, unit_source_value
FROM  (
  SELECT person_id, CASE WHEN gender_concept_id = 8507 THEN 'm'
         WHEN gender_concept_id = 8532 THEN 'f'
         ELSE 'no_gender' END AS gender,
         CASE WHEN race_concept_id IN (38003600, 38003599, 38003598, 8516) THEN 'black'
         ELSE 'no_black' END AS ethnicity,
         year_of_birth
  FROM @cdm_schema.person
  where gender_concept_id IS NOT NULL AND year_of_birth IS NOT NULL AND race_concept_id IS NOT NULL
) cte
JOIN (
  SELECT measurement_id, measurement_date, person_id, value_as_number, concept_code, unit_source_value,
  unit_concept_id
  FROM @cdm_schema.measurement m
  LEFT JOIN @cdm_schema.concept c ON m.unit_concept_id = c.concept_id
  WHERE unit_source_value IS NOT NULL AND value_as_number > 0 AND value_as_number IS NOT NULL
  AND measurement_concept_id IN (@creatinine_concept_ids)
  ) cte2 ON cte.person_id = cte2.person_id
  WHERE year_of_birth  - measurement_date > 17;

SELECT CASE WHEN
--8861 mg/ml
 gender = 'f' and ethnicity = 'not_black' and unit_concept_id = 8861 THEN
  POWER(value_as_number * 88.4, -1.154) * POWER(age,-0.203) * 0.742
  WHEN  gender = 'm' and ethnicity = 'not_black' and unit_concept_id = 8861  THEN
  POWER(value_as_number * 88.4, -1.154) * POWER(age, -0.203)
  WHEN  gender = 'f' and ethnicity = 'black' and unit_concept_id = 8861  THEN
  POWER(value_as_number * 88.4, -1.154) * POWER(age, -0.203) * 0.742 * 1.212
  WHEN  gender = 'm' and ethnicity = 'black' and unit_concept_id = 8861 THEN
  POWER(value_as_number * 88.4, -1.154) * POWER(age,-0.203) * 1.212
  --8753 - mmol/l
gender = 'f' and ethnicity = 'not_black' and unit_concept_id = 8753 THEN
  POWER(value_as_number, -1.154) * POWER(age,-0.203) * 0.742
  WHEN  gender = 'm' and ethnicity = 'not_black' and unit_concept_id = 8753  THEN
  POWER(value_as_number, -1.154) * POWER(age, -0.203)
  WHEN  gender = 'f' and ethnicity = 'black' and unit_concept_id = 8753  THEN
  POWER(value_as_number, -1.154) * POWER(age, -0.203) * 0.742 * 1.212
  WHEN  gender = 'm' and ethnicity = 'black' and unit_concept_id = 8753 THEN
  POWER(value_as_number, -1.154) * POWER(age,-0.203) * 1.212

--8749 umol/l
gender = 'f' and ethnicity = 'not_black' and unit_concept_id = 8753 THEN
  POWER(value_as_number * 1000, -1.154) * POWER(age,-0.203) * 0.742
  WHEN  gender = 'm' and ethnicity = 'not_black' and unit_concept_id = 8753  THEN
  POWER(value_as_number * 1000, -1.154) * POWER(age, -0.203)
  WHEN  gender = 'f' and ethnicity = 'black' and unit_concept_id = 8753  THEN
  POWER(value_as_number * 1000, -1.154) * POWER(age, -0.203) * 0.742 * 1.212
  WHEN  gender = 'm' and ethnicity = 'black' and unit_concept_id = 8753 THEN
  POWER(value_as_number * 1000, -1.154) * POWER(age,-0.203) * 1.212


  END as gfr_value, measurement_date, person_id
  FROM {write_schema}.{gfr_tmp_table} ;

DROP {write_schema}.{gfr_tmp_table};
/*
  eGFR <- ifelse( gender %in% genderFemale,
                  ifelse( creatinine <= 0.7,
                          ( (creatinine / 0.7)^(-0.329) ) * (0.993^age),
                          ( (creatinine / 0.7)^(-1.209) ) * (0.993^age)
                  ),
                  ifelse( gender %in% genderMale,
                          ifelse( creatinine <= 0.9,
                                  ( (creatinine / 0.9)^(-0.411) ) * (0.993^age),
                                  ( (creatinine / 0.9)^(-1.209) ) * (0.993^age)
                          ),
                          NA)
  )
  eGFR <- ifelse( rase %in% black,
                  ifelse( gender %in% genderFemale,
                          eGFR * 166,
                          ifelse( gender %in% genderMale,
                                  eGFR * 163,
                                  NA
                          )
                  ),
                  ifelse( gender %in% genderFemale,
                          eGFR * 144,
                          ifelse( gender %in% genderMale,
                                  eGFR * 141,
                                  NA)
                  )
  )

  return (round(eGFR, 2))

                )*/
