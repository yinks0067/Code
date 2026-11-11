# MSc Data Science Coursework

These are three projects I built during my MSc in Data Science at the University of Salford (Distinction). One uses Spark on Databricks to analyse a large dataset, and two are relational database projects in SQL Server. My predictive maintenance project from the same course now has [its own repo](https://github.com/yinks0067/predictive-maintenance-spark-ml).

They're not polished products. They're the work where I learned to explore data I hadn't seen before, ask it useful questions, and back each answer with a query or a model I could explain.

| Project | File | Tools |
| --- | --- | --- |
| Clinical trials analysis | `Clinical trials_df.ipynb` and `Clinical trials analysis.sql` | PySpark, Spark SQL, Databricks |
| Library database | `Database development for a library..sql` | SQL Server (T-SQL) |
| NHS prescriptions database | `PrescriptionsDB Queries .sql` | SQL Server (T-SQL) |

---

## 1. Clinical trials analysis

**The question:** what does the 2021 clinical trials dataset tell us about the kinds of studies being run, what they focus on, and who runs them?

I answered the same set of questions twice: once with PySpark DataFrames (`Clinical trials_df.ipynb`) and once with Spark SQL (`Clinical trials analysis.sql`). Doing both helped me see when each approach is the more natural fit.

**What I found**

- The dataset holds **387,261 studies**
- Most are **interventional** (301,472), followed by observational (77,540)
- The most common conditions are carcinoma (13,389 studies), diabetes mellitus (11,080) and neoplasms (9,371). The conditions column held several values in one cell, so I split and expanded it before counting.
- The busiest sponsors include GlaxoSmithKline, the National Cancer Institute, AstraZeneca and Pfizer. In the SQL version I also filtered out the big pharmaceutical parent companies to see which other organisations run the most trials.
- I counted how many trials finished each month of 2021 and plotted it as a bar chart
- I listed the sponsors with the most trials terminated in 2021, led by Johns Hopkins University

**What I took from it:** real data is messy. Columns with lists inside them, dates stored as text like "Nov 2021", and inconsistent sponsor names all needed handling before any count could be trusted.

---

## 2. Library database

**The brief:** design a database for a library that tracks members, the items they borrow, loans, overdue fines and repayments.

**What I built (T-SQL)**

- **Tables** for members, items, item types, item status, loans, loan status, repayments and repayment methods, with primary keys, foreign keys and checks (for example, a membership can't end before it starts)
- **Stored procedures** to search the catalogue by title, add a new member and update a member's details
- **A function** that lists items on loan that are due back within five days
- **A view** of each member's loan history
- **A trigger** that marks an item as available again as soon as its return date is recorded
- Sample data and test queries to check that each part works

**What I took from it:** putting rules in the database itself, with constraints, procedures and triggers, keeps the data correct no matter which app or person is using it.

---

## 3. NHS prescriptions database

**The brief:** load three tables of NHS prescribing data (drugs, prescriptions and GP practices), link them properly and answer questions about prescribing.

**What I did (T-SQL)**

- Created the database and added primary and foreign keys to link prescriptions to drugs and to practices
- Wrote queries to:
  - find all drugs that come as tablets or capsules
  - work out the total quantity for each prescription
  - compare the number of prescriptions and the average, lowest and highest cost for each BNF chapter
  - find the most expensive prescriptions by practice
  - rank the five practices prescribing the largest quantities
  - find which practices prescribed Gaviscon
  - count the GP practices in each postcode

**What I took from it:** the hard part of SQL isn't the syntax. It's getting the joins and keys right so the numbers actually mean what you think they mean.

---

## About me

I'm Yinka, an AI Solutions Engineer in Manchester. These days I build AI products end to end: discovery, design and the build itself. You can see my current work on my [GitHub profile](https://github.com/yinks0067) or find me on [LinkedIn](https://www.linkedin.com/in/yinka-sunmola/).
