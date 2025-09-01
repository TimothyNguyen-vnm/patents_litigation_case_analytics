# Patent Litigation Analytics Project  

## Overview  
This project demonstrates an **economics consulting workflow** using **SQL, Python, and Stata**. It leverages the USPTO patent litigation dataset (74k+ cases, 5M+ documents) to construct a litigation master dataset and analyze the economic drivers of litigation outcomes.  

The project is structured like a **real consulting engagement**, moving from raw data to actionable insights:  
1. **SQL** – Data integration, cleaning, and construction of a case-level litigation master table.  
2. **Python** – Exploratory data analysis, visualization of trends, and descriptive statistics.  
3. **Stata** – Econometric modeling (settlement probability, case duration, survival analysis).  

---

## Dataset  

This project uses the **Patent Litigations dataset** from the **USPTO Office of the Chief Economist** (via Kaggle).  

- **Scope**: Over **74,000 cases** spanning **1963–2015**, covering more than **5 million documents**.  
- **Files**:  
  - `cases.csv` – Case-level metadata  
  - `pacer_cases.csv` – Court and jurisdiction details  
  - `names.csv` – Litigating parties (plaintiffs, defendants, counter-parties, third-parties)  
  - `attorneys.csv` – Attorneys and law firms involved  
  - `documents.csv` – Filings, judgments, settlements, and procedural history  
- **Source**: Collected from **PACER** (Public Access to Court Electronic Records) and **RECAP**.  
- **License**: Public Domain Mark 1.0  

### Why It Matters  
Patent litigation sits at the intersection of **intellectual property law** and **economic growth**. By analyzing litigation outcomes, case duration, and repeat litigants, we can inform:  
- Corporate litigation strategy (likelihood of settlement vs. trial)  
- Antitrust and policy evaluation (efficiency of courts, industry-level trends)  
- Judicial resource allocation and regulatory reform  

---

## Methods  

### 🔹 SQL – Data Engineering  
- Joined `cases`, `pacer_cases`, `names`, `attorneys`, and `documents` into a **litigation master** table.  
- Created outcome variables (`Settlement`, `Dismissed`, `Judgment`, `Ongoing`).  
- Engineered features: number of plaintiffs/defendants, repeat litigants, attorney counts, case duration.  
- Cleaned null values for export into analysis software.  

### 🔹 Python – Data Analytics  
- Exploratory Data Analysis (EDA) with Pandas & Matplotlib.  
- Visualized litigation trends by year, court, and outcome.  
- Benchmarked courts and jurisdictions by case load and settlement rates.  
- Identified top repeat litigants and high-volume law firms.  

### 🔹 Stata – Econometrics  
- **Logit model** of settlement probability as a function of case complexity and jurisdiction.  
- **OLS regression** on (log) case duration to test drivers of litigation length.  
- **Survival analysis (Cox proportional hazard)** to estimate time-to-settlement.  
- Computed marginal effects and policy-relevant estimates.  

---

## Results (Example Insights)  
- **Settlement Likelihood**: Multi-defendant cases are less likely to settle, while certain jurisdictions encourage early settlement.  
- **Case Duration**: Duration rises sharply with the number of litigants and attorneys involved.  
- **Survival Curves**: Courts vary systematically in time-to-settlement, suggesting differences in judicial efficiency.  
- **Repeat Litigants**: Firms involved in 5+ cases behave strategically, resisting settlement more often.  

---

## Skills Demonstrated  
- **SQL**: Relational joins, data cleaning, feature engineering.  
- **Python**: Data wrangling, visualization, exploratory analytics.  
- **Stata**: Applied econometrics, regression analysis, survival modeling, marginal effects.  
- **Consulting**: Structuring a project as a case study, translating data into economic insights.  

---

## Project Structure  
/sql        -- SQL scripts for data integration & feature engineering
/python     -- Python notebooks for EDA & visualization
/stata      -- Stata do-files for econometric modeling
/outputs    -- Clean datasets, tables, figures, regression results

---

## License  
Dataset: **Public Domain (USPTO Office of the Chief Economist)**  
Project code: MIT License  

---

✨ This project is designed to showcase **consulting-style economics analysis** with a full stack of **SQL, Python, and Stata** tools.  
