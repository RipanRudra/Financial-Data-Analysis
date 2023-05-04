USE Calender_Db
GO
--What is the total revenue for 2021?
select 
SUM(Revenue) as total_revenue
from [Revenue Raw Data] 
where Month_ID in (select distinct Month_ID from ipi_Calendar_lookup where Fiscal_Year= 'fy21')



--what is the total revenue performance YoY?
SELECT	A.total_revenue_Fy21
	, B.total_revenue_Fy20
	, A.total_revenue_Fy21 - B.total_revenue_Fy20 AS Dollar_Diff_YoY
	, a.total_revenue_Fy21/b.total_revenue_Fy20   as Perc_diff_YoY
FROM 	
	(select 
	SUM(Revenue) as total_revenue_Fy21
	from [Revenue Raw Data] 
	where Month_ID in 
	(
	select distinct Month_ID from ipi_Calendar_lookup where Fiscal_Year= 'fy21')
	)  a,

	(select 
	SUM(Revenue) as total_revenue_Fy20
	from [Revenue Raw Data] 
	where Month_ID in
	(
	select distinct month_id -12 from [Revenue Raw Data] where month_ID in 
	(select distinct Month_ID from ipi_Calendar_lookup where Fiscal_Year= 'fy21'))
	) b


--What is the MoM Revenue Performance?
select a.Total_Revenue_TM
	, b.total_revenue_PM
	, a.Total_Revenue_TM -b.total_revenue_PM as Dollar_Diff_MoM
	, a.Total_Revenue_TM/b.total_revenue_PM  as Per_Diff_MoM
From
		(select 
		SUM(Revenue) as Total_Revenue_TM
		from [Revenue Raw Data] 
		where Month_ID in (select Max(Month_ID) FROM [Revenue Raw Data] )
		) a,


		(select 
		SUM(Revenue) as total_revenue_PM
		from [Revenue Raw Data] 
		where Month_ID in (SELECT MAX(Month_ID) -1 FROM [Revenue Raw Data] )
		) b

--What is the total revenue vs Target?
select a.total_revenue_Fy21, b.target_Fy21,  a.total_revenue_Fy21 - b.target_Fy21 as Revenue_Vs_Target_Diff, a.total_revenue_Fy21 / b.target_Fy21 -1 as Perc_diff
from
	(select 
	SUM(Revenue) as total_revenue_Fy21
	from [Revenue Raw Data] 
	where Month_ID in (select distinct Month_ID from ipi_Calendar_lookup where Fiscal_Year= 'fy21')) a,

	(select SUM(Target) as target_Fy21
	from [Targets Raw Data]
	where Month_ID in (select distinct Month_ID from [Revenue Raw Data] 
					where month_id in (select distinct Month_ID from ipi_Calendar_lookup where Fiscal_Year= 'fy21'))) b;


--What is the Revenue vs Target performance Per Month?

select a.month_id
	, c.Fiscal_Month
	, a.total_revenue_Fy21, b.target_Fy21
	,  a.total_revenue_Fy21 - b.target_Fy21 as Revenue_Vs_Target_Diff
	, a.total_revenue_Fy21 / b.target_Fy21 -1 as Perc_diff
from
	(select month_id,
	SUM(Revenue) as total_revenue_Fy21
	from [Revenue Raw Data] 
	where Month_ID in (select distinct Month_ID from ipi_Calendar_lookup where Fiscal_Year= 'fy21') GROUP BY Month_ID) a

	left join

	(select month_id, SUM(Target) as target_Fy21
	from [Targets Raw Data]
	where Month_ID in (
	select distinct Month_ID from [Revenue Raw Data] where month_id in 
	(
	select distinct Month_ID from ipi_Calendar_lookup where Fiscal_Year= 'fy21'
	))
	group by Month_ID
	) b
	ON A.Month_ID = B.Month_ID
	
	left join 

	(select distinct month_id, fiscal_month from [dbo].[ipi_Calendar_lookup]) c
	on a.Month_ID = c.Month_ID

	ORDER BY a.Month_ID, c.Fiscal_Month

	--What is the best performing product in terms of revenue this year?

	SELECT Top 1 Product_Category, SUM(Revenue) AS Revenue_Fy21
	FROM [Revenue Raw Data]
	WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM ipi_Calendar_lookup WHERE Fiscal_Year = 'FY21')
	group by Product_Category
	order by Revenue_Fy21  desc

	--what is the product performance vs target this month?

	select a.Month_ID, a.RevenueTM, a.Product_Category, b. TargetTM, a.RevenueTM - b.TargetTM as Dollar_diff_TM, RevenueTM/TargetTM -1 as diff
	from

		(SELECT month_ID, Product_Category, SUM(Revenue) AS RevenueTM
		FROM [Revenue Raw Data]
		WHERE Month_ID IN (SELECT Max(Month_ID) FROM [Revenue Raw Data])
		group by Product_Category, Month_ID
		) a
	
		left JOIN

		(Select month_id, Product_Category, sum(Target) as TargetTM
		from [Targets Raw Data]
		where Month_ID in (select max(month_id) from [Revenue Raw Data])
		group by Month_ID, Product_Category
		) b
	
	ON a.month_id = b.month_id and a.Product_Category =b.Product_Category
	order by RevenueTM, TargetTM
	
	
--Which accout is performing the best in terms of revenue?

Select al.New_Account_Name, rd.Account_No, sum(rd.Revenue) as total_revenue
from [Revenue Raw Data] rd
left join [dbo].[ipi_account_lookup] al on al.New_Account_No = rd.Account_No
group by rd.Account_No, al.New_Account_Name
order by total_revenue desc



