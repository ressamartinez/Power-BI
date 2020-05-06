
select temp.patient_visit_id,
       temp.[Policy Code],
       temp.Policy,
	   temp.[Visit Type Group],
	   temp.[GL Account Code],
	   temp.[GL Account Name],
	   temp.[Invoice Date],
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
       case when tvr.patient_visit_id is null then (Select distinct _tvr.patient_visit_id from temp_volume_revenue _tvr
	                                                       where _tvr.patient_visit_id = tvr.patient_visit_id) 
	   else tvr.patient_visit_id end as patient_visit_id,
	   tvr.[Policy Code],
	   tvr.Policy,
	   tvr.[Visit Type Group],
	   tvr.[GL Account Code],
	   tvr.[GL Account Name],
	   tvr.[Invoice Date],
	   tvr.[Invoice Number],
	   tvr.[Related Invoice],
	   tvr.[Related Invoice Date],
	   tvr.[Costcentre Code],
	   tvr.Costcentre,
	   tvr.[Gross Amount],
	   tvr.ar_invoice_detail_id,
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

from temp_volume_revenue tvr left join ipd_census_1 ipd on ipd.patient_visit_id = tvr.patient_visit_id 
where tvr.patient_visit_id in (SELECT _ipd.patient_visit_id from ipd_census_1 _ipd
	                                        where _ipd.patient_visit_id = ipd.patient_visit_id)

UNION ALL

select distinct        
       case when tvr.patient_visit_id is null then (Select distinct _tvr.patient_visit_id from temp_volume_revenue _tvr
	                                                       where _tvr.patient_visit_id = tvr.patient_visit_id) 
	   else tvr.patient_visit_id end as patient_visit_id,
	   tvr.[Policy Code],
	   tvr.Policy,
	   tvr.[Visit Type Group],
	   tvr.[GL Account Code],
	   tvr.[GL Account Name],
	   tvr.[Invoice Date],
	   tvr.[Invoice Number],
	   tvr.[Related Invoice],
	   tvr.[Related Invoice Date],
	   tvr.[Costcentre Code],
	   tvr.Costcentre,
	   tvr.[Gross Amount],
	   tvr.ar_invoice_detail_id,
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

from temp_volume_revenue tvr left join opd_census_1 opd on opd.patient_visit_id = tvr.patient_visit_id 
where tvr.patient_visit_id in (SELECT _opd.patient_visit_id from opd_census_1 _opd
	                                        where _opd.patient_visit_id = opd.patient_visit_id)

)as temp

order by temp.[Invoice Date]