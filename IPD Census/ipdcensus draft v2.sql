select distinct temp.patient_id
		, temp.patient_visit_id
		, temp.[Visit Start]
		, temp.[Expected Discharge Date]
		, temp.[Closure Date]
		, temp.[Visit Type Name]
		, temp.[Visit Reason]
		, temp.[Visit Code]
		, temp.[Created By]
		, temp.[Place of Admission]
		, temp.[Length of Stay]
		, temp.Policy
		, temp.HN
		, temp.[Patient Name]
		, temp.City
		, temp.Region
		, temp.Subregion
		, temp.Age
		, temp.[Date of Birth]
		, temp.Nationality
		, temp.Race
		, temp.[Ethnic Group]
		, temp.Religion
		, temp.Gender
		, temp.Country
		, temp.[Home Address]
		, temp.[Primary Service]
		, temp.Ward
		, temp.[Room Code]
		, temp.[Room Class Name]
		--, temp.[Bed Type]
		, temp.[Primary Doctor]
		--, temp.Diagnosis
		, temp.Description as [Diagnosis]

		
from
(
select distinct
		api.patient_id 
		,api.patient_visit_id
		,api.visible_patient_id as HN
		,pfn.display_name_l as [Patient Name]
		,case when pfn.sex_rcd = 'M' then 'Male' else 'Female' end as [Gender]
		,pfn.date_of_birth as [Date of Birth]
		,datediff(dd,pfn.date_of_birth, getdate()) / 365 as Age
		,pfn.nationality_rcd as [Nationality]
		,api.visit_type_name_l as [Visit Type Name]
		,api.visit_code as [Visit Code]
		,api.actual_visit_date_time as [Visit Start]
		,api.expected_discharge_date_time as [Expected Discharge Date]
		,api.closure_date_time as [Closure Date]
		,datediff(dd,api.actual_visit_date_time,api.closure_date_time) as [Length of Stay]
		,api.primary_service_name_l as [Primary Service]
		,api.created_from_area_name_l as [Place of Admission]
		--,bev.ward_name_l as [Ward]
		,api.admission_bed_code as [Room Code]
		,api.admission_room_charge_set_name_l as [Room Class Name]
		--,btr.name_l as [Bed Type] 
		,emp1.display_name_l as [Created By]
		,emp2.display_name_l as [Primary Doctor]
		--,(select top 1 description from coding_system_element_description csed
		--					where csed.code = pvdv.code
		--					and pvdv.current_visit_diagnosis_flag = 1) as [Diagnosis]
		,csed.description as [Description]
		--,vrr.name_l as [Visit Reason]
		,case when ADNV.city is NULL then city.name_l else ADNV.city end as City
		,ISNULL(ADNV.address_line_1_l,'') + ' ' + ISNULL(adnv.address_line_2_l,'') + ISNULL(adnv.address_line_3_l,'') as [Home Address]
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
		,case when adnv.city_id is not NULL then (SELECT subr.name_l as subregion
													from AmalgaPROD.dbo.subregion_nl_view subr
													where subr.subregion_id = adnv.subregion_id) else (SELECT subr.name_l as subregion
																										from AmalgaPROD.dbo.subregion_nl_view subr
																										where subr.subregion_id = adnv.subregion_id) end as Subregion
		,case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as [Address Type]
		,rr.name_l as [Religion]
		,cref.name_l as [Country]
		,rce.name_l as [Race]
		,egr.name_l as [Ethnic Group]
		,(select top 1 ward_name_l from bed_entry_info_view t1 
		where t1.patient_visit_id = api.patient_visit_id
		order by start_date_time desc
						) as [Ward]
		,stuff((select '; ' + name_l from patient_visit_reason a1 left join visit_reason_ref a2 on a1.visit_reason_rcd = a2.visit_reason_rcd
																		where a1.patient_visit_id = api.patient_visit_id
																		for XML PATH('')),1,1,'') as [Visit Reason]
		,stuff((select '; ' + b1.policy_name_l from api_patient_visit_policy_view b1 where b1.patient_visit_id = api.patient_visit_id
																		for XML PATH('')),1,1,'') as Policy


FROM api_patient_visit_view api
						left join user_account ua on api.created_by = ua.user_id
						left join person_formatted_name_iview emp1 on ua.person_id = emp1.person_id
						left join person_formatted_name_iview pfn on pfn.person_id = api.patient_id
						left join bed_entry_info_view bev on bev.patient_visit_id = api.patient_visit_id
						left join caregiver_role cr on cr.patient_visit_id = api.patient_visit_id
						left join person_formatted_name_iview emp2 on emp2.person_id = cr.employee_id
						left join patient_visit_diagnosis_view pvdv on pvdv.patient_visit_id = api.patient_visit_id
						left join patient_visit_reason pvr on pvr.patient_visit_id = api.patient_visit_id
						left join visit_reason_ref vrr on vrr.visit_reason_rcd = pvr.visit_reason_rcd
						left join coding_system_element_description csed on csed.code = pvdv.code
						left join bed_type_ref btr on btr.bed_type_rcd = bev.bed_type_rcd
						left join person_address_nl_view panv ON api.patient_id = panv.person_id
						left join address_nl_view adnv ON panv.address_id = adnv.address_id
						left join city_nl_view city on ADNV.city_id = city.city_id
						left join country_ref cref on adnv.country_rcd = cref.country_rcd
						left join person p on p.person_id = api.patient_id
						left join religion_ref rr on rr.religion_rcd = p.religion_rcd
						left join race_ref rce on rce.race_rcd = p.race_rcd
						left join person_ethnic_group peg on peg.person_id = api.patient_id
						left join ethnic_group_ref egr on egr.ethnic_group_rcd = peg.ethnic_group_rcd
						left join api_patient_visit_policy_view apv on api.patient_visit_id = apv.patient_visit_id

where year(api.actual_visit_date_time) = 2018
     and month(actual_visit_date_time) = 1
     and api.closure_date_time is NOT null
      and api.cancelled_date_time is null
      and api.visit_type_rcd in ('V1', 'V2')
      and api.discharge_status_rcd = 'COM'
	  and cr.caregiver_role_type_rcd = 'PRIDR'
	  and cr.caregiver_role_status_rcd = 'ACTIV'
	  and isnull(pvdv.current_visit_diagnosis_flag,0) = 1 
	  and peg.active_flag = 1
	  and rce.active_status = 'a'
	  and egr.active_status = 'a'	
	  and panv.effective_until_date is null  
	  --and api.visible_patient_id in ('00006719', '00509908'/*, '00032498'*/) 
      --and last_status_rcd is NULL
--order by actual_visit_date_time
) as temp
where temp.[Address Type] in ('H1','N/A')
order by temp.[Patient Name]