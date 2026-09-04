# NovaTech — Product Feature Impact & A/B Testing

# Project Overview

NovaTech recently redesigned its digital product onboarding experience. The Product Team wanted to determine whether the new onboarding experience actually improved user activation, engagement, retention, and revenue.

An A/B experiment was conducted:

- Control: Existing onboarding experience
- Treatment: Redesigned onboarding experience

This project evaluates the experiment end-to-end using **Python, SQL, and Power BI**, translating user-level behavioral data into a product rollout recommendation.

---

# Business Problem

The key business question was:

> **Did the redesigned onboarding experience improve activation and downstream business outcomes compared with the existing experience?**

The analysis focused on:

- 7-day activation
- Onboarding funnel progression
- Feature adoption
- User engagement
- D1, D7 and D30 retention
- Paid conversion
- Revenue per user
- Revenue per paying user


# Experiment Design

| Group | Experience |
|---|---|
| Control | Existing onboarding |
| Treatment | Redesigned onboarding |

# Primary Metric

**7-Day Activation Rate**

A user is considered activated when they:

1. Complete onboarding, and
2. Perform at least one core product action within 7 days of signup.

---

# Key Results

| Metric | Control | Treatment | Impact |
|---|---:|---:|---:|
| 7-Day Activation | 33.44% | 38.37% | **+4.93 pp** |
| D1 Retention | 9.12% | 10.47% | **+1.35 pp** |
| D7 Retention | 15.76% | 17.96% | **+2.20 pp** |
| D30 Retention | 1.11% | 1.24% | +0.12 pp |
| Feature Adoption | 34.31% | 39.27% | **+4.96 pp** |
| Meaningful Actions/User | 1.105 | 1.269 | **+14.86%** |
| Paid Conversion | 7.15% | 8.57% | **+1.42 pp** |
| Revenue/User | $47.71 | $56.44 | **+18.30%** |
| Revenue/Paying User | $667.01 | $658.45 | -1.28% |

The primary activation result was statistically significant:

- **z = -16.24**
- **p < 0.001**
- 95% CI for Treatment − Control: **+4.33 to +5.52 pp**

---

# Key Insights

# 1. Activation improved significantly

The redesigned onboarding increased 7-day activation from **33.44% to 38.37%**, representing:

- **+4.93 percentage points**
- **+14.73% relative lift**

This indicates that the new onboarding successfully improves the transition from signup to meaningful product usage.

### 2. The onboarding funnel improved

Onboarding completion increased from:

**71.92% → 77.82%**

This suggests that the redesigned onboarding reduces friction early in the user journey.

### 3. Early retention improved

D1 and D7 retention both improved significantly.

However, D30 retention increased only slightly and was **not statistically significant**.

Therefore, the experiment should not be interpreted as evidence of a long-term retention improvement yet.

### 4. Engagement increased

Feature adoption increased by **+4.96 pp**, while meaningful actions per user increased by approximately **14.86%**.

Sessions per user remained approximately unchanged.

### 5. Business impact improved

Paid conversion increased by **+1.42 pp**, while revenue per user increased by **18.30%**.

Revenue per paying user decreased slightly by **1.28%**, suggesting that the revenue improvement is primarily driven by more users converting rather than higher spend per paying user.

---

# Estimated Business Impact

At a modeled scale of **100,000 users**:

- Approximately **4,927 additional activated users**
- Approximately **$873K incremental revenue**

These figures represent modeled incremental impact based on the observed treatment-control differences.

---

# Recommendation:-

# Controlled Phased Rollout:-

The redesigned onboarding should proceed to a **controlled phased rollout**.

The experiment shows strong evidence of improvement in:

- Activation
- Early retention
- Engagement
- Paid conversion
- Revenue per user

During rollout, continue monitoring:

- **D30 retention**
- **Revenue per paying user**

This allows NovaTech to capture the demonstrated gains while validating longer-term user and monetization behavior.

---

# Tools & Technologies

- **Python** — data cleaning, exploration and statistical analysis
- **SQL / MySQL** — data validation, segmentation, funnel, retention and business analysis
- **Power BI** — interactive dashboard and KPI reporting
- **Pandas / NumPy / SciPy** — analytical workflow and statistical testing

---

# Repository Structure

```text
novatech-onboarding-ab-test/
│
├── README.md
│
├── dataset/
│   ├── users.csv
│   ├── experiments.csv
│   ├── events.csv
│   ├── transactions.csv
│   └── data_dictionary.csv
│
├── sql/
│   ├── 00_create_database.sql
│   ├── 01_create_raw_tables.sql
│   ├── 02_data_validation.sql
│   ├── 03_create_clean_tables.sql
│   ├── 04_funnel_analysis.sql
│   ├── 05_user_segmentation.sql
│   ├── 06_retention_analysis.sql
│   ├── 07_experiment_analysis.sql
│   ├── 08_business_impact.sql
│   └── 09_validation_report.md
│
├── python/
│   ├── product_AB_cleaned.ipynb
│   └── product_AB_uncleaned.ipynb
│
├── powerbi/
│   └── NovaTech_AB_Test_Performance.pbix
│
└── dashboard/
    └── novatech_dashboard.png
