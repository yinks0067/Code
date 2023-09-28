
--Create a database importig the 3 CSV tables from database---

Create Database PrescriptionsDB

ALTER TABLE Prescriptions
ADD FOREIGN KEY (BNF_CODE) REFERENCES Drugs(BNF_CODE);


ALTER TABLE Medical_Practice
ADD CONSTRAINT PK_Medical_Practice PRIMARY KEY (PRACTICE_CODE);

ALTER TABLE Medical_Practice 
ALTER COLUMN PRACTICE_CODE Varchar(100) NOT NULL;

ALTER TABLE Prescriptions
ALTER COLUMN PRACTICE_CODE Varchar(100);

ALTER TABLE Prescriptions
ADD FOREIGN KEY (PRACTICE_CODE) REFERENCES Medical_Practice(PRACTICE_CODE);

----
USE PrescriptionsDB;
GO


--Create a view tht returns all drugs in form of Capsule or Tablets

SELECT *
FROM Drugs
WHERE BNF_DESCRIPTION LIKE '%tablet%' OR BNF_DESCRIPTION LIKE '%capsule%'



---Write a query that returns total quantity for each prescription----

SELECT PRESCRIPTION_CODE,
 ROUND(QUANTITY*ITEMS,0)  AS  Total_Prescription_Quantity
FROM Prescriptions;



---Write a query that give dinstict chemical substance----

SELECT DISTINCT CHEMICAL_SUBSTANCE_BNF_DESCR
FROM Drugs

-------Prescription for each BNF_Chapter_plus_code------

SELECT 
    BNF_CHAPTER_PLUS_CODE, 
    COUNT(*) AS prescriptions_number, 
    AVG(ACTUAL_COST) AS Average_cost, 
    MIN(ACTUAL_COST) AS minimum_cost, 
    MAX(ACTUAL_COST) AS maximum_cost
FROM Drugs dr LEFT JOIN Prescriptions ps
on dr.BNF_CODE= ps.BNF_CODE
GROUP BY BNF_CHAPTER_PLUS_CODE;


----Write a command query  to return the most expensive prescription----

Select gp.PRACTICE_NAME, ac.PRESCRIPTION_CODE, ac.ACTUAL_COST
FROM PRESCRIPTIONS ac 
JOIN Medical_Practice gp ON gp.PRACTICE_CODE = gp.PRACTICE_CODE
Where ac.ACTUAL_COST > 4000
and ac.ACTUAL_COST = (SELECT Max(ACTUAL_COST)
FROM PRESCRIPTIONS
WHERE PRACTICE_CODE = gp.PRACTICE_CODE)
ORDER BY ACTUAL_COST DESC



------- Top medical_practise with highest prescription Quantity--------

SELECT TOP 5 p.PRACTICE_CODE, mp.PRACTICE_NAME, SUM(p.QUANTITY) AS total_quantity
FROM Prescriptions p
JOIN dbo.Medical_Practice mp ON p.PRACTICE_CODE = mp.PRACTICE_CODE
GROUP BY p.PRACTICE_CODE, mp.PRACTICE_NAME
ORDER BY total_quantity DESC;


----A Count of Total Medical Substance Dispensed across NHS Monthly----------- 

SELECT  CHEMICAL_SUBSTANCE_BNF_DESCR, COUNT(BNF_DESCRIPTION) AS Drug_Prescribed_Monthly
FROM Drugs
GROUP BY CHEMICAL_SUBSTANCE_BNF_DESCR
ORDER BY Drug_Prescribed_Monthly DESC;

----Selection of BNF_CODEs is length s more than 10 characters------

SELECT BNF_CODE
FROM Prescriptions
WHERE LEN(BNF_CODE) >= 10;


-------Check for a particular medical practise name  that prescribed Gaviscon----

SELECT Practice_Name
FROM Medical_Practice
WHERE EXISTS (
    SELECT *
    FROM Prescriptions
    INNER JOIN Drugs ON Prescriptions.BNF_CODE = Drugs.BNF_CODE
    WHERE Prescriptions.Practice_Code = Medical_Practice.Practice_Code
    AND Drugs.BNF_DESCRIPTION	LIKE '%GAVISCON%'
);


------- Count the total number of medical practice available within the NHS and group by post code--------

SELECT Postcode, COUNT(*) AS Total_Practices
FROM Medical_Practice
GROUP BY Postcode;





-------Conclusion--------------------
