

select patient_visit_id,
	   visit_type_rcd,
	   visit_code,
	   patient_id,
	   hospital_code,
	   visible_patient_id,
	   visit_type_name_l,
	   creation_date_time,
	   actual_visit_date_time,
	   closure_date_time,
	   expected_discharge_date_time,
	   expected_length_of_stay,
	   cancelled_date_time,
	   comment,
	   guarantor_person_id,
	   guarantor_person_name_l,
	   created_by,
	   user_name,
	   visit_source_rcd,
	   visit_source_name_l,
	   primary_service_rcd,
	   primary_service_name_l,
	   ambulatory_status_rcd,
	   ambulatory_status_name_l,
	   charge_type_rcd,
	   charge_type_name_l,
	   last_status_comment,
	   last_status_created_by_employee_id,
	   last_status_created_date_time,
	   last_status_change_rcd,
	   last_status_rcd,
	   last_status_name_l,
	   last_status_change_name_l,
	   discharge_date_time,
	   last_coding_status_rcd,
	   last_coding_status_name_l,
	   last_coding_status_diagnosis_type_rcd,
	   last_coding_status_diagnosis_type_name_l,
	   last_coding_status_employee_id,
	   last_coding_status_employee_nr,
	   last_coding_status_date_time,
	   admission_patient_visit_location_id,
	   admission_area_id,
	   admission_area_name_l,
	   admission_area_code,
	   admission_bed_schedule_entry_id,
	   admission_bed_id,
	   admission_bed_code,
	   admission_room_charge_set_id,
	   admission_room_charge_set_name_l

FROM api_patient_visit_view
where year(actual_visit_date_time) = 2018
      --and month(actual_visit_date_time) = 1
      and closure_date_time is NOT null
	  and cancelled_date_time is null
	  and visit_type_rcd in ('V1', 'V2')
	  and discharge_status_rcd = 'COM'
	  --and last_status_rcd is NULL

order by actual_visit_date_time




