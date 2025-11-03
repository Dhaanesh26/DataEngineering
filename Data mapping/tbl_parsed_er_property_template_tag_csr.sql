-- ===================================================================
-- Final SQL to populate claims_analytics.tbl_parsed_er_property_template_tag_csr
-- Derived from property_tag.py PySpark logic
-- ===================================================================
'''
INSERT INTO claims_analytics.tbl_parsed_er_property_template_tag_csr
SELECT DISTINCT 
    a.claim_number,
    a.loss_type_description,
    a.col,
    a.water_col,
    a.fire_dmg,
    a.supply_q1,
    a.supply_q2,
    a.plumbing_q1,
    a.appliance_q1,
    a.appliance_q2,
    a.appliance_q3,
    a.appliance_q4,
    a.appliance_q5,
    a.filter_q1,
    a.condo_q1,
    a.condo_q2,
    a.condo_q3,
    a.drain_q1,
    a.drain_q2,
    a.tenant_q1,
    a.tenant_q2,
    a.oth_water_q1,
    a.oth_water_q2,
    a.fire_3_q1,
    a.fire_3_q2,
    a.fire_2_q1,
    a.fire_2_q2,
    a.fire_2_q3,
    a.fire_2_q4,
    a.fire_1_q1,
    a.fire_1_q2,
    a.fire_1_q3,
    a.fire_1_q4,
    a.fire_1_q5,
    a.fire_1_q6,
    a.vehicle_q1,
    a.vehicle_q2,
    a.vehicle_q3,
    a.theft_q1,
    a.theft_q2,
    a.theft_q3,
    a.tree_q1,
    a.tree_q2,
    a.tree_q3,
    a.notes,
    a.reserves_verified,
    a.tag,
    rec.recommendation,
    rec.percent_to_rec,
    a.note_date,
    a.note_user_id,
    b.user_id,
    b.csr_name,
    b.employee_id,
    c.work_state,
    c.reports_to,
    c.cost_center_description
FROM (
    SELECT 
        claim_number,
        loss_type_description,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 1)  AS col,
        REGEXP_SUBSTR(tag, "[^|]+"", 1, 2)  AS water_col,
        REGEXP_SUBSTR(tag, \[^|]+\, 1, 3)  AS fire_dmg,
        REGEXP_SUBSTR(tag, "[^|]+\, 1, 4)  AS supply_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 5)  AS supply_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 6)  AS plumbing_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 7)  AS appliance_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 8)  AS appliance_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 9)  AS appliance_q3,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 10) AS appliance_q4,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 11) AS appliance_q5,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 12) AS filter_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 13) AS condo_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 14) AS condo_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 15) AS condo_q3,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 16) AS drain_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 17) AS drain_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 18) AS tenant_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 19) AS tenant_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 20) AS oth_water_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 21) AS oth_water_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 22) AS fire_3_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 23) AS fire_3_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 24) AS fire_2_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 25) AS fire_2_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 26) AS fire_2_q3,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 27) AS fire_2_q4,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 28) AS fire_1_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 29) AS fire_1_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 30) AS fire_1_q3,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 31) AS fire_1_q4,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 32) AS fire_1_q5,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 33) AS fire_1_q6,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 34) AS vehicle_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 35) AS vehicle_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 36) AS vehicle_q3,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 37) AS theft_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 38) AS theft_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 39) AS theft_q3,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 40) AS tree_q1,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 41) AS tree_q2,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 42) AS tree_q3,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 43) AS notes,
        REGEXP_SUBSTR(tag, "[^|]+", 1, 44) AS reserves_verified,
        tag,
        note_date,
        note_user_id,
        note_id
    FROM (
        SELECT
            regexp_extract(upper(a.body), "~BDEP-(.*?)(\\||~)", 1) AS tag, 
            b.claim_number,
            b.loss_type_description,
            a.create_time AS note_date,
            a.create_user_id AS note_user_id,
            a.note_id
        FROM claims_master.claims_notes_master a
        JOIN claims_master.claims_master b 
          ON a.claim_id = b.claim_id
        WHERE b.line_of_business_desc = "Property"
          AND a.create_time > (
              SELECT MAX(note_date)
              FROM claims_analytics.tbl_parsed_er_property_template_tag_csr
          )
          AND upper(a.body) LIKE "%~BDEP-%"
    ) src
) a
LEFT JOIN (
    SELECT 
        note_id,
        recommendation,
        percent_to_rec
    FROM (
        SELECT 
            a.note_id,
            b.recommendation,
            a.num_matches / b.num_fields * 100 AS percent_to_rec,
            ROW_NUMBER() OVER(PARTITION BY a.note_id ORDER BY a.num_matches / b.num_fields DESC) AS rn
        FROM (
            SELECT a.note_id, b.tag_id, COUNT(DISTINCT b.field) AS num_matches
            FROM (
                -- field-value pairs extracted from tags
                SELECT "{field}" AS field, value, note_id
                FROM tmp_er_template_tag_rec_linking
            ) a
            LEFT JOIN claims_analytics.ref_tbl_er_property_template_minimal_tag_rec_linking b 
                ON a.field = b.field AND a.value = b.value
            WHERE b.field IS NOT NULL
            GROUP BY a.note_id, b.tag_id
        ) a
        LEFT JOIN claims_analytics.ref_tbl_er_property_template_minimal_tag_recs b 
          ON a.tag_id = b.tag_id
    ) x
    WHERE rn = 1
) rec
  ON a.note_id = rec.note_id
LEFT JOIN (
    SELECT DISTINCT 
        user_id, 
        CONCAT(user_first_name, " ", user_last_name) AS csr_name, 
        employee_id 
    FROM claims_master.user_master
) b 
  ON a.note_user_id = b.user_id
LEFT JOIN hr_analytics.v_employee_profile c
  ON CAST(b.employee_id AS INT) = c.employee_no;
'''

