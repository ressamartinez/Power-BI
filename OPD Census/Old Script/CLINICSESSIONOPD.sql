DECLARE @visit_type_group_rcd varchar(5) = 'OPD'
DECLARE @visit_start_date_from datetime = '2019-01-01'
DECLARE @visit_start_date_until datetime = '2019-01-31 23:59:59.999'
DECLARE @hosptal_code varchar(50) = 'AHI'
DECLARE @other_language_rcd varchar(50) = 'EN'
DECLARE @local_language_rcd varchar(50) = 'EN'

DECLARE @table AS TABLE(patient_visit_id guid PRIMARY KEY, patient_triage_history_id guid)

INSERT          @table (patient_visit_id, patient_triage_history_id)
SELECT          pv.patient_visit_id
                , pth.patient_triage_history_id
FROM            patient_visit_nl_view AS pv
INNER JOIN      visit_type_ref_nl_view vtr ON vtr.visit_type_rcd = pv.visit_type_rcd
OUTER APPLY     (
                SELECT TOP 1    pth.patient_triage_history_id
                                , pth.patient_visit_id
                FROM            patient_triage_history_nl_view AS pth
                WHERE           pth.patient_visit_id = pv.patient_visit_id
                AND             pth.verified_flag = 1
                AND             pth.deleted_date_time IS NULL
                ORDER BY        pth.triage_date_time DESC
                ) AS pth
WHERE           pv.actual_visit_date_time BETWEEN @visit_start_date_from AND @visit_start_date_until
AND             vtr.visit_type_group_rcd = @visit_type_group_rcd
AND             pv.cancelled_date_time IS NULL

SELECT          
-- patient
                apv.person_indicator_name_e_list
                , apv.person_indicator_name_l_list
                , apv.visible_patient_id
                , pfn.list_name_e AS patient_name_e
                , pfn.list_name_l AS patient_name_l
                , apv.date_of_birth
                , apv.death_date_time
                , dbo.radt_VisiblePatientAge(apv.date_of_birth, ISNULL(apv.death_date_time, GETDATE()), @other_language_rcd) AS patient_age_e
                , dbo.radt_VisiblePatientAge(apv.date_of_birth, ISNULL(apv.death_date_time, GETDATE()), @local_language_rcd) AS patient_age_l
                , apv.nationality_name_e
                , apv.nationality_name_l
                , apv.ethnic_group_name_e_list
                , apv.ethnic_group_name_l_list
                , apv.religion_name_e
                , apv.religion_name_l
                , apv.sex_name_e
                , apv.sex_name_l
                , pv.patient_visit_id
                , pv.actual_visit_date_time
                , DATEDIFF(day, pv.actual_visit_date_time, GETDATE()) AS length_of_stay
                , apv.residence_country_name_e
                , apv.residence_country_name_l
                , al.address_e AS home_address_e
                , al.address_l AS home_address_l
                , apv.home_phone_number
                , patv.primary_related_patient_confirmation_status_rcd AS patient_link_status_rcd
                , patv.display_patient_id AS patient_id

-- policy
                , dbo.radt_PatientVisitPolicyDisplayInfo(pv.patient_visit_id, 0, DEFAULT, DEFAULT) AS visit_policies_name_e
                , dbo.radt_PatientVisitPolicyDisplayInfo(pv.patient_visit_id, 1, DEFAULT, DEFAULT) AS visit_policies_name_l

-- visit package
                , dbo.radt_GetVisitPackages(pv.patient_visit_id, 0) AS package_list

-- triage
                , pth.patient_visit_id
                , pth.patient_triage_history_id
                , amr.name_e AS arrival_mode_name_e
                , amr.name_l AS arrival_mode_name_l
                , tctr.name_e AS triage_category_name_e
                , tctr.name_l AS triage_category_name_l
                , pfni.list_name_e AS triage_nurse_name_e
                , pfni.list_name_l AS triage_nurse_name_l
                , pth.triage_date_time AS triage_date_time
                , pfni2.list_name_e AS updated_by_name_e
                , pfni2.list_name_l AS updated_by_name_l
                , pth.lu_updated AS last_updated
                , pth.patient_clinical_observation_id
                , pth.retriage_flag
                , rrr.name_e AS retriage_reason_name_e
                , rrr.name_l AS retriage_reason_name_l
                , pth.comment AS retriage_comment

