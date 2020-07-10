DECLARE @date1 DATETIME
DECLARE @date2 DATETIME

SET @date1 = '01/01/2018 00:00:00.000'
SET @date2 = SSIS.dbo.fn_TwoHRDateTo()

select 
       tempb.patient_id
	   ,tempb.patient_visit_id
	   ,tempb.facility_code
	   ,tempb.[Visit Start]
	   ,tempb.[Closure Date]
	   ,tempb.cancelled_date_time
	   ,tempb.visit_type_rcd
	   ,tempb.[Visit Type Name]
	   ,tempb.[Visit No.]
	   ,tempb.[Priority Group]
	   ,tempb.[Visit Reason]
	   ,tempb.[Created By]
	   ,tempb.[Visit Policies]
	   ,tempb.policy_id
	   ,tempb.policy_code
	   ,tempb.HN
	   ,tempb.[Patient Name]
	   ,tempb.Region
	   ,tempb.Subregion
	   ,tempb.City
	   ,tempb.[Address Type]
	   ,case when tempb.Age is null then (cast(cast((DATEDIFF(dd,tempb.[Date of Birth],tempb.[Visit Start]) / 365.25) as int) as varchar)) else tempb.Age end as Age   
	   ,tempb.[Date of Birth]
	   ,tempb.nationality_rcd
	   ,tempb.Nationality
	   ,tempb.Race
	   ,tempb.ethnic_group_rcd_list
	   ,tempb.[Ethnic Group]
	   ,tempb.religion_rcd
	   ,tempb.Religion
	   ,tempb.sex_rcd
	   ,tempb.Sex
	   ,tempb.home_address_country_rcd
	   ,tempb.[Home Country]
	   ,tempb.residence_country_rcd
	   ,tempb.[Country of Residence]
	   ,tempb.[Home Address]
	   ,tempb.primary_service_rcd
	   ,tempb.[Primary Service]
	   ,tempb.Packages
	   ,tempb.diagnosis_type_rcd
	   ,tempb.code
	   ,tempb.Diagnosis

