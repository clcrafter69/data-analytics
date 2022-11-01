select count(*) from public."SA_entry_data"


select count(*) from public."SA_signup_data"



/**Question 1:** Total Entry Amount for all members who signed up in September 2020*/
select sum("e"."Entry_Amount") as "Total Amount"
from public."SA_signup_data" as s
join public."SA_entry_data" e
on "s"."User_ID" ="e"."User_ID"
where date_trunc('month',"s"."Reg_Date") ='2020-09-01'

select *
from public."SA_signup_data" as s
join public."SA_entry_data" e
on "s"."User_ID" ="e"."User_ID"
where date_trunc('month',"s"."Reg_Date") ='2020-09-01'






/**********************Question 2*******************/

/*****select all entries from September**/
select "s"."User_ID",avg("s"."Entry_Amount") as "Avg User Amount By Day",to_char("s"."Entry_Date", 'Day') as "Day Name"
from public."SA_entry_data" as s
where date_trunc('month',"s"."Entry_Date") ='2020-09-01'
group by "s"."User_ID", "Day Name"


/**********************Question 3*******************************/

select sum("s"."Entry_Amount"),"s"."Player","s"."League"
from public."SA_entry_data" as s
where date_trunc('month',"s"."Entry_Date") ='2020-09-01'
group by "s"."Player","s"."League"
order by  sum("s"."Entry_Amount") desc
limit 5


/************************Question 4****************************/
with
cte_player 
as (
select sum("s"."Entry_Amount") as total_player_amount, count("s"."Entry_Amount"), "s"."Player"
from public."SA_entry_data" as s
group by  "s"."Player"
),

cte_user 
as (
select sum("s"."Entry_Amount") as total_user_amount,  "s"."User_ID", "s"."Player", count("s"."Entry_Amount")
from public."SA_entry_data" as s
    where "s"."Entry_Amount" <> 0
group by  "s"."Player", "s"."User_ID"
order by "s"."Player", "s"."User_ID" 
)
select "p"."Player","u"."User_ID", (total_user_amount/total_player_amount) *100 as user_share
from cte_player p
 join cte_user u
on "p"."Player" = "u"."Player"
order by "p"."Player" asc,"user_share" desc
