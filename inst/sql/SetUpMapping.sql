CREATE TABLE @write_schema.@measurement_tmp_tbl (
  measurement_id integer NOT NULL,
			person_id integer NOT NULL,
			measurement_concept_id integer NOT NULL,
			measurement_date date NOT NULL,
			measurement_datetime TIMESTAMP NULL,
			measurement_time varchar(10) NULL,
			measurement_type_concept_id integer NOT NULL,
			operator_concept_id integer NULL,
			value_as_number NUMERIC NULL,
			value_as_concept_id integer NULL,
			unit_concept_id integer NULL,
			range_low NUMERIC NULL,
			range_high NUMERIC NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			measurement_source_value varchar(50) NULL,
			measurement_source_concept_id integer NULL,
			unit_source_value varchar(50) NULL,
			value_source_value varchar(50) NULL)
    );
  INSERT INTO   @write_schema.@measurement_tmp_tbl (
      person_id,
			measurement_concept_id,
			measurement_date date,
			measurement_datetime ,
			measurement_time ,
			measurement_type_concept_id ,
			operator_concept_id ,
			value_as_number ,
			value_as_concept_id  ,
			unit_concept_id  ,
			range_low  ,
			range_high  ,
			provider_id  ,
			visit_occurrence_id  ,
			visit_detail_id  ,
			measurement_source_value  ,
			measurement_source_concept_id  ,
			unit_source_value,
			value_source_value
			)
  SELECT
      m.person_id,
			m.measurement_concept_id,
			m.measurement_date date,
			m.measurement_datetime ,
			m.measurement_time ,
			m.measurement_type_concept_id ,
			m.operator_concept_id ,
			m.value_as_number ,
			m.value_as_concept_id  ,
			u.unit_concept_id  ,
			m.range_low  ,
			m.range_high  ,
			m.provider_id  ,
			m.visit_occurrence_id  ,
			m.visit_detail_id  ,
			m.measurement_source_value  ,
			m.measurement_source_concept_id  ,
			m.unit_source_value,
			m.value_source_value
  FROM @cdm_schema.measurement m
  WHERE measurement_concept_id
  IN (@target_measurement_concept_ids) AND
  value_as_number IS NOT NULL AND
  unit_source_value IS NOT NULL --AND unit_concept_id = 0
