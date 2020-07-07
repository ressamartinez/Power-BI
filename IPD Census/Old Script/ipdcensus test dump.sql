--select count(distinct tempc.patient_visit_id)

--from (

select tempb.patient_id
	   ,tempb.patient_visit_id
	   ,tempb.[Visit Start]
	   ,tempb.[Expected Discharge Date]
	   ,tempb.[Closure Date]
	   ,tempb.cancelled_date_time
	   ,tempb.[Visit Type Name]
	   ,tempb.[Visit Reason]
	   ,tempb.[Created By]
	   ,tempb.[Place of Admission]
	   ,tempb.[Length of Stay]
	   ,tempb.[Visit Policies]
	   ,tempb.policy_id
	   ,tempb.HN
	   ,tempb.[Patient Name]
	   ,tempb.Region
	   ,tempb.Subregion
	   ,tempb.City
	   ,tempb.[Address Type]
	   ,case when tempb.Age is null then (cast(cast((DATEDIFF(dd,tempb.[Date of Birth],GETDATE()) / 365.25) as int) as varchar)) else tempb.Age end as Age
	   ,tempb.[Date of Birth]
	   ,tempb.Nationality
	   ,tempb.Race
	   ,tempb.[Ethnic Group]
	   ,tempb.Religion
	   ,tempb.Sex
	   ,tempb.[Home Country]
	   ,tempb.[Country of Residence]
	   ,tempb.[Home Address]
	   ,tempb.[Primary Service]
	   ,tempb.Ward
	   ,tempb.[Room Code]
	   ,tempb.[Room Class Name]
	   ,tempb.[Primary Doctor]
	   ,tempb.diagnosis_type_rcd
	   ,tempb.Diagnosis
	   ,tempb.[Discharge Reason]
	   ,tempb.[Discharge Notes]
	   ,tempb.[Discharge Outcome]
	   ,tempb.[Discharge Disposition]

from (

select temp.patient_id
	   ,temp.patient_visit_id
	   ,temp.[Visit Start]
	   ,temp.[Expected Discharge Date]
	   ,temp.[Closure Date]
	   ,temp.cancelled_date_time
	   ,temp.[Visit Type Name]
	   ,temp.[Visit Reason]
	   ,temp.[Created By]
	   ,temp.[Place of Admission]
	   ,temp.[Length of Stay]
	   ,temp.[Visit Policies]
	   ,temp.policy_id
	   ,temp.HN
	   ,temp.[Patient Name]
	   ,temp.Region
	   ,temp.Subregion
	   ,temp.City
	   ,temp.[Address Type]
	   ,temp.Age
	   ,temp.[Date of Birth]
	   ,temp.Nationality
	   ,temp.Race
	   ,temp.[Ethnic Group]
	   ,temp.Religion
	   ,temp.Sex
	   ,temp.home_address_country_rcd
	   ,temp.[Home Country]
	   ,temp.residence_country_rcd
	   ,temp.[Country of Residence]
	   ,temp.[Home Address]
	   ,temp.[Primary Service]
	   ,temp.Ward
	   ,temp.[Room Code]
	   ,temp.[Room Class Name]
	   ,temp.[Primary Doctor]
	   ,pvdv.diagnosis_type_rcd
	   ,pvdv.coding_type_rcd
	   ,pvdv.active_flag
	   ,pvdv.primary_flag
	   ,pvdv.current_visit_diagnosis_flag
	   ,csed.coding_system_rcd
       ,csed.description as Diagnosis
	   ,temp.[Discharge Reason]
	   ,temp.[Discharge Notes]
	   ,temp.[Discharge Outcome]
	   ,temp.[Discharge Disposition]

from (

select distinct apv.patient_id
	   ,api.patient_visit_id
	   ,api.actual_visit_date_time as [Visit Start]
	   ,api.expected_discharge_date_time as [Expected Discharge Date]
	   ,api.closure_date_time as [Closure Date]
	   ,api.cancelled_date_time
	   ,api.visit_type_name_l as [Visit Type Name]
	   --,stuff((select '; ' + name_l from patient_visit_reason a1 left join visit_reason_ref a2 on a1.visit_reason_rcd = a2.visit_reason_rcd
				--														where a1.patient_visit_id = api.patient_visit_id
				--														for XML PATH('')),1,1,'') as [Visit Reason]
	   ,vrr.name_l as [Visit Reason]
	   ,emp1.display_name_l as [Created By]
	   ,api.created_from_area_name_l as [Place of Admission]
	   ,datediff(dd,api.actual_visit_date_time,api.closure_date_time) as [Length of Stay]
	   --,stuff((select '; ' + b1.policy_name_l from api_patient_visit_policy_view b1 where b1.patient_visit_id = api.patient_visit_id
				--														for XML PATH('')),1,1,'') as [Visit Policies]
	   ,ISNULL(apvp.policy_name_l, 'Self Pay') as [Visit Policies]
	   ,apvp.policy_id
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
													where subr.subregion_id = adnv.subregion_id) else (SELECT subr.name_l as subregion
																										from AmalgaPROD.dbo.subregion_nl_view subr
																										where subr.subregion_id = adnv.subregion_id) end as Subregion
		,case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as [Address Type]
		--,datediff(dd,apv.date_of_birth, getdate()) / 365 as Age
		,cast(cast((DATEDIFF(dd,apv.date_of_birth,api.closure_date_time) / 365.25) as int) as varchar) as Age
		,apv.date_of_birth as [Date of Birth]
		,apv.nationality_rcd
		,apv.nationality_name_l as Nationality
		,apv.race_name_l as Race
		,case when apv.ethnic_group_name_l_list is null then 'Unknown' else apv.ethnic_group_name_l_list end as [Ethnic Group]
		,apv.religion_name_l as Religion
		,apv.sex_name_l as Sex
		,case when apv.home_address_country_rcd is null then 'UNK' else apv.home_address_country_rcd end as home_address_country_rcd
		,case when apv.home_address_country_name_l is null then 'Unknown' else apv.home_address_country_name_l end as [Home Country]
		,apv.residence_country_rcd
		,apv.residence_country_name_l as [Country of Residence]
		,ISNULL(apv.home_address_line_1_l,'') + ' ' + ISNULL(apv.home_address_line_2_l,'') + ISNULL(apv.home_address_line_3_l,'') as [Home Address]
		,api.primary_service_name_l as [Primary Service]
		,(select top 1 ward_name_l from bed_entry_info_view t1 
					where t1.patient_visit_id = api.patient_visit_id
					order by start_date_time desc) as Ward
	    ,api.admission_bed_code as [Room Code]
		,api.admission_room_charge_set_name_l as [Room Class Name]
		,emp2.display_name_l as [Primary Doctor]
		,api.discharge_reason_name_l as [Discharge Reason]
		,api.discharge_notes as [Discharge Notes]
		,api.discharge_outcome_name_l as [Discharge Outcome]
		,api.discharge_disposition_name_l as [Discharge Disposition]

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
			left join person_formatted_name_iview emp2 on emp2.person_id = cr.employee_id
			left join patient_visit_reason pvr on api.patient_visit_id = pvr.patient_visit_id
			left join visit_reason_ref vrr on pvr.visit_reason_rcd = vrr.visit_reason_rcd
			--left join country_ref cref on apv.home_address_country_rcd = cref.country_rcd


where 
	  cancelled_date_time is null
      and api.visit_type_rcd in ('V1', 'V2')
      --and discharge_status_rcd = 'COM'
	  --and panv.effective_until_date is null 
	  and cr.caregiver_role_type_rcd = 'PRIDR'
	  and cr.caregiver_role_status_rcd = 'ACTIV'
	  --and api.visible_patient_id in ('00006719', '00509908', '00032498')  
      --and last_status_rcd is NULL

) as temp
			left join patient_visit_diagnosis_view pvdv on pvdv.patient_visit_id = temp.patient_visit_id
			left join coding_system_element_description csed on csed.code = pvdv.code

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
	   ,temp.[Visit Start]
	   ,temp.[Expected Discharge Date]
	   ,temp.[Closure Date]
	   ,temp.cancelled_date_time
	   ,temp.[Visit Type Name]
	   ,temp.[Visit Reason]
	   ,temp.[Created By]
	   ,temp.[Place of Admission]
	   ,temp.[Length of Stay]
	   ,temp.[Visit Policies]
	   ,temp.policy_id
	   ,temp.HN
	   ,temp.[Patient Name]
	   ,temp.Region
	   ,temp.Subregion
	   ,temp.City
	   ,temp.[Address Type]
	   ,temp.Age
	   ,temp.[Date of Birth]
	   ,temp.Nationality
	   ,temp.Race
	   ,temp.[Ethnic Group]
	   ,temp.Religion
	   ,temp.Sex
	   ,temp.home_address_country_rcd
	   ,temp.[Home Country]
	   ,temp.residence_country_rcd
	   ,temp.[Country of Residence]
	   ,temp.[Home Address]
	   ,temp.[Primary Service]
	   ,temp.Ward
	   ,temp.[Room Code]
	   ,temp.[Room Class Name]
	   ,temp.[Primary Doctor]
	   ,pvdv.diagnosis_type_rcd
	   ,pvdv.coding_type_rcd
	   ,pvdv.active_flag
	   ,pvdv.primary_flag
	   ,pvdv.current_visit_diagnosis_flag
	   ,csed.coding_system_rcd
       ,csed.description as Diagnosis
	   ,temp.[Discharge Reason]
	   ,temp.[Discharge Notes]
	   ,temp.[Discharge Outcome]
	   ,temp.[Discharge Disposition]

from (

select distinct apv.patient_id
	   ,api.patient_visit_id
	   ,api.actual_visit_date_time as [Visit Start]
	   ,api.expected_discharge_date_time as [Expected Discharge Date]
	   ,api.closure_date_time as [Closure Date]
	   ,api.cancelled_date_time
	   ,api.visit_type_name_l as [Visit Type Name]
	   --,stuff((select '; ' + name_l from patient_visit_reason a1 left join visit_reason_ref a2 on a1.visit_reason_rcd = a2.visit_reason_rcd
				--														where a1.patient_visit_id = api.patient_visit_id
				--														for XML PATH('')),1,1,'') as [Visit Reason]
	   ,vrr.name_l as [Visit Reason]
	   ,emp1.display_name_l as [Created By]
	   ,api.created_from_area_name_l as [Place of Admission]
	   ,datediff(dd,api.actual_visit_date_time,api.closure_date_time) as [Length of Stay]
	   --,stuff((select '; ' + b1.policy_name_l from api_patient_visit_policy_view b1 where b1.patient_visit_id = api.patient_visit_id
				--														for XML PATH('')),1,1,'') as [Visit Policies]
	   ,ISNULL(apvp.policy_name_l, 'Self Pay') as [Visit Policies]
	   ,apvp.policy_id
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
													where subr.subregion_id = adnv.subregion_id) else (SELECT subr.name_l as subregion
																										from AmalgaPROD.dbo.subregion_nl_view subr
																										where subr.subregion_id = adnv.subregion_id) end as Subregion
		,case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as [Address Type]
		--,datediff(dd,apv.date_of_birth, getdate()) / 365 as Age
		,cast(cast((DATEDIFF(dd,apv.date_of_birth,api.closure_date_time) / 365.25) as int) as varchar) as Age
		,apv.date_of_birth as [Date of Birth]
		,apv.nationality_rcd
		,apv.nationality_name_l as Nationality
		,apv.race_name_l as Race
		,case when apv.ethnic_group_name_l_list is null then 'Unknown' else apv.ethnic_group_name_l_list end as [Ethnic Group]
		,apv.religion_name_l as Religion
		,apv.sex_name_l as Sex
		,case when apv.home_address_country_rcd is null then 'UNK' else apv.home_address_country_rcd end as home_address_country_rcd
		,case when apv.home_address_country_name_l is null then 'Unknown' else apv.home_address_country_name_l end as [Home Country]
		,apv.residence_country_rcd
		,apv.residence_country_name_l as [Country of Residence]
		,ISNULL(apv.home_address_line_1_l,'') + ' ' + ISNULL(apv.home_address_line_2_l,'') + ISNULL(apv.home_address_line_3_l,'') as [Home Address]
		,api.primary_service_name_l as [Primary Service]
		,(select top 1 ward_name_l from bed_entry_info_view t1 
					where t1.patient_visit_id = api.patient_visit_id
					order by start_date_time desc) as Ward
	    ,api.admission_bed_code as [Room Code]
		,api.admission_room_charge_set_name_l as [Room Class Name]
		,emp2.display_name_l as [Primary Doctor]
		,api.discharge_reason_name_l as [Discharge Reason]
		,api.discharge_notes as [Discharge Notes]
		,api.discharge_outcome_name_l as [Discharge Outcome]
		,api.discharge_disposition_name_l as [Discharge Disposition]

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
			left join person_formatted_name_iview emp2 on emp2.person_id = cr.employee_id
			left join patient_visit_reason pvr on api.patient_visit_id = pvr.patient_visit_id
			left join visit_reason_ref vrr on pvr.visit_reason_rcd = vrr.visit_reason_rcd
			--left join country_ref cref on apv.home_address_country_rcd = cref.country_rcd

where 
	  cancelled_date_time is null
      and api.visit_type_rcd in ('V1', 'V2')
      --and discharge_status_rcd = 'COM'
	  --and panv.effective_until_date is null 
	  and cr.caregiver_role_type_rcd = 'PRIDR'
	  and cr.caregiver_role_status_rcd = 'ACTIV'
	  --and api.visible_patient_id in ('00006719', '00509908', '00032498')  
      --and last_status_rcd is NULL

) as temp
			left join patient_visit_diagnosis_view pvdv on temp.patient_visit_id = pvdv.patient_visit_id
			left join coding_system_element_description csed on pvdv.code = csed.code

where temp.[Address Type] in ('H1','N/A')
	  and (csed.coding_system_rcd is null or csed.coding_system_rcd in ('ICD10', 'ICD9CM'))
	  and (pvdv.coding_type_rcd is null or pvdv.coding_type_rcd = 'PRI')
      and (select count(*) from patient_visit_diagnosis_view
				where patient_visit_id = pvdv.patient_visit_id
				and current_visit_diagnosis_flag = 1) = 0

) as tempb
where 
      --year(tempb.[Visit Start]) = 2018
      --and month(tempb.[Visit Start]) = 11
	   CAST(CONVERT(VARCHAR(10),tempb.[Visit Start],101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),'01/01/2019',101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),tempb.[Visit Start],101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),'12/31/2019',101) as SMALLDATETIME)
	  --and tempb.HN in ('00007616')
	  --and tempb.[Room Code] not like '%-%'
--and tempb.patient_visit_id = '09EF6AC9-2239-11EA-A0D4-484D7EF1A97B'
	  
--) as tempc
order by tempb.[Visit Start]