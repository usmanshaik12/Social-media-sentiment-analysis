-- Sentiment Distribution
SELECT Sentiment, COUNT(*) AS Post_Count
FROM instagram_posts
GROUP BY Sentiment;

-- Most Popular Phone Models
SELECT Mobile_Model, COUNT(*) AS Post_Count
FROM instagram_posts
GROUP BY Mobile_Model
ORDER BY Post_Count DESC;

-- Engagement Score by Post
SELECT Post_ID, Username, (Likes + Comments - Dislikes) AS Engagement_Score
FROM instagram_posts
ORDER BY Engagement_Score DESC
LIMIT 10;

-- Avg Engagement per Mobile Model
SELECT Mobile_Model,
       ROUND(AVG(Likes), 2) AS Avg_Likes,
       ROUND(AVG(Comments), 2) AS Avg_Comments,
       ROUND(AVG(Dislikes), 2) AS Avg_Dislikes
FROM instagram_posts
GROUP BY Mobile_Model
ORDER BY Avg_Likes DESC;

-- Monthly Sentiment Trend
SELECT STRFTIME('%Y-%m', Post_Date) AS Month, Sentiment, COUNT(*) AS Count
FROM instagram_posts
GROUP BY Month, Sentiment
ORDER BY Month;
