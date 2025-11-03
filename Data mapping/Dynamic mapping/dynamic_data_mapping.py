from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, lit
from pyspark.sql.window import Window
import pandas as pd

# 1️⃣ Initialize Spark Session
spark = SparkSession.builder.appName("AAA_ACE_LINA_Migration").getOrCreate()

# 2️⃣ Load source tables (simulating Teradata -> AWS)
employee_df = spark.read.option("header", True).csv("s3://aaa-insurance/employee_history_master.csv")
referral_df = spark.read.option("header", True).csv("s3://aaa-insurance/referral_history_master.csv")

# 3️⃣ Load column mapping file (CSV)
mapping_df = pd.read_csv("/mnt/data/column_mapping.csv")

# Convert data types
referral_df = referral_df.withColumn("sellingoffice", col("sellingoffice").cast("int")) \
                         .withColumn("referredby", col("referredby").cast("long"))

employee_df = employee_df.withColumn("employee_id", col("employee_id").cast("long"))

# 4️⃣ Perform necessary joins based on mapping logic
joined_df = referral_df.join(employee_df, referral_df.referredby == employee_df.employee_id, "left")

# 5️⃣ Derive fields based on mapping
window_spec = Window.partitionBy("referredby", "sellingoffice", "referralcreatedate")
joined_df = joined_df.withColumn("referralcount", count("referral_id").over(window_spec))

# 6️⃣ Build final column list dynamically based on mapping
final_columns = []
for _, row in mapping_df.iterrows():
    src = row['source_column']
    tgt = row['target_column']
    transform = row['transformation']

    if transform == 'direct':
        final_columns.append(col(row['target_column']).alias(src))
    elif transform == 'join_on_employee_id':
        final_columns.append(col('employeename').alias(src))
    elif transform == 'derived_count':
        final_columns.append(col('referralcount').alias(src))
    elif transform == 'default_unknown':
        final_columns.append(lit("Unknown").alias(src))

# 7️⃣ Select dynamically created column list
final_df = joined_df.select(*final_columns)

# 8️⃣ Write output to S3 (or local)
final_df.write.mode("overwrite").parquet("s3://aaa-insurance/ace_lina_output/")

print("✅ ACE_LINA transformation completed and written to output.")