-- =====================================================================
-- SQL to populate tbl_parsed_er_property_template_tag_csr
-- =====================================================================

WITH existing_er_tags AS (
    SELECT * FROM ${read_claims_analytics_db}.tbl_parsed_er_property_template_tag_csr
),

max_note AS (
    SELECT MAX(note_date) AS max_note_date
    FROM existing_er_tags
),

bdep_notes AS (
    SELECT  
        upper(a.body) AS body,
        b.claim_number,
        b.loss_type_description,
        a.create_time AS note_date,
        a.create_user_id AS note_user_id,
        a.note_id
    FROM ${read_claims_master_db}.claims_notes_master a
    JOIN ${read_claims_master_db}.claims_master b
        ON a.claim_id = b.claim_id
    WHERE b.line_of_business_desc = 'Property'
      AND a.create_time > (SELECT max_note_date FROM max_note)
      AND a.body LIKE '%~BDEP-%'
),

parsed_bdep AS (
    SELECT  
        regexp_extract(body, '~BDEP-(.*?)(\\|~)', 1) AS tag,
        claim_number,
        loss_type_description,
        note_date,
        note_user_id,
        note_id
    FROM bdep_notes
),

split_tags AS (
    SELECT
        claim_number,
        loss_type_description,
        SPLIT(tag, '\\|')[1]  AS col,
        SPLIT(tag, '\\|')[2]  AS water_col,
        SPLIT(tag, '\\|')[3]  AS fire_dmg,
        SPLIT(tag, '\\|')[4]  AS supply_q1,
        SPLIT(tag, '\\|')[5]  AS supply_q2,
        SPLIT(tag, '\\|')[6]  AS plumbing_q1,
        SPLIT(tag, '\\|')[7]  AS appliance_q1,
        SPLIT(tag, '\\|')[8]  AS appliance_q2,
        SPLIT(tag, '\\|')[9]  AS appliance_q3,
        SPLIT(tag, '\\|')[10] AS appliance_q4,
        SPLIT(tag, '\\|')[11] AS appliance_q5,
        SPLIT(tag, '\\|')[12] AS filter_q1,
        SPLIT(tag, '\\|')[13] AS condo_q1,
        SPLIT(tag, '\\|')[14] AS condo_q2,
        SPLIT(tag, '\\|')[15] AS condo_q3,
        SPLIT(tag, '\\|')[16] AS drain_q1,
        SPLIT(tag, '\\|')[17] AS drain_q2,
        SPLIT(tag, '\\|')[18] AS tenant_q1,
        SPLIT(tag, '\\|')[19] AS tenant_q2,
        SPLIT(tag, '\\|')[20] AS oth_water_q1,
        SPLIT(tag, '\\|')[21] AS oth_water_q2,
        SPLIT(tag, '\\|')[22] AS fire_3_q1,
        SPLIT(tag, '\\|')[23] AS fire_3_q2,
        SPLIT(tag, '\\|')[24] AS fire_2_q1,
        SPLIT(tag, '\\|')[25] AS fire_2_q2,
        SPLIT(tag, '\\|')[26] AS fire_2_q3,
        SPLIT(tag, '\\|')[27] AS fire_2_q4,
        SPLIT(tag, '\\|')[28] AS fire_1_q1,
        SPLIT(tag, '\\|')[29] AS fire_1_q2,
        SPLIT(tag, '\\|')[30] AS fire_1_q3,
        SPLIT(tag, '\\|')[31] AS fire_1_q4,
        SPLIT(tag, '\\|')[32] AS fire_1_q5,
        SPLIT(tag, '\\|')[33] AS fire_1_q6,
        SPLIT(tag, '\\|')[34] AS vehicle_q1,
        SPLIT(tag, '\\|')[35] AS vehicle_q2,
        SPLIT(tag, '\\|')[36] AS vehicle_q3,
        SPLIT(tag, '\\|')[37] AS theft_q1,
        SPLIT(tag, '\\|')[38] AS theft_q2,
        SPLIT(tag, '\\|')[39] AS theft_q3,
        SPLIT(tag, '\\|')[40] AS tree_q1,
        SPLIT(tag, '\\|')[41] AS tree_q2,
        SPLIT(tag, '\\|')[42] AS tree_q3,
        SPLIT(tag, '\\|')[43] AS notes,
        SPLIT(tag, '\\|')[44] AS reserves_verified,
        tag,
        note_date,
        note_user_id,
        note_id
    FROM parsed_bdep
),

