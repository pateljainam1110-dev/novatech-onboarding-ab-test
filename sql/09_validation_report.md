# NovaTech SQL Validation Report

## Validation status

The SQL logic was checked against the actual NovaTech CSV dataset used in the Python analysis.

The raw dataset contains intentional data-quality issues:
- `users.csv`: 100,100 rows, including 100 exact duplicate rows.
- `experiments.csv`: 100,000 rows, including 50 assignment records before signup.
- `events.csv`: 432,790 rows, including 250 duplicate event rows.
- `transactions.csv`: 8,360 rows, including 75 missing amounts.

The SQL workflow therefore uses raw staging tables first, audits the raw data, then creates clean analysis tables.

## Expected cleaned row counts

| Table | Expected rows |
|---|---:|
| users_clean | 100,000 |
| experiments_clean | 99,950 |
| events_clean | 432,540 |
| transactions_clean | 8,360 |

## Cross-checks against Python

### Primary 7-day activation

| Group | Users | Activated | Rate |
|---|---:|---:|---:|
| Control | 49,963 | 16,710 | 33.44% |
| Treatment | 49,987 | 19,181 | 38.37% |

Expected treatment lift: **+4.93 percentage points**.

### Retention

| Metric | Control | Treatment |
|---|---:|---:|
| D1 | 9.12% | 10.47% |
| D7 | 15.76% | 17.96% |
| D30 | 1.11% | 1.24% |

Expected lifts:
- D1: **+1.35 pp**
- D7: **+2.20 pp**
- D30: **+0.12 pp**

### Monetization

Expected successful paid users:
- Control: **3,574**
- Treatment: **4,285**

Expected revenue:
- Control: **$2,383,888.30**
- Treatment: **$2,821,453.82**

Expected revenue per experiment user:
- Control: **$47.71**
- Treatment: **$56.44**

## Important reproducibility note

The SQL files are written for **MySQL 8.x** and use functions such as `DATE_ADD`, `LOWER`, `COALESCE`, `NULLIF`, CTEs, and standard aggregation syntax.

The SQL logic was cross-checked against the actual dataset and the previously completed Python analysis. Because this package is generated outside the user's local MySQL server, final execution should still be performed in the user's own MySQL Workbench after importing the raw CSVs. The expected-result tables above provide a direct validation target.
