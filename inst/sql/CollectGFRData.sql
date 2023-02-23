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
  SELECT measurement_id, measurement_date, person_id, value_as_number, concept_code, unit_source_value
  FROM @cdm_schema.measurement m LEFT JOIN @cdm_schema.concept c ON m.unit_concept_id = c.concept_id
  WHERE unit_source_value IS NOT NULL AND value_as_number > 0 AND value_as_number IS NOT NULL
  AND measurement_concept_id IN (@creatinine_concept_ids)
  ) cte2 ON cte.person_id = cte2.person_id
  WHERE year_of_birth  - measurement_date > 17;

/*
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
*/

SELECT CASE WHEN
 gender = 'f' and ethnicity = 'not_black' THEN
  POWER(value_as_number, -1.154) * POWER(age,-0.203) * 0.742
  WHEN  gender = 'm' and ethnicity = 'not_black' THEN
  POWER(value_as_number, -1.154) * POWER(age, -0.203)
  WHEN  gender = 'f' and ethnicity = 'black' THEN
  POWER(value_as_number, -1.154) * POWER(age, -0.203) * 0.742 * 1.212
  WHEN  gender = 'm' and ethnicity = 'black' THEN
  POWER(value_as_number, -1.154) * POWER(age,-0.203) * 1.212


