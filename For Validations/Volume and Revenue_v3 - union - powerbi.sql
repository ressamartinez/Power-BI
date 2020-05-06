DECLARE @From datetime
DECLARE @To datetime

SET @From = '01/01/2020 00:00:00.000'		
SET @To = '01/31/2020 23:59:59.998'


select temp.patient_visit_id,
       temp.[Policy Code],
       temp.Policy,
	   temp.[Visit Type Group],
	   temp.[GL Account Code],
	   temp.[GL Account Name],
	   temp.[Effective Date],
	   temp.[Invoice Date],
	   temp.PAR,
	   temp.[Invoice Number],
	   temp.[Related Invoice],
	   temp.[Related Invoice Date],
	   temp.[Costcentre Code],
	   temp.Costcentre,
	   temp.[Gross Amount],
	   temp.ar_invoice_detail_id,
	   temp.[Visit Start],
	   temp.[Closure Date],
	   temp.[Cancelled Visit Date],
	   temp.HN,
	   temp.[Patient Name],
	   temp.Age,
	   temp.Sex,
	   temp.Nationality,
	   temp.[Home Country],
	   temp.[Country of Residence],
	   temp.Diagnosis,
	   case when temp.Age >= 0 and temp.Age <= 2 then '0 - 2'
			when temp.Age >= 3 and temp.Age <= 6 then '3 - 6'
			when temp.Age >= 7 and temp.Age <= 12 then '7 - 12'
			when temp.Age >= 13 and temp.Age <= 18 then '13 - 18'
			when temp.Age >= 19 and temp.Age <= 36 then '19 - 36'
			when temp.Age >= 37 and temp.Age <= 59 then '37 - 59'
			when temp.Age >= 60  then '60 and above'
	   end as [Age Group]

from (

select distinct 
       case when vr.patient_visit_id is null then (Select distinct _vr.patient_visit_id from volume_revenue _vr
	                                                       where _vr.patient_visit_id = vr.patient_visit_id) 
	   else vr.patient_visit_id end as patient_visit_id,
	   vr.[Policy Code],
	   vr.Policy,
	   vr.[Visit Type Group],
	   vr.[GL Account Code],
	   vr.[GL Account Name],
	   vr.[Effective Date],
	   vr.[Invoice Date],
	   vr.PAR,
	   vr.[Invoice Number],
	   vr.[Related Invoice],
	   vr.[Related Invoice Date],
	   vr.[Costcentre Code],
	   vr.Costcentre,
	   vr.[Gross Amount],
	   vr.ar_invoice_detail_id,
       ipd.[Visit Start],
	   ipd.[Closure Date],
	   ipd.cancelled_date_time as [Cancelled Visit Date],
	   ipd.HN,
	   ipd.[Patient Name],
	   ipd.Age,
	   ipd.Sex,
	   ipd.Nationality,
	   ipd.[Home Country],
	   ipd.[Country of Residence],
	   ipd.Diagnosis

from volume_revenue vr left join ipd_census_1 ipd on ipd.patient_visit_id = vr.patient_visit_id 
where vr.PAR like 'PAR%'
	  and vr.patient_visit_id in (SELECT _ipd.patient_visit_id from ipd_census_1 _ipd
	                                        where _ipd.patient_visit_id = ipd.patient_visit_id)

UNION ALL

select distinct        
       case when vr.patient_visit_id is null then (Select distinct _vr.patient_visit_id from volume_revenue _vr
	                                                       where _vr.patient_visit_id = vr.patient_visit_id) 
	   else vr.patient_visit_id end as patient_visit_id,
	   vr.[Policy Code],
	   vr.Policy,
	   vr.[Visit Type Group],
	   vr.[GL Account Code],
	   vr.[GL Account Name],
	   vr.[Effective Date],
	   vr.[Invoice Date],
	   vr.PAR,
	   vr.[Invoice Number],
	   vr.[Related Invoice],
	   vr.[Related Invoice Date],
	   vr.[Costcentre Code],
	   vr.Costcentre,
	   vr.[Gross Amount],
	   vr.ar_invoice_detail_id,
       opd.[Visit Start],
	   opd.[Closure Date],
	   opd.cancelled_date_time as [Cancelled Visit Date],
	   opd.HN,
	   opd.[Patient Name],
	   opd.Age,
	   opd.Sex,
	   opd.Nationality,
	   opd.[Home Country],
	   opd.[Country of Residence],
	   opd.Diagnosis

from volume_revenue vr left join opd_census_1 opd on opd.patient_visit_id = vr.patient_visit_id 
where vr.PAR like 'PAR%'
	  and vr.patient_visit_id in (SELECT _opd.patient_visit_id from opd_census_1 _opd
	                                        where _opd.patient_visit_id = opd.patient_visit_id)

UNION ALL

select case when vr.patient_visit_id is null then (Select distinct _vr.patient_visit_id from volume_revenue _vr
	                                                       where _vr.patient_visit_id = vr.patient_visit_id) 
	   else vr.patient_visit_id end as patient_visit_id,
	   --vr.patient_visit_id,
	   vr.[Policy Code],
	   vr.Policy,
	   vr.[Visit Type Group],
	   vr.[GL Account Code],
	   vr.[GL Account Name],
	   vr.[Effective Date],
	   vr.[Invoice Date],
	   vr.PAR,
	   vr.[Invoice Number],
	   vr.[Related Invoice],
	   vr.[Related Invoice Date],
	   vr.[Costcentre Code],
	   vr.Costcentre,
	   vr.[Gross Amount],
	   vr.ar_invoice_detail_id,
	   pv.actual_visit_date_time as [Visit Start],
	   pv.closure_date_time as [Closure Date],
	   pv.cancelled_date_time as [Cancelled Visit Date],
	   apv.visible_patient_id collate SQL_Latin1_General_CP1_CI_AS as HN,
	   apv.display_name_l collate SQL_Latin1_General_CP1_CI_AS as [Patient Name],
	   cast(cast((DATEDIFF(dd,apv.date_of_birth,pv.closure_date_time) / 365.25) as int) as varchar) collate SQL_Latin1_General_CP1_CI_AS as Age,
	   apv.sex_name_l collate SQL_Latin1_General_CP1_CI_AS as Sex,
	   apv.nationality_name_l collate SQL_Latin1_General_CP1_CI_AS as Nationality,
	   apv.home_address_country_name_l collate SQL_Latin1_General_CP1_CI_AS as [Home Country],
	   apv.residence_country_name_l collate SQL_Latin1_General_CP1_CI_AS as [Country of Residence],
	   csed.description collate SQL_Latin1_General_CP1_CI_AS as Diagnosis

from volume_revenue vr left join AmalgaPROD.dbo.patient_visit pv on vr.patient_visit_id = pv.patient_visit_id
                            left join AmalgaPROD.dbo.api_patient_view apv on pv.patient_id = apv.patient_id
							left join AmalgaPROD.dbo.patient_visit_diagnosis_view pvdv on vr.patient_visit_id = pvdv.patient_visit_id
	                        left join AmalgaPROD.dbo.coding_system_element_description csed on pvdv.code = csed.code
where vr.PAR like 'GJV%'

)as temp
where  CAST(CONVERT(VARCHAR(10),temp.[Effective Date],101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
	  and CAST(CONVERT(VARCHAR(10),temp.[Effective Date],101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)

order by par desc