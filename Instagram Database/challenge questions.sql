-- count all user
SELECT COUNT(*) FROM users;

-- 5 oldest users
SELECT *
FROM users
ORDER BY created_at DESC
LIMIT 5;

-- find user id 200 and see the captions of all posts they have created
SELECT user_id, username, posts.id, caption
FROM users
JOIN posts ON posts.user_id = users.id
WHERE users.id = 200;

-- show each username and number of likes they have created
SELECT username, COUNT(*)
FROM users
JOIN likes ON likes.user_id = users.id
GROUP BY username;

-- what day of the week do most user register on
SELECT EXTRACT(DOW FROM created_at) AS day_of_week, COUNT(*) AS registration_count
FROM users
GROUP BY 1
ORDER BY 2 DESC;

-- we want to target inactive users with email campaign
-- find users who have never posted 
SELECT DISTINCT username, email
FROM users
LEFT JOIN posts ON posts.user_id = users.id
WHERE posts.id IS NULL;

-- which user has most liked post
SELECT posts.id, posts.url, COUNT(likes.post_id) AS likes_count, users.username
FROM posts
JOIN likes ON likes.post_id = posts.id
JOIN users ON posts.user_id = users.id
GROUP BY posts.id, users.username
ORDER BY likes_count DESC
LIMIT 1;

-- what is the average number of posts per user
SELECT ROUND(AVG(post_count), 2) AS average_posts_per_user
FROM (
	SELECT users.id, COUNT(posts.id) AS post_count	
	FROM users
	LEFT JOIN posts ON users.id = posts.user_id
	GROUP BY users.id
);

-- 10 most commonly used hashtags
SELECT title, COUNT(hashtags.id) AS hashtag_count
FROM hashtags
JOIN hashtags_posts ON hashtags.id = hashtags_posts.hashtag_id
GROUP BY title
ORDER BY hashtag_count DESC
LIMIT 10;



/* we might have problem with bots. what are the actions to tackle this?
- find abnormal activity patterns (high number of likes, comments, or follows within a short period)
- spammy contents
*/

/* find if there are any suspicious high number of likes, comments, or follows within a short period */
SELECT 
	DATE_TRUNC('minute', created_at) AS truncated_created_at, 
	COUNT(post_id) AS like_post_count
FROM likes
GROUP BY created_at
ORDER BY like_post_count DESC
LIMIT 10;
-- note: number of like per minute for a post is =< 2 like per minute

SELECT 
	DATE_TRUNC('minute', created_at) AS truncated_created_at, 
	COUNT(comment_id) AS like_comment_count
FROM likes
GROUP BY truncated_created_at
ORDER BY like_comment_count DESC
LIMIT 10;
-- note: number of like per minute for a comment is =< 5 like per minute

SELECT
	DATE_TRUNC('minute', created_at) AS truncated_created_at, 
	COUNT(*) AS follower_count,
	follower_id
FROM followers
GROUP BY truncated_created_at, follower_id
ORDER BY follower_count DESC
LIMIT 10;
-- note: there are some users who follow 2 new users per minute 


WITH new_followed_user_per_minute AS (
	SELECT
		follower_id,
		COUNT(follower_id) AS new_accounts_followed,
		EXTRACT(MINUTE FROM created_at) AS minute
	FROM
		followers
	GROUP BY
		follower_id, minute
),
average_new_followed_accounts AS (
	SELECT
		follower_id,
		AVG(new_accounts_followed) AS avg_new_accounts_per_minute
	FROM
		new_followed_user_per_minute
	GROUP BY 
		follower_id
)
SELECT 
	users.id,
	users.username,
	ROUND(COALESCE(average_new_followed_accounts.avg_new_accounts_per_minute), 2) AS avg_new_accounts_per_minute,
	COUNT(DISTINCT followers.leader_id) AS total_followed_users
FROM users
LEFT JOIN followers ON users.id = followers.follower_id
LEFT JOIN average_new_followed_accounts ON users.id = average_new_followed_accounts.follower_id
GROUP BY 
	users.id, users.username, avg_new_accounts_per_minute
ORDER BY avg_new_accounts_per_minute DESC
LIMIT 10;
-- note: there are some users who on average follow more than 2 new users per minute at a time and has followed a high number of users
-- these users are potentially bots accounts


-- find repetitive contents in posts or comments to find potentially spammy behavior
WITH content_counts AS (
	SELECT content, COUNT(*) AS occurence_count
	FROM (
		SELECT caption AS content FROM posts
		UNION ALL
		SELECT contents AS content FROM comments
	) combined_content
	GROUP BY content	
)
SELECT content, occurence_count
FROM content_counts
WHERE occurence_count > 1
ORDER BY occurence_count DESC
LIMIT 50;
-- note: there are some repetitive contents which mostly contains only hashtags




