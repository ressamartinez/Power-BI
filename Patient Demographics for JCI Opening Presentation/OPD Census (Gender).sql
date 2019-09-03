select tempc.Sex
       ,count(case when tempc.Sex = 'Male' and tempc.Classification = 'Minor' then 1 
				   when tempc.Sex = 'Female' and tempc.Classification = 'Minor' then 1
	               when tempc.Sex = 'Unknown' and tempc.Classification = 'Minor' then 1 end) as Minor
	   ,count(case when tempc.Sex = 'Male' and tempc.Classification = 'Adult' then 1 
	               when tempc.Sex = 'Female' and tempc.Classification = 'Adult' then 1 
				   when tempc.Sex = 'Unknown' and tempc.Classification = 'Adult' then 1 end) as Adult
	   ,count(case when tempc.Sex = 'Male' and tempc.Classification = 'Senior' then 1 
	               when tempc.Sex = 'Female' and tempc.Classification = 'Senior' then 1 
				   when tempc.Sex = 'Unknown' and tempc.Classification = 'Senior' then 1 end) as Senior
	   ,count(case when tempc.Sex = 'Male' then 1 
	               when tempc.Sex = 'Female' then 1 
				   when tempc.Sex = 'Unknown' then 1 end) as Total

from (

select tempb.patient_id
	   ,tempb.patient_visit_id
	   ,tempb.facility_code
	   ,tempb.[Visit Start]
	   ,tempb.[Closure Date]
	   ,tempb.[Visit Type Name]
	   ,tempb.[Visit No.]
	   ,tempb.[Priority Group]
	   ,tempb.[Visit Reason]
	   ,tempb.[Created By]
	   ,tempb.[Visit Policies]
	   ,tempb.HN
	   ,tempb.[Patient Name]
	   ,tempb.Region
	   ,tempb.Subregion
	   ,tempb.City
	   ,tempb.[Address Type]
	   ,tempb.Age
	   ,tempb.[Date of Birth]
	   ,tempb.Nationality
	   ,tempb.Race
	   ,tempb.[Ethnic Group]
	   ,tempb.Religion
	   ,tempb.Sex
	   ,tempb.country_rcd
	   ,tempb.Country
	   ,tempb.[Home Address]
	   ,tempb.[Primary Service]
	   ,tempb.Packages
	   ,ISNULL(tempb.[Cardinal Direction], 'International') as [Cardinal Direction]
	   ,tempb.Subregion + ', ' + (case when tempb.Subregion = 'Aurora' then 'Region III (Central Luzon)' else tempb.Region end) + ', ' + tempb.country_rcd as Location
       ,DATENAME(MONTH,tempb.[Visit Start]) as [Month Name]
	   ,DATEPART(m, tempb.[Visit Start]) as [Month ID]
	   ,YEAR(tempb.[Visit Start]) as Year
	   ,case when Age >= 0 and Age <= 18 then 'Minor'
			 when Age >= 19 and Age <= 60 then 'Adult'
			 when Age > 60 then 'Senior'
			 end as Classification

from (

select temp.patient_id
	   ,temp.patient_visit_id
	   ,temp.facility_code
	   ,temp.[Visit Start]
	   ,temp.[Closure Date]
	   ,temp.[Visit Type Name]
	   ,temp.[Visit No.]
	   ,temp.[Priority Group]
	   ,temp.[Visit Reason]
	   ,temp.[Created By]
	   ,temp.[Visit Policies]
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
	   ,temp.country_rcd
	   ,temp.Country
	   ,temp.[Home Address]
	   ,temp.[Primary Service]
	   ,temp.Packages
	   ,case when temp.region_id in ('BB9EF3AD-E153-4264-A4D1-585CA49663D1',
									'782EDCE7-54A8-45E1-A28F-CC968E8085ED',
									'EB2A431D-6A54-4A15-9290-E0FCD8CC7E2F',
									'8567E599-6446-4C44-AEC1-180A15CAC7B4',
									'A819A2A7-9C56-4F9F-980D-42EDBA3DF706') then 'North'
		when temp.region_id = '5492EC17-D67E-4110-AEF7-AFEDB0019D3D' then (case when temp.subregion_id in ('E3B8E064-3631-4D65-8F75-699C5AD98B38',
																											  '6419D7CE-F964-419B-9821-848B60EAD536') then 'South' 
																			   when temp.subregion_id = '69949CD1-5D65-4360-9146-F9EA75D52FE7' then 'West'
																			   when temp.subregion_id = '0A1795AE-7F91-47FD-8B61-DAC5619DCB3C' then 'East'
																			   when temp.subregion_id in ('B8A497E3-242A-4DCD-8E98-475B07F04738','D3A47087-E4F8-4203-A8E3-FF729E511EA0') then 'North'
																			   
																       end)
		 when temp.region_id in ('9641BDC3-66E8-4356-BD8B-036635144D0A',
									'6E295C6A-403B-4A3E-BBA5-2422BC275747',
									'5843FFE5-2C44-4B8A-A0AF-31434FC2976E',
									'D409522B-EADD-4ED4-BA17-569CA5F79AB5',
									'A05FE1A4-6191-4314-8166-581D3CC8DF85',
									'7E9C4BFC-7CF7-49ED-8D1E-86D577C8FBF1',
									'19C7AF39-03F5-4565-A37C-C90302F68607',
									'02154BC9-2DC5-410D-8818-C93CD3083621',
									'D5C0A045-2C5F-45BC-B650-E39FA4C1164C',
									'64B41AB2-126C-442E-A007-26F87D3540AE',
									'43419A2D-316F-4220-8D77-F0E392DEFBFC') then 'South'
	end as [Cardinal Direction]

from (

select distinct apv.patient_id
	   ,api.patient_visit_id
	   ,api.actual_visit_date_time as [Visit Start]
	   ,api.visit_type_name_l as [Visit Type Name]
	   ,stuff((select '; ' + name_l from patient_visit_reason a1 left join visit_reason_ref a2 on a1.visit_reason_rcd = a2.visit_reason_rcd
																		where a1.patient_visit_id = api.patient_visit_id
																		for XML PATH('')),1,1,'') as [Visit Reason]
	   --,vrr.name_l as [Visit Reason]
	   ,emp1.display_name_l as [Created By]
	   ,stuff((select '; ' + b1.policy_name_l from api_patient_visit_policy_view b1 where b1.patient_visit_id = api.patient_visit_id
																		for XML PATH('')),1,1,'') as [Visit Policies]
	   --,ISNULL(apvp.policy_name_l, 'Self Pay') as [Visit Policies]
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
															where subr.subregion_id = city.subregion_id) 
											else (SELECT subr.subregion_id as subregion
													from AmalgaPROD.dbo.subregion_nl_view subr
													where subr.subregion_id = adnv.subregion_id) end as subregion_id
		,case when adnv.city_id is not NULL then (SELECT subr.name_l as subregion
													from AmalgaPROD.dbo.subregion_nl_view subr
													where subr.subregion_id = adnv.subregion_id) 
											else (SELECT subr.name_l as subregion
													from AmalgaPROD.dbo.subregion_nl_view subr
													where subr.subregion_id = adnv.subregion_id) end as Subregion
		,case when panv.person_address_type_rcd is NULL then 'N/A' ELSE panv.person_address_type_rcd end as [Address Type]
		,datediff(dd,apv.date_of_birth, getdate()) / 365 as Age
		,apv.date_of_birth as [Date of Birth]
		,apv.nationality_rcd
		,apv.nationality_name_l as Nationality
		,apv.race_name_l as Race
		,apv.ethnic_group_name_l_list as [Ethnic Group]
		,apv.religion_name_l as Religion
		,apv.sex_name_l as Sex
		,adnv.country_rcd
		,cref.name_l as Country
		,ISNULL(apv.home_address_line_1_l,'') + ' ' + ISNULL(apv.home_address_line_2_l,'') + ISNULL(apv.home_address_line_3_l,'') as [Home Address]
		,api.primary_service_name_l as [Primary Service]
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

FROM api_patient_visit_view api 
			left join api_patient_view apv on api.patient_id = apv.patient_id
			left join user_account ua on api.created_by = ua.user_id
			left join person_formatted_name_iview emp1 on ua.person_id = emp1.person_id
			left join api_patient_visit_policy_view apvp on api.patient_visit_id = apvp.patient_visit_id
			left join person_address_nl_view panv ON apv.patient_id = panv.person_id
			left join address_nl_view adnv ON panv.address_id = adnv.address_id
			left join city_nl_view city on ADNV.city_id = city.city_id
			left join caregiver_role cr on cr.patient_visit_id = api.patient_visit_id
			left join patient_visit_reason pvr on api.patient_visit_id = pvr.patient_visit_id
			left join visit_reason_ref vrr on pvr.visit_reason_rcd = vrr.visit_reason_rcd
			left join country_ref cref on adnv.country_rcd = cref.country_rcd
			left join visit_type_ref vtr on api.visit_type_rcd = vtr.visit_type_rcd

where 
	  year(actual_visit_date_time) = 2018
      --and month(actual_visit_date_time) = 1  
      and cancelled_date_time is null
	  and panv.effective_until_date is null
      and vtr.visit_type_group_rcd = 'OPD'
	  

) as temp

where temp.[Address Type] in ('H1','N/A')
--and temp.[Visit No.] in ('2324176', '2324269')
)as tempb
--order by tempb.[Visit Start]

) as tempc
group by tempc.Sex