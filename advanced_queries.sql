-- 1. Top Influencer per Sentiment Type
WITH engagement_scores AS (
  SELECT
    Username,
    Sentiment,
    SUM(Likes + Comments - Dislikes) AS Total_Engagement
  FROM instagram_posts
  GROUP BY Username, Sentiment
),
ranked_influencers AS (
  SELECT *,
         RANK() OVER (PARTITION BY Sentiment ORDER BY Total_Engagement DESC) AS rnk
  FROM engagement_scores
)
SELECT Sentiment, Username, Total_Engagement
FROM ranked_influencers
WHERE rnk = 1;

-- 2. Most Improved Models Over Time (H1 vs H2)
WITH monthly_data AS (
  SELECT
    Mobile_Model,
    CASE
      WHEN STRFTIME('%m', Post_Date) IN ('01', '02', '03') THEN 'H1'
      WHEN STRFTIME('%m', Post_Date) IN ('04', '05', '06') THEN 'H2'
    END AS Half_Year,
    AVG(Likes + Comments - Dislikes) AS Avg_Engagement
  FROM instagram_posts
  WHERE STRFTIME('%Y', Post_Date) = '2024'
  GROUP BY Mobile_Model, Half_Year
),
pivoted AS (
  SELECT
    Mobile_Model,
    MAX(CASE WHEN Half_Year = 'H1' THEN Avg_Engagement END) AS H1_Engagement,
    MAX(CASE WHEN Half_Year = 'H2' THEN Avg_Engagement END) AS H2_Engagement
  FROM monthly_data
  GROUP BY Mobile_Model
)
SELECT *,
       (H2_Engagement - H1_Engagement) AS Engagement_Growth
FROM pivoted
WHERE H1_Engagement IS NOT NULL AND H2_Engagement IS NOT NULL
ORDER BY Engagement_Growth DESC
LIMIT 5;

-- 3. Top 3 Posts per Mobile Model by Engagement
SELECT *
FROM (
  SELECT *,
         RANK() OVER (PARTITION BY Mobile_Model ORDER BY (Likes + Comments - Dislikes) DESC) AS rnk
  FROM instagram_posts
) ranked_posts
WHERE rnk <= 3;

-- 4. Sentiment Shift per User (First vs Last Post)
WITH user_posts AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY Username ORDER BY Post_Date ASC) AS rn_asc,
         ROW_NUMBER() OVER (PARTITION BY Username ORDER BY Post_Date DESC) AS rn_desc
  FROM instagram_posts
),
first_last AS (
  SELECT Username,
         MAX(CASE WHEN rn_asc = 1 THEN Sentiment END) AS First_Sentiment,
         MAX(CASE WHEN rn_desc = 1 THEN Sentiment END) AS Last_Sentiment
  FROM user_posts
  GROUP BY Username
)
SELECT *,
       CASE
         WHEN First_Sentiment != Last_Sentiment THEN 'Changed'
         ELSE 'No Change'
       END AS Sentiment_Shift
FROM first_last;

-- 5. Identify Engagement Outliers (2x more than average)
WITH model_avg AS (
  SELECT Mobile_Model,
         AVG(Likes + Comments - Dislikes) AS Avg_Engagement
  FROM instagram_posts
  GROUP BY Mobile_Model
)
SELECT p.*
FROM instagram_posts p
JOIN model_avg m ON p.Mobile_Model = m.Mobile_Model
WHERE (p.Likes + p.Comments - p.Dislikes) > 2 * m.Avg_Engagement;