-- clinic session
                , CASE WHEN pmc.coding_system_rcd IS NULL THEN pmc.coding_other
                     ELSE COALESCE(ced.description, ced_local.description) END AS diagnosis_name_e
                , CASE WHEN pmc.coding_system_rcd IS NULL THEN pmc.coding_other
                       ELSE COALESCE(ced_local.description, ced.description) END AS diagnosis_name_l
                , pmc.comment AS diagnosis_comment
                , pmc.primary_flag AS primary_diagnosis_flag
                , pmc.recorded_at_date_time
                , pmc.coding_employee_id
                , doc.list_name_e AS diagnosed_by_name_e
                , doc.list_name_l AS diagnosed_by_name_l
                , pvmc.patient_visit_id
                , pv.patient_visit_id
                , pwqe.patient_work_queue_entry_id
               
FROM            patient_visit_nl_view pv
INNER JOIN      visit_type_ref_nl_view vtr ON vtr.visit_type_rcd = pv.visit_type_rcd

-- patient
INNER JOIN      primary_patient_view AS patv ON patv.transaction_patient_id = pv.patient_id
AND             patv.hospital_code = @hosptal_code
INNER JOIN      person_formatted_name_iview_nl_view AS pfn ON pfn.person_id = patv.display_patient_id
INNER JOIN      api_patient_view apv ON apv.patient_id = pv.patient_id
LEFT JOIN       address_label_view AS al ON al.address_id = apv.home_address_id

-- triage
LEFT JOIN      @table AS pth_temp ON pth_temp.patient_visit_id = pv.patient_visit_id
LEFT JOIN      patient_triage_history_nl_view AS pth ON  pth.patient_triage_history_id = pth_temp.patient_triage_history_id 
LEFT JOIN      arrival_mode_ref_nl_view AS amr on pv.arrival_mode_rcd = amr.arrival_mode_rcd
LEFT JOIN      triage_category_type_ref_nl_view AS tctr on pth.triage_category_type_rcd = tctr.triage_category_type_rcd
LEFT JOIN      person_formatted_name_iview_nl_view AS pfni on pth.triage_nurse_id = pfni.person_id
LEFT JOIN      user_account_nl_view ua ON ua.user_id = pth.lu_user_id
LEFT JOIN      person_formatted_name_iview_nl_view AS pfni2 on pfni2.person_id = ua.person_id
LEFT JOIN       retriage_reason_ref_nl_view AS rrr on pth.retriage_reason_rcd = rrr.retriage_reason_rcd

-- clinic session
LEFT JOIN  patient_visit_medical_coding_nl_view AS pvmc ON pvmc.patient_visit_id = pv.patient_visit_id
LEFT JOIN  patient_medical_coding_nl_view AS pmc ON pmc.patient_medical_coding_id = pvmc.patient_medical_coding_id
            AND pmc.coding_type_rcd = 'PRI'            
            AND pmc.patient_medical_coding_type_rcd = 'VISIT'
            AND pmc.primary_flag = 1
            AND pmc.active_flag = 1
LEFT JOIN   coding_system_element_description_nl_view AS ced ON ced.coding_system_rcd = pmc.coding_system_rcd
            AND ced.code = pmc.code
            AND ced.language_rcd = @other_language_rcd
LEFT JOIN   coding_system_element_description_nl_view AS ced_local ON ced_local.coding_system_rcd = pmc.coding_system_rcd
            AND ced_local.code = pmc.code
            AND ced_local.language_rcd = @local_language_rcd
LEFT JOIN   person_formatted_name_iview_nl_view AS doc ON doc.person_id = pmc.coding_employee_id
LEFT JOIN   patient_work_queue_entry_nl_view AS pwqe ON pwqe.patient_visit_id = pvmc.patient_visit_id
            AND pwqe.employee_id = pmc.coding_employee_id
            AND pwqe.patient_wq_status_rcd <> 'CAN'
            
WHERE       pv.actual_visit_date_time BETWEEN @visit_start_date_from AND @visit_start_date_until
AND         vtr.visit_type_group_rcd = @visit_type_group_rcd
AND         pv.cancelled_date_time IS NULL
AND         ((vtr.patient_queue_supported_flag = 1 AND pwqe.patient_work_queue_entry_id IS NOT NULL)
            OR vtr.patient_queue_supported_flag = 0)
