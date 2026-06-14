# 🔧 AWS Employee ETL Pipeline — S3 → Glue → Athena

## Architecture
```
Source S3 Bucket
        ↓  Upload CSV
S3 Event Notification (PUT)
        ↓  Auto triggers
AWS Lambda (trigger-glue-on-upload)
        ↓  Starts ETL job
AWS Glue PySpark ETL Job
        ↓  Clean + Transform
Target S3 Bucket (Parquet/CSV)
        ↓  Query
Amazon Athena SQL
```

## What This Pipeline Does
- HR uploads employee CSV to source S3 bucket
- S3 event automatically triggers Lambda (zero manual steps)
- Lambda starts Glue PySpark ETL job with dynamic file path
- Glue cleans: duplicates, nulls, salary formatting, name cleaning
- Clean data written to target S3
- Athena queries clean data with SQL

## AWS Services Used
| Service | Purpose |
|---|---|
| Amazon S3 | Raw data landing zone + clean output |
| AWS Lambda | Auto-trigger on file upload |
| AWS Glue | PySpark ETL processing |
| Amazon Athena | SQL analytics on clean data |
| CloudWatch | Monitoring + logging |
| AWS IAM | Secure role-based access |

## PySpark Cleaning Logic
```python
# Remove duplicates
df = df.dropDuplicates()

# Remove nulls
df = df.na.drop()

# Clean name - remove special characters
df = df.withColumn("name",
    initcap(trim(regexp_replace(col("name"), "[^A-Za-z ]", ""))))

# Clean salary - remove Rs. INR symbols
df = df.withColumn("salary",
    regexp_replace(col("salary"), "[^0-9]", ""))
df = df.withColumn("salary", col("salary").cast(IntegerType()))

# Write as Parquet to target S3
df.write.mode("overwrite").parquet(output_path)
```

## Files
| File | Description |
|---|---|
| `lambda_function.py` | Lambda trigger code |
| `glue_etl_job.py` | Full PySpark cleaning script |
| `athena_queries.sql` | Verification SQL queries |
| `sample_data/unclean_employees.csv` | Sample dirty data |

## Author
**Barathwaj K G** | AWS Data Engineer  
[LinkedIn](https://linkedin.com/in/barathwaj-kg)