tag_link_counts AS (
    SELECT
        a.note_id,
        b.tag_id,
        COUNT(DISTINCT b.field) AS num_matches
    FROM (
        SELECT field, value, note_id
        FROM split_tags
        LATERAL VIEW explode(map(
            'col', col, 'water_col', water_col, 'fire_dmg', fire_dmg,
            'supply_q1', supply_q1, 'supply_q2', supply_q2, 'plumbing_q1', plumbing_q1,
            'appliance_q1', appliance_q1, 'appliance_q2', appliance_q2, 'appliance_q3', appliance_q3,
            'appliance_q4', appliance_q4, 'appliance_q5', appliance_q5, 'filter_q1', filter_q1,
            'condo_q1', condo_q1, 'condo_q2', condo_q2, 'condo_q3', condo_q3,
            'drain_q1', drain_q1, 'drain_q2', drain_q2, 'tenant_q1', tenant_q1,
            'tenant_q2', tenant_q2, 'oth_water_q1', oth_water_q1, 'oth_water_q2', oth_water_q2,
            'fire_3_q1', fire_3_q1, 'fire_3_q2', fire_3_q2, 'fire_2_q1', fire_2_q1,
            'fire_2_q2', fire_2_q2, 'fire_2_q3', fire_2_q3, 'fire_2_q4', fire_2_q4,
            'fire_1_q1', fire_1_q1, 'fire_1_q2', fire_1_q2, 'fire_1_q3', fire_1_q3,
            'fire_1_q4', fire_1_q4, 'fire_1_q5', fire_1_q5, 'fire_1_q6', fire_1_q6,
            'vehicle_q1', vehicle_q1, 'vehicle_q2', vehicle_q2, 'vehicle_q3', vehicle_q3,
            'theft_q1', theft_q1, 'theft_q2', theft_q2, 'theft_q3', theft_q3,
            'tree_q1', tree_q1, 'tree_q2', tree_q2, 'tree_q3', tree_q3, 'reserves_verified', reserves_verified
        )) exploded as field, value
    ) a
    LEFT JOIN ${read_claims_analytics_db}.ref_tbl_er_property_template_minimal_tag_rec_linking b
        ON a.field = b.field AND a.value = b.value
    WHERE b.field IS NOT NULL
    GROUP BY a.note_id, b.tag_id
),

tag_recommendations AS (
    SELECT
        note_id,
        recommendation,
        percent_to_rec
    FROM (
        SELECT
            a.note_id,
            b.tag_id,
            b.recommendation,
            a.num_matches / b.num_fields * 100 AS percent_to_rec,
            ROW_NUMBER() OVER(PARTITION BY a.note_id ORDER BY (a.num_matches / b.num_fields * 100) DESC) AS row_num
        FROM tag_link_counts a
        LEFT JOIN ${read_claims_analytics_db}.ref_tbl_er_property_template_minimal_tag_recs b
            ON a.tag_id = b.tag_id
    ) ranked
    WHERE row_num = 1
),

user_info AS (
    SELECT DISTINCT 
        user_id, 
        CONCAT(user_first_name, ' ', user_last_name) AS csr_name, 
        employee_id 
    FROM ${read_claims_master_db}.user_master
)

SELECT DISTINCT 
    a.claim_number,
    a.loss_type_description,
    a.* EXCEPT(tag, note_date, note_user_id, note_id),
    rec.recommendation,
    rec.percent_to_rec,
    a.note_date,
    a.note_user_id,
    b.user_id,
    b.csr_name,
    b.employee_id,
    c.work_state,
    c.reports_to,
    c.cost_center_description
FROM split_tags a
LEFT JOIN tag_recommendations rec
    ON a.note_id = rec.note_id
LEFT JOIN user_info b
    ON a.note_user_id = b.user_id
LEFT JOIN hr_analytics.v_employee_profile c
    ON CAST(b.employee_id AS INT) = c.employee_no;
