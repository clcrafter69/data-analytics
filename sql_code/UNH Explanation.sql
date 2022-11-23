
/*Step 1:  Determine how many policyholders made 3 or more calls
	Count the number of policyholders that fit this criteria using COUNT(),group by policy_holder_id
	Filter using the HAVING keyword (WHERE cannot filter aggregate rows)
	
  Step 2: Wrap in a CTE
	The query can be a subquery but I prefer CTEs because they are much easier to read
	
  Step 3  Count the number of policyholders:
	Now that the data has been filtered with the requested criteria, simply select a count of the rows 
	from the CTE call_count.
	*/



WITH call_count AS (
  SELECT 
    policy_holder_id, 
    Count(case_id) AS policy_count 
  FROM 
    callers 
  GROUP BY 
    policy_holder_id 
  HAVING 
    Count(policy_holder_id) >= 3
) 
SELECT 
  Count(policy_holder_id) 
FROM 
  call_count;
  
  
  /******************************************************************************************************/
  
/* a test of my subquery before placing in CTE*/

 /* SELECT policy_holder_id,count(case_id) as policy_count
 FROM callers
 group by policy_holder_id
 HAVING count(policy_holder_id) >=3 */
