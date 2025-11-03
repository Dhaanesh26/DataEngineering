-- SQL to populate tbl_parsed_subro_property_tags -- 1st table

-- load the current analytics table 
WITH existing_sub_tags AS (
    SELECT *
    FROM claims_analytics.tbl_parsed_subro_property_tags
),

-- compute the maximum note date, we will only parse new notes whose create time > this value
max_note AS (
    SELECT MAX(note_date) AS max_note_date
    FROM existing_sub_tags
),

-- all notes from claims_notes_master joined to claims_master (to get claims_number), filtered to 
    -- LOB = Property
    -- notes newer than last processed date (note_date)
    -- notes that contain first table substring ('BDSP -') in the body
bdsp_notes AS (
    SELECT
        upper(a.body) AS body,
        b.claim_number,
        b.loss_type_description,
        a.create_time AS note_date,
        a.create_user_id AS note_user_id
    FROM claims_master.claims_notes_master a
    JOIN claims_master.claims_master b
        ON a.claim_id = b.claim_id
    WHERE b.line_of_business_desc = "Property"
      AND a.create_time > (SELECT max_note_date FROM max_note)
      AND a.body LIKE "%BDSP -%"
),

-- the information in notes are stored in the form of tags.. which are not in the redable form or columns
-- Use regexp_extract to pull tag content out of the body
-- Result after this code block execution -> tag is expected like 'field1|field2|field3..'
parsed_notes AS (
    SELECT 
        regexp_extract(body, "~BDSP -(.*?)(\\|~)", 1) AS tag,
        claim_number,
        loss_type_description,
        note_date,
        note_user_id
    FROM bdsp_notes
),

-- this script maps the above segments(tags) into clear column names. transformations are used like
    --boolean conversions (CASE Statements) to translate textual fields to human readable values
    -- tag, note_date, note_user_id are left in bottom select statement for traceability
split_notes AS (
    SELECT
        claim_number,
        loss_type_description,
        SPLIT(tag, "\\|")[1] AS q1_cause_of_loss,
        CASE WHEN SPLIT(tag, "\\|")[2] = "TRUE" THEN "Yes"
             WHEN SPLIT(tag, "\\|")[2] = "FALSE" THEN "No" ELSE "" END AS q1a_fire_source_neighbor,
        CASE WHEN SPLIT(tag, "\\|")[3] = "TRUE" THEN "Yes"
             WHEN SPLIT(tag, "\\|")[3] = "FALSE" THEN "No" ELSE "" END AS q1aa_fire_oc_investigation,
        SPLIT(tag, "\\|")[4]  AS q1ab_fire_ignition_source,
        SPLIT(tag, "\\|")[5]  AS q1ac_fire_product_age,
        SPLIT(tag, "\\|")[6]  AS q1ad_fire_evidence_location,
        SPLIT(tag, "\\|")[7]  AS q1b_water_source,
        CASE WHEN SPLIT(tag, "\\|")[8]  = "TRUE" THEN "Yes"
             WHEN SPLIT(tag, "\\|")[8]  = "FALSE" THEN "No" ELSE "" END AS q1ba_water_tops_eligible,
        CASE WHEN SPLIT(tag, "\\|")[9]  = "TRUE" THEN "Yes"
             WHEN SPLIT(tag, "\\|")[9]  = "FALSE" THEN "No" ELSE "" END AS q1baa_water_sent_to_stutman,
        SPLIT(tag, "\\|")[10] AS q1bb_water_product_age,
        SPLIT(tag, "\\|")[11] AS q1bc_water_evidence_location,
        SPLIT(tag, "\\|")[12] AS q2_adverse_party,
        SPLIT(tag, "\\|")[13] AS q3_police_fire_report,
        CASE WHEN SPLIT(tag, "\\|")[14] = "TRUE" THEN "Proven"
             WHEN SPLIT(tag, "\\|")[14] = "FALSE" THEN "Not proven" ELSE "" END AS q4_negligence,
        CASE WHEN SPLIT(tag, "\\|")[15] = "TRUE" THEN "Yes"
             WHEN SPLIT(tag, "\\|")[15] = "FALSE" THEN "No" ELSE "" END AS q5_investigation_completed,
        CASE WHEN SPLIT(tag, "\\|")[16] = "TRUE" THEN "Yes"
             WHEN SPLIT(tag, "\\|")[16] = "FALSE" THEN "No" ELSE "" END AS q6_evidence_obtained,
        SPLIT(tag, "\\|")[17] AS q7_ccnr,
        SPLIT(tag, "\\|")[18] AS exp_recovery,
        SPLIT(tag, "\\|")[19] AS reserve,
        SPLIT(tag, "\\|")[20] AS type_of_issue,
        SPLIT(tag, "\\|")[21] AS review_notes,
        tag,
        note_date,
        note_user_id
    FROM parsed_notes
)

-- final SELECT returns the parsed, transformed rows exactly the data we would insert into tbl_parsed_subro_property_tags
SELECT *
FROM split_notes;
