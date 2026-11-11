-- Databricks notebook source
-- MAGIC %python
-- MAGIC fileroot = "clinicaltrial_2021"

-- COMMAND ----------

-- MAGIC %python
-- MAGIC Clinicaltrial1 = spark.read.csv("/FileStore/tables/" + fileroot + ".csv", header=True,sep="|")
-- MAGIC Clinicaltrial1.display(100) #I used this commamd to explore the file to work with and how to approach it.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC #Created a temp SQL file to query
-- MAGIC Clinicaltrial1 . createOrReplaceTempView ("sqlClinicaltrial")

-- COMMAND ----------

-- Count the numbers of studies----

SELECT COUNT(*) as numbers_Of_studies FROM sqlClinicaltrial

-- COMMAND ----------

/* Grouping by type along with the frequencies of each type */
SELECT Type, COUNT(*) AS frequency
FROM sqlClinicaltrial
GROUP BY Type
ORDER BY frequency DESC;


-- COMMAND ----------

--I decided to split the condition column because it has arrays seperated with comma
SELECT SPLIT(Conditions, ',') as Splitted_Conditions
FROM sqlClinicaltrial
WHERE Conditions != ''

-- COMMAND ----------

--I explooded the splited _condition column
SELECT exploded_conditions as Splitted_Conditions, count(*) as count
FROM (
  SELECT explode(split(Conditions, ',')) as exploded_conditions
  FROM sqlClinicaltrial WHERE Conditions != ''
) t
GROUP BY exploded_conditions
ORDER BY count DESC

-- COMMAND ----------

-- MAGIC %python
-- MAGIC fileroot2 = "pharma"
-- MAGIC import os
-- MAGIC os.environ ['fileroot2'] = fileroot2

-- COMMAND ----------

-- MAGIC %python
-- MAGIC #I created a schema that only load the parent_company colum as that is the only colum needed.
-- MAGIC from pyspark.sql.types import *
-- MAGIC 
-- MAGIC myPharmaSchema = StructType([
-- MAGIC     StructField("Parent_company", StringType()),
-- MAGIC   StructField("field34", StringType())])

-- COMMAND ----------

-- MAGIC %python
-- MAGIC Pharma_df = spark.read.csv("/FileStore/tables/"+fileroot2 +".csv", header=True, schema=myPharmaSchema)
-- MAGIC #created an SQL temp view for the pharma file
-- MAGIC Pharma_df . createOrReplaceTempView ("sqlPharma")

-- COMMAND ----------

/* Sponsors with numbers of clinical trial */

Select Sponsor, count(*) as Number_of_clinical_trials
from sqlClinicaltrial
Where Sponsor Not in (Select Parent_company from sqlPharma)
Group By Sponsor
Order By Number_of_clinical_trials DESC;

-- COMMAND ----------

--Numbers of trials complete in 2021
SELECT 
   Completion, Count (*)
FROM 
    sqlClinicaltrial
WHERE
    status = 'Completed'
    AND Completion IS NOT NULL 
    AND Completion LIKE '%2021'
GROUP BY 
    Completion
    ORDER BY
    TO_DATE(Completion, 'MMM yyyy')
--     MONTH(TO_DATE(Completion, 'MMM-yyyy'))


-- COMMAND ----------

--Numbers of trials completed in 2021 to show Visualization
SELECT 
   Completion, Count (*)
FROM 
    sqlClinicaltrial
WHERE
    status = 'Completed'
    AND Completion IS NOT NULL 
    AND Completion LIKE '%2021'
GROUP BY 
    Completion
    ORDER BY
    TO_DATE(Completion, 'MMM yyyy')
--     MONTH(TO_DATE(Completion, 'MMM-yyyy'))

-- COMMAND ----------

--Total numbers of studies terminated in 2021 and their sponsors
SELECT Sponsor, COUNT(*) AS terminated_trial_count
FROM sqlClinicaltrial
WHERE Status = 'Terminated' AND Completion LIKE '%2021'
GROUP BY Sponsor
ORDER BY terminated_trial_count DESC;
