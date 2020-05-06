declare @company_code varchar(3)
DECLARE @From datetime
DECLARE @To datetime

set @company_code = 'AHI'
SET @From = '01/01/2019 00:00:00.000'		
SET @To = '12/31/2019 23:59:59.998'

--GJV
select temp.patient_visit_id,
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
		[Gross Amount] = temp.[Credit Amount] - temp.[Debit Amount],
		temp.ar_invoice_detail_id

from  (

	select 		
				vtr.visit_type_group_rcd as [Visit Type Group]
				,gac.gl_acct_code_code as [GL Account Code]
				,gac.name_l as [GL Account Name]
				,gac2.gl_acct_code_code as main_gl_code
				,gac2.name_l as main_gl_name
			    ,case when cd.patient_visit_id is null then (Select distinct _cd.patient_visit_id from charge_detail _cd
																inner join ar_invoice_detail _ard on _cd.charge_detail_id = _ard.charge_detail_id
																inner join ar_invoice _ar on _ar.ar_invoice_id = _ard.ar_invoice_id
														where _ar.ar_invoice_id = ar.related_ar_invoice_id) 
				 else cd.patient_visit_id end as patient_visit_id
				,ISNULL(p.name_l, 'Self Pay') as Policy
				,ar.transaction_date_time as [Invoice Date]
				,gt.transaction_text as [PAR]
				,ar.transaction_text as [Invoice Number]
				,isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice]
				,isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date]
				,c.costcentre_code as [Costcentre Code]
				,c.name_l as [Costcentre]
				,[Debit Amount] = case when debit_flag = 1 then gtd.amount else '-' end
				,[Credit Amount] = case when debit_flag = 0 then gtd.amount else '-' end
				,ard.ar_invoice_detail_id
				,gt.effective_date as [Effective Date]


	from		gl_transaction_nl_view gt
	inner join gl_transaction_detail_nl_view gtd on gtd.gl_transaction_id = gt.gl_transaction_id 
	inner JOIN costcentre c on gtd.costcentre_id = c.costcentre_id
	inner join gl_acct_code_nl_view gac on gac.gl_acct_code_id = gtd.gl_acct_code_id
	inner join gl_acct_code gac2 on gac2.gl_acct_code_id = gac.parent_acct_code_id
	inner JOIN visit_type_ref vtr on gtd.visit_type_rcd = vtr.visit_type_rcd
	left JOIN ar_invoice_nl_view ar on gt.gl_transaction_id = ar.gl_transaction_id
	left JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
	LEFT JOIN charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
	LEFT JOIN policy p on ar.policy_id = p.policy_id

	where CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
	    and CAST(CONVERT(VARCHAR(10),gt.effective_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
		and	gt.company_code = @company_code
		and	gt.transaction_status_rcd = 'POS'
		and gt.user_transaction_type_id = '8566FA00-63FE-11DA-BB34-000E0C7F3ED2'    --GJV


) as temp
where  main_gl_code in ('41', '42')
		and temp.[GL Account Code] not in ('4219000')   --Other Revenue
