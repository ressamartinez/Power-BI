
select tempb.[Visit Start],
       tempb.[Closure Date],
	   tempb.invoice_date,
	   tempb.HN,
	   tempb.[Patient Name],
	   tempb.policy,     --invoice
	   tempb.main_group_code,
	   tempb.main_group_name,
	   gross_amount = sum(tempb.gross_amount),
	   discount_amount = sum(tempb.discount_amount),
	   tempb.main_gl_code,
	   tempb.main_gl_name,
	   tempb.gl_acct_code,
	   tempb.gl_acct_name,
	   tempb.patient_visit_id

from (

	select distinct temp.patient_visit_id,
	       temp.ar_invoice_id,
		   temp.ar_invoice_detail_id,
	       ipd.[Visit Start],
		   ipd.[Closure Date],
		   temp.invoice_date,
		   ipd.HN,
		   ipd.[Patient Name],
		   temp.policy,
		   temp.main_group_code,
		   temp.main_group_name,
		   temp.gross_amount,
		   temp.discount_amount,
		   temp.main_gl_code,
		   temp.main_gl_name,
		   temp.gl_acct_code,
		   temp.gl_acct_name

	from 
	(
		select DISTINCT
			   cd.charge_detail_id,
			   ar.ar_invoice_id,
			   ard.ar_invoice_detail_id,
			   cd.caregiver_employee_id,
			   pv.patient_visit_id,
			   pv.actual_visit_date_time as visit_start,
			   ar.transaction_date_time as invoice_date,
			   phu.visible_patient_id as hospital_nr,
			   pfn.display_name_l as patient_name,
			   --ar.policy_id,
			   isnull(p.name_l, 'Self Pay') as policy,
			   main_group_code = (Select item_group_code from item_group where item_group_id = ig.parent_item_group_id),
			   main_group_name = (Select name_l from item_group where item_group_id = ig.parent_item_group_id),
			   ard.gross_amount,
			   ard.discount_amount,
			   gac2.gl_acct_code_code as main_gl_code,
			   gac2.name_l as main_gl_name,
			   gac.gl_acct_code_code as gl_acct_code,
			   gac.name_l as gl_acct_name
			   --ESV.employee_nr,
			   --specialty = isnull(ESV.parent_clinical_specialty_name_l, 'No Specialty')

		from AmalgaPROD.dbo.charge_detail cd 
						inner join AmalgaPROD.dbo.patient_visit pv on cd.patient_visit_id = pv.patient_visit_id
						inner join AmalgaPROD.dbo.ar_invoice_detail ard on cd.charge_detail_id = ard.charge_detail_id
						inner join AmalgaPROD.dbo.ar_invoice ar on ard.ar_invoice_id = ar.ar_invoice_id
						inner join gl_acct_code gac on cd.gl_acct_code_id = gac.gl_acct_code_id
						inner join gl_acct_code gac2 on gac2.gl_acct_code_id = gac.parent_acct_code_id
						inner join item i on ard.item_id = i.item_id 
						inner join item_group ig on i.item_group_id = ig.item_group_id
						left join policy p on ar.policy_id = p.policy_id
						inner join patient_hospital_usage phu on pv.patient_id = phu.patient_id
						inner join person_formatted_name_iview pfn on phu.patient_id = pfn.person_id
						--left join AmalgaPROD.dbo.api_employee_specialty_view ESV on cd.caregiver_employee_id = esv.employee_id

		where cd.deleted_date_time is null
			  and pv.cancelled_date_time is null
			  and ar.system_transaction_type_rcd IN ('INVR')
			  and ar.transaction_status_rcd NOT IN ('VOI', 'UNK')
			  and pv.visit_type_rcd in ('V1', 'V2')
			  and ard.item_id NOT IN (SELECT item_id FROM AmalgaPROD.dbo.item_nl_view WHERE item_code like 'S23%') 
			  and ard.item_id NOT IN (SELECT item_id FROM AmalgaPROD.dbo.item_nl_view WHERE sub_item_type_rcd = 'DRFEE')
			  --and pv.patient_visit_id = 'B086E6CD-7318-11E9-BF57-5065F31C4CB0'
			  --and year(ar.transaction_date_time) = 2019
			  --and month(ar.transaction_date_time) = 1


	)as temp
	left join AHMC_DataAnalyticsDB.dbo.ipd_census_1 ipd on ipd.patient_visit_id = temp.patient_visit_id

)as tempb
where year(tempb.invoice_date) = 2018
      and month(tempb.invoice_date) = 1
	  --and tempb.HN = '00570264'
	  --and tempb.main_group_code = '010'
	  and tempb.gross_amount <> 0

group by tempb.patient_visit_id,
         tempb.[Visit Start],
		 tempb.[Closure Date],
		 tempb.invoice_date,
		 tempb.HN,
		 tempb.[Patient Name],
		 tempb.policy,
		 tempb.main_group_code,
		 tempb.main_group_name,
		 tempb.main_gl_code,
		 tempb.main_gl_name,
		 tempb.gl_acct_code,
		 tempb.gl_acct_name

order by tempb.[Visit Start],
         tempb.invoice_date,
		 tempb.policy,
		 tempb.main_group_name
