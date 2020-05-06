declare @company_code varchar(3)

set @company_code = 'AHI'

select temp.[Transaction Number],
       temp.[Transaction DateTime],
	   temp.[Effective DateTime],
	   temp.[Account Code],
	   temp.[Account Name],
	   temp.[Cost Centre Code],
	   temp.[Cost Centre],
	   temp.[Debit Amount],
	   temp.[Credit Amount],
	   Movement = temp.[Credit Amount] - temp.[Debit Amount]

from  (

	select 		
		        gt.transaction_text as [Transaction Number],
				gt.transaction_date_time as [Transaction DateTime],
				gt.effective_date as [Effective DateTime],
				gac2.gl_acct_code_code as main_gl_code,
			    gac2.name_l as main_gl_name,
				gac.gl_acct_code_code as [Account Code],
				gac.name_l as [Account Name],
				cc.costcentre_code as [Cost Centre Code],
				cc.name_l as [Cost Centre],
				vtr.visit_type_group_rcd,
				[Debit Amount] = case when debit_flag = 1 then amount else '-' end,
				[Credit Amount] = case when debit_flag = 0 then amount else '-' end

	from		gl_transaction_nl_view gt
	inner join	gl_transaction_detail_nl_view gtd on gtd.gl_transaction_id = gt.gl_transaction_id 
	inner join	gl_acct_code_nl_view gac on gac.gl_acct_code_id = gtd.gl_acct_code_id
	inner join  gl_acct_code gac2 on gac2.gl_acct_code_id = gac.parent_acct_code_id
	inner join	costcentre_nl_view cc on cc.costcentre_id = gtd.costcentre_id
	inner JOIN visit_type_ref vtr on gtd.visit_type_rcd = vtr.visit_type_rcd

	where   MONTH(gt.effective_date) >= 1 and MONTH(gt.effective_date) <= 1
		and	Year(gt.effective_date) = 2019
		and	gt.company_code = @company_code
		and	gt.transaction_status_rcd = 'POS'

) as temp
where  main_gl_code in ('41', '42')
	   and temp.[Account Code] not in ('4219000')   --Other Revenue
		and temp.[Account Code] = '4110000'

order by temp.[Account Code]