from (

	select temp.patient_id
		   ,temp.patient_visit_id
		   ,temp.facility_code
		   ,temp.[Visit Start]
		   ,temp.[Closure Date]
		   ,temp.cancelled_date_time
		   ,temp.visit_type_rcd
		   ,temp.[Visit Type Name]
		   ,temp.[Visit No.]
		   ,temp.[Priority Group]
		   ,temp.[Visit Reason]
		   ,temp.patient_work_queue_entry_id
		   ,temp.work_queue_type
		   ,temp.[Created By]
		   ,temp.[Visit Policies]
		   ,temp.policy_id
		   ,temp.policy_code
		   ,temp.HN
		   ,temp.[Patient Name]
		   ,temp.Region
		   ,temp.Subregion
		   ,temp.City
		   ,temp.[Address Type]
		   ,temp.Age
		   ,temp.[Date of Birth]
		   ,temp.nationality_rcd
		   ,temp.Nationality
		   ,temp.Race
		   ,temp.ethnic_group_rcd_list
		   ,temp.[Ethnic Group]
		   ,temp.religion_rcd
		   ,temp.Religion
		   ,temp.sex_rcd
		   ,temp.Sex
		   ,temp.home_address_country_rcd
		   ,temp.[Home Country]
		   ,temp.residence_country_rcd
		   ,temp.[Country of Residence]
		   ,temp.[Home Address]
		   ,temp.primary_service_rcd
		   ,temp.[Primary Service]
		   ,temp.Packages
		   ,pvdv.diagnosis_type_rcd
		   ,pvdv.coding_type_rcd
		   ,pvdv.active_flag
		   ,pvdv.primary_flag
		   ,pvdv.current_visit_diagnosis_flag
		   ,csed.coding_system_rcd
		   ,csed.code
		   ,csed.description as Diagnosis

	from (

	select distinct apv.patient_id
		   ,api.patient_visit_id
		   ,api.actual_visit_date_time as [Visit Start]
		   ,api.visit_type_rcd
		   ,api.visit_type_name_l as [Visit Type Name]
		   --,stuff((select '; ' + name_l from patient_visit_reason a1 left join visit_reason_ref a2 on a1.visit_reason_rcd = a2.visit_reason_rcd
					--														where a1.patient_visit_id = api.patient_visit_id
					--														for XML PATH('')),1,1,'') as [Visit Reason]
		   ,vrr.name_l as [Visit Reason]
		   ,emp1.display_name_l as [Created By]
		   --,stuff((select '; ' + b1.policy_name_l from api_patient_visit_policy_view b1 where b1.patient_visit_id = api.patient_visit_id
					--														for XML PATH('')),1,1,'') as [Visit Policies]
		   ,ISNULL(apvp.policy_name_l, 'Self Pay') as [Visit Policies]
		   ,apvp.policy_id
		   ,apvp.policy_code
		   ,apv.visible_patient_id as HN
		   ,apv.display_name_l as [Patient Name]
		   ,case when ADNV.city is NULL then city.city_id else ADNV.city_id end as city_id
		   ,case when ADNV.city is NULL then city.name_l else ADNV.city end as City
		   ,case when adnv.city_id is NOT NULL then  (SELECT region_id
																	from AmalgaPROD.dbo.region
																	where region_id = (SELECT region_id
																				from AmalgaPROD.dbo.city_nl_view
																				where city_id = adnv.city_id)) 
															else (SELECT region_id								
																from AmalgaPROD.dbo.region
																where region_id = (SELECT region_id
																					from AmalgaPROD.dbo.subregion_nl_view
																					where subregion_id = adnv.subregion_id))  end as region_id
		   ,case when adnv.city_id is NOT NULL then  (SELECT name_l
																	from AmalgaPROD.dbo.region
																	where region_id = (SELECT region_id
																				from AmalgaPROD.dbo.city_nl_view
																				where city_id = adnv.city_id)) 
															else (SELECT name_l								
																from AmalgaPROD.dbo.region
																where region_id = (SELECT region_id
																					from AmalgaPROD.dbo.subregion_nl_view
																					where subregion_id = adnv.subregion_id))  end as Region
			,case when adnv.city_id is not NULL then (SELECT subr.subregion_id as subregion
																from AmalgaPROD.dbo.subregion_nl_view subr
																where subr.subregion_id = city.subregion_id) else (SELECT subr.subregion_id as subregion
																													from AmalgaPROD.dbo.subregion_nl_view subr
																													where subr.subregion_id = adnv.subregion_id) end as subregion_id
			,case when adnv.city_id is not NULL then (SELECT subr.name_l as subregion
														from AmalgaPROD.dbo.subregion_nl_view subr
														where subr.subregion_id = city.subregion_id) else (SELECT subr.name_l as subregion
																											from AmalgaPROD.dbo.subregion_nl_view subr
																											where subr.subregion_id = adnv.subregion_id) end as Subregion
			,case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as [Address Type]
			,cast(cast((DATEDIFF(dd,apv.date_of_birth,api.closure_date_time) / 365.25) as int) as varchar) as Age
			--,datediff(dd,apv.date_of_birth, getdate()) / 365 as Age
			,apv.date_of_birth as [Date of Birth]
			,apv.nationality_rcd
			,apv.nationality_name_l as Nationality
			,apv.race_name_l as Race
			,case when apv.ethnic_group_rcd_list is null then 'UNK' else apv.ethnic_group_rcd_list end as ethnic_group_rcd_list
			,case when apv.ethnic_group_name_l_list is null then 'Unknown' else apv.ethnic_group_name_l_list end as [Ethnic Group]
			,apv.religion_name_l as Religion
			,apv.religion_rcd
			,apv.sex_rcd
			,apv.sex_name_l as Sex
			,case when apv.home_address_country_rcd is null then 'UNK' else apv.home_address_country_rcd end as home_address_country_rcd
			,case when apv.home_address_country_name_l is null then 'Unknown' else apv.home_address_country_name_l end as [Home Country]
			,apv.residence_country_rcd
			,apv.residence_country_name_l as [Country of Residence]
			,ISNULL(apv.home_address_line_1_l,'') + ' ' + ISNULL(apv.home_address_line_2_l,'') + ISNULL(apv.home_address_line_3_l,'') as [Home Address]
			,api.primary_service_name_l as [Primary Service]
			,api.primary_service_rcd
			,Packages = (SELECT name_l 
							 FROM item_nl_view 
							 WHERE item_id = (SELECT TOP 1 package_item_id 
											  FROM patient_visit_package_nl_view 
											  WHERE patient_visit_id = api.patient_visit_id 
													AND patient_visit_package_status_rcd = 'CRE' 
											  ORDER BY creation_date_time DESC))
			,api.visit_code as [Visit No.]
			,apv.priority_group_name_l as [Priority Group]
			,api.facility_code
			,api.closure_date_time as [Closure Date]
			,pwq.patient_work_queue_entry_id
			,pwtr.name_l as work_queue_type
			,api.cancelled_date_time


	FROM api_patient_visit_view api 
				left join api_patient_view apv on api.patient_id = apv.patient_id
				left join user_account ua on api.created_by = ua.user_id
				left join person_formatted_name_iview emp1 on ua.person_id = emp1.person_id
				left join api_patient_visit_policy_view apvp on api.patient_visit_id = apvp.patient_visit_id
				left join address_label_view al on apv.home_address_id = al.address_id
				left join person_address_nl_view panv ON apv.patient_id = panv.person_id
				left join address_nl_view adnv ON al.address_id = adnv.address_id
				left join city_nl_view city on ADNV.city_id = city.city_id
				left join caregiver_role cr on cr.patient_visit_id = api.patient_visit_id
				left join patient_visit_reason pvr on api.patient_visit_id = pvr.patient_visit_id
				left join visit_reason_ref vrr on pvr.visit_reason_rcd = vrr.visit_reason_rcd
				--left join country_ref cref on apv.home_address_country_rcd = cref.country_rcd
				left join visit_type_ref vtr on api.visit_type_rcd = vtr.visit_type_rcd
				left join patient_work_queue_entry pwq on api.patient_visit_id = pwq.patient_visit_id
														  and pwq.patient_wq_status_rcd <> 'CAN'
														  AND ((vtr.patient_queue_supported_flag = 1 AND pwq.patient_work_queue_entry_id IS NOT NULL)
														  OR vtr.patient_queue_supported_flag = 0)
				left join patient_wq_entry_type_ref pwtr on pwq.patient_wq_entry_type_rcd = pwtr.patient_wq_entry_type_rcd

	where vtr.visit_type_group_rcd = 'OPD'
	  
) as temp
	left join patient_visit_diagnosis_view pvdv on temp.patient_visit_id = pvdv.patient_visit_id
	left join coding_system_element_description csed on pvdv.code = csed.code

where temp.[Address Type] in ('H1','N/A')
	  and (csed.coding_system_rcd is null or csed.coding_system_rcd in ('ICD10', 'ICD9CM'))
	  --and (pvdv.coding_type_rcd is null or pvdv.coding_type_rcd = 'PRI')
	  and isnull(pvdv.current_visit_diagnosis_flag,0) = 1
      and (select count(*) from patient_visit_diagnosis_view
				where patient_visit_id = pvdv.patient_visit_id
				and current_visit_diagnosis_flag = 1) > 0

UNION ALL

	select temp.patient_id
		   ,temp.patient_visit_id
		   ,temp.facility_code
		   ,temp.[Visit Start]
		   ,temp.[Closure Date]
		   ,temp.cancelled_date_time
		   ,temp.visit_type_rcd
		   ,temp.[Visit Type Name]
		   ,temp.[Visit No.]
		   ,temp.[Priority Group]
		   ,temp.[Visit Reason]
		   ,temp.patient_work_queue_entry_id
		   ,temp.work_queue_type
		   ,temp.[Created By]
		   ,temp.[Visit Policies]
		   ,temp.policy_id
		   ,temp.policy_code
		   ,temp.HN
		   ,temp.[Patient Name]
		   ,temp.Region
		   ,temp.Subregion
		   ,temp.City
		   ,temp.[Address Type]
		   ,temp.Age
		   ,temp.[Date of Birth]
		   ,temp.nationality_rcd
		   ,temp.Nationality
		   ,temp.Race
		   ,temp.ethnic_group_rcd_list
		   ,temp.[Ethnic Group]
		   ,temp.religion_rcd
		   ,temp.Religion
		   ,temp.sex_rcd
		   ,temp.Sex
		   ,temp.home_address_country_rcd
		   ,temp.[Home Country]
		   ,temp.residence_country_rcd
		   ,temp.[Country of Residence]
		   ,temp.[Home Address]
		   ,temp.primary_service_rcd
		   ,temp.[Primary Service]
		   ,temp.Packages
		   ,pvdv.diagnosis_type_rcd
		   ,pvdv.coding_type_rcd
		   ,pvdv.active_flag
		   ,pvdv.primary_flag
		   ,pvdv.current_visit_diagnosis_flag
		   ,csed.coding_system_rcd
		   ,csed.code
		   ,csed.description as Diagnosis

	from (

	select distinct apv.patient_id
		   ,api.patient_visit_id
		   ,api.actual_visit_date_time as [Visit Start]
		   ,api.visit_type_rcd
		   ,api.visit_type_name_l as [Visit Type Name]
		   --,stuff((select '; ' + name_l from patient_visit_reason a1 left join visit_reason_ref a2 on a1.visit_reason_rcd = a2.visit_reason_rcd
					--														where a1.patient_visit_id = api.patient_visit_id
					--														for XML PATH('')),1,1,'') as [Visit Reason]
		   ,vrr.name_l as [Visit Reason]
		   ,emp1.display_name_l as [Created By]
		   --,stuff((select '; ' + b1.policy_name_l from api_patient_visit_policy_view b1 where b1.patient_visit_id = api.patient_visit_id
					--														for XML PATH('')),1,1,'') as [Visit Policies]
		   ,ISNULL(apvp.policy_name_l, 'Self Pay') as [Visit Policies]
		   ,apvp.policy_id
		   ,apvp.policy_code
		   ,apv.visible_patient_id as HN
		   ,apv.display_name_l as [Patient Name]
		   ,case when ADNV.city is NULL then city.city_id else ADNV.city_id end as city_id
		   ,case when ADNV.city is NULL then city.name_l else ADNV.city end as City
		   ,case when adnv.city_id is NOT NULL then  (SELECT region_id
																	from AmalgaPROD.dbo.region
																	where region_id = (SELECT region_id
																				from AmalgaPROD.dbo.city_nl_view
																				where city_id = adnv.city_id)) 
															else (SELECT region_id								
																from AmalgaPROD.dbo.region
																where region_id = (SELECT region_id
																					from AmalgaPROD.dbo.subregion_nl_view
																					where subregion_id = adnv.subregion_id))  end as region_id
		   ,case when adnv.city_id is NOT NULL then  (SELECT name_l
																	from AmalgaPROD.dbo.region
																	where region_id = (SELECT region_id
																				from AmalgaPROD.dbo.city_nl_view
																				where city_id = adnv.city_id)) 
															else (SELECT name_l								
																from AmalgaPROD.dbo.region
																where region_id = (SELECT region_id
																					from AmalgaPROD.dbo.subregion_nl_view
																					where subregion_id = adnv.subregion_id))  end as Region
			,case when adnv.city_id is not NULL then (SELECT subr.subregion_id as subregion
																from AmalgaPROD.dbo.subregion_nl_view subr
																where subr.subregion_id = city.subregion_id) else (SELECT subr.subregion_id as subregion
																													from AmalgaPROD.dbo.subregion_nl_view subr
																													where subr.subregion_id = adnv.subregion_id) end as subregion_id
			,case when adnv.city_id is not NULL then (SELECT subr.name_l as subregion
														from AmalgaPROD.dbo.subregion_nl_view subr
														where subr.subregion_id = city.subregion_id) else (SELECT subr.name_l as subregion
																											from AmalgaPROD.dbo.subregion_nl_view subr
																											where subr.subregion_id = adnv.subregion_id) end as Subregion
			,case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as [Address Type]
			,cast(cast((DATEDIFF(dd,apv.date_of_birth,api.closure_date_time) / 365.25) as int) as varchar) as Age
			--,datediff(dd,apv.date_of_birth, getdate()) / 365 as Age
			,apv.date_of_birth as [Date of Birth]
			,apv.nationality_rcd
			,apv.nationality_name_l as Nationality
			,apv.race_name_l as Race
			,case when apv.ethnic_group_rcd_list is null then 'UNK' else apv.ethnic_group_rcd_list end as ethnic_group_rcd_list
			,case when apv.ethnic_group_name_l_list is null then 'Unknown' else apv.ethnic_group_name_l_list end as [Ethnic Group]
			,apv.religion_name_l as Religion
			,apv.religion_rcd
			,apv.sex_rcd
			,apv.sex_name_l as Sex
			,case when apv.home_address_country_rcd is null then 'UNK' else apv.home_address_country_rcd end as home_address_country_rcd
			,case when apv.home_address_country_name_l is null then 'Unknown' else apv.home_address_country_name_l end as [Home Country]
			,apv.residence_country_rcd
			,apv.residence_country_name_l as [Country of Residence]
			,ISNULL(apv.home_address_line_1_l,'') + ' ' + ISNULL(apv.home_address_line_2_l,'') + ISNULL(apv.home_address_line_3_l,'') as [Home Address]
			,api.primary_service_name_l as [Primary Service]
			,api.primary_service_rcd
			,Packages = (SELECT name_l 
							 FROM item_nl_view 
							 WHERE item_id = (SELECT TOP 1 package_item_id 
											  FROM patient_visit_package_nl_view 
											  WHERE patient_visit_id = api.patient_visit_id 
													AND patient_visit_package_status_rcd = 'CRE' 
											  ORDER BY creation_date_time DESC))
			,api.visit_code as [Visit No.]
			,apv.priority_group_name_l as [Priority Group]
			,api.facility_code
			,api.closure_date_time as [Closure Date]
			,pwq.patient_work_queue_entry_id
			,pwtr.name_l as work_queue_type
			,api.cancelled_date_time


	FROM api_patient_visit_view api 
				left join api_patient_view apv on api.patient_id = apv.patient_id
				left join user_account ua on api.created_by = ua.user_id
				left join person_formatted_name_iview emp1 on ua.person_id = emp1.person_id
				left join api_patient_visit_policy_view apvp on api.patient_visit_id = apvp.patient_visit_id
				left join address_label_view al on apv.home_address_id = al.address_id
				left join person_address_nl_view panv ON apv.patient_id = panv.person_id
				left join address_nl_view adnv ON al.address_id = adnv.address_id
				left join city_nl_view city on ADNV.city_id = city.city_id
				left join caregiver_role cr on cr.patient_visit_id = api.patient_visit_id
				left join patient_visit_reason pvr on api.patient_visit_id = pvr.patient_visit_id
				left join visit_reason_ref vrr on pvr.visit_reason_rcd = vrr.visit_reason_rcd
				--left join country_ref cref on apv.home_address_country_rcd = cref.country_rcd
				left join visit_type_ref vtr on api.visit_type_rcd = vtr.visit_type_rcd
				left join patient_work_queue_entry pwq on api.patient_visit_id = pwq.patient_visit_id
														  and pwq.patient_wq_status_rcd <> 'CAN'
														  AND ((vtr.patient_queue_supported_flag = 1 AND pwq.patient_work_queue_entry_id IS NOT NULL)
														  OR vtr.patient_queue_supported_flag = 0)
				left join patient_wq_entry_type_ref pwtr on pwq.patient_wq_entry_type_rcd = pwtr.patient_wq_entry_type_rcd

	where vtr.visit_type_group_rcd = 'OPD'
	  
) as temp
	left join patient_visit_diagnosis_view pvdv on temp.patient_visit_id = pvdv.patient_visit_id
	left join coding_system_element_description csed on pvdv.code = csed.code

where temp.[Address Type] in ('H1','N/A')
	  and (csed.coding_system_rcd is null or csed.coding_system_rcd in ('ICD10', 'ICD9CM'))
	  --and (pvdv.coding_type_rcd is null or pvdv.coding_type_rcd = 'PRI')
      and (select count(*) from patient_visit_diagnosis_view
				where patient_visit_id = pvdv.patient_visit_id
				and current_visit_diagnosis_flag = 1) = 0

)as tempb
where tempb.[Visit Start] between @date1 and @date2
order by [Visit Start]