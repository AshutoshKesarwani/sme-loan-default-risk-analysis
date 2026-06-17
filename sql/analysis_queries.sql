-- SME Loan Default Risk Analysis
-- Author: Ashutosh Kesarwani
-- Aston University | June 2026

-- ================================================
-- QUERY 1: Overall Default Rate
-- ================================================
SELECT 
    MIS_Status,
    COUNT(*) AS total_loans,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM sba_loans
GROUP BY MIS_Status;

-- ================================================
-- QUERY 2: State-wise Default Rate
-- ================================================
SELECT 
    State,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM sba_loans
WHERE MIS_Status IN ('P I F', 'CHGOFF')
GROUP BY State
ORDER BY default_rate_pct DESC
LIMIT 15;

-- ================================================
-- QUERY 3: Industry-wise Default Rate
-- ================================================
SELECT 
    LEFT(NAICS, 2) AS industry_code,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM sba_loans
WHERE MIS_Status IN ('P I F', 'CHGOFF')
AND NAICS != '0'
GROUP BY LEFT(NAICS, 2)
ORDER BY default_rate_pct DESC
LIMIT 15;

-- ================================================
-- QUERY 4: Loan Size vs Default Rate
-- ================================================
SELECT 
    CASE 
        WHEN CAST(GrAppv AS DECIMAL(15,2)) < 50000 
            THEN '1. Small (Under 50K)'
        WHEN CAST(GrAppv AS DECIMAL(15,2)) BETWEEN 50000 AND 150000 
            THEN '2. Medium (50K-150K)'
        WHEN CAST(GrAppv AS DECIMAL(15,2)) BETWEEN 150001 AND 500000 
            THEN '3. Large (150K-500K)'
        ELSE '4. Very Large (500K+)'
    END AS loan_size_bucket,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM sba_loans
WHERE MIS_Status IN ('P I F', 'CHGOFF')
AND GrAppv != ''
GROUP BY loan_size_bucket
ORDER BY loan_size_bucket;

-- ================================================
-- QUERY 5: New vs Existing Business
-- ================================================
SELECT 
    CASE 
        WHEN NewExist = '1' THEN 'Existing Business'
        WHEN NewExist = '2' THEN 'New Business'
    END AS business_type,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM sba_loans
WHERE MIS_Status IN ('P I F', 'CHGOFF')
AND NewExist IN ('1', '2')
GROUP BY NewExist
ORDER BY default_rate_pct DESC;

-- ================================================
-- QUERY 6: Documentation Type vs Default Rate
-- ================================================
SELECT 
    CASE 
        WHEN LowDoc = 'Y' THEN 'Low Documentation'
        WHEN LowDoc = 'N' THEN 'Full Documentation'
        ELSE 'Other'
    END AS doc_type,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM sba_loans
WHERE MIS_Status IN ('P I F', 'CHGOFF')
GROUP BY LowDoc
ORDER BY default_rate_pct DESC;

-- ================================================
-- QUERY 7: Yearly Default Rate Trend
-- ================================================
SELECT 
    ApprovalFY AS year,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM sba_loans
WHERE MIS_Status IN ('P I F', 'CHGOFF')
AND ApprovalFY != ''
GROUP BY ApprovalFY
ORDER BY ApprovalFY ASC;
