declare @company_code varchar(3)
DECLARE @From datetime
DECLARE @To datetime

set @company_code = 'AHI'
SET @From = '01/01/2019 00:00:00.000'		
SET @To = '12/31/2019 23:59:59.998'

select  distinct 
	temp.patient_visit_id,
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
	temp.ar_invoice_detail_id

from (

	SELECT  
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
			,ISNULL(po.name_l, 'Self Pay') as Policy
			,ar.transaction_date_time as [Invoice Date]
			,glt.transaction_text as [PAR]
			,ar.transaction_text as [Invoice Number]
			,isnull((select transaction_text from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice]
			,isnull((select transaction_date_time from ar_invoice where ar_invoice_id = ar.related_ar_invoice_id),'') as [Related Invoice Date]
			,c.costcentre_code as [Costcentre Code]
			,c.name_l as [Costcentre]
			,ard.gross_amount * ar.credit_factor as [Gross Amount]
			,ard.ar_invoice_detail_id
			,glt.effective_date as [Effective Date]

	from gl_transaction glt inner JOIN ar_invoice_nl_view ar on glt.gl_transaction_id = ar.gl_transaction_id
							inner JOIN ar_invoice_detail ard on ar.ar_invoice_id = ard.ar_invoice_id
							inner JOIN costcentre c on ard.costcentre_credit_id = c.costcentre_id
							inner JOIN gl_acct_code gac on ard.gl_acct_code_credit_id = gac.gl_acct_code_id
							inner join gl_acct_code gac2 on gac2.gl_acct_code_id = gac.parent_acct_code_id
							LEFT JOIN charge_detail cd on ard.charge_detail_id = cd.charge_detail_id
							LEFT JOIN policy po on ar.policy_id = po.policy_id
							inner JOIN visit_type_ref vtr on ar.visit_type_rcd = vtr.visit_type_rcd

	where CAST(CONVERT(VARCHAR(10),glt.effective_date,101) as SMALLDATETIME) >= CAST(CONVERT(VARCHAR(10),@From,101) as SMALLDATETIME)
	        and CAST(CONVERT(VARCHAR(10),glt.effective_date,101) as SMALLDATETIME) <= CAST(CONVERT(VARCHAR(10),@To,101) as SMALLDATETIME)
			and ar.transaction_status_rcd not in ('unk','voi')
			and cd.deleted_date_time is null
			and glt.company_code = @company_code
			and glt.transaction_status_rcd = 'POS'
)as temp
where 
		temp.main_gl_code in ('41', '42')
		and temp.[GL Account Code] not in ('4219000')   --Other Revenue
		and temp.[Gross Amount] <> 0