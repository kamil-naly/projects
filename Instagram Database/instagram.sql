CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	usermame VARCHAR(30) NOT NULL UNIQUE,
	bio VARCHAR(400),
  	avatar VARCHAR(200),
  	phone VARCHAR(30),
  	email VARCHAR(40),
  	password VARCHAR(50) NOT NULL,
	CHECK(COALESCE(phone, email) IS NOT NULL)
);

CREATE TABLE posts (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	url VARCHAR(200),
	caption VARCHAR(240),
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- delete posts if user deleted
	lat REAL CHECK(lat IS NULL OR (lat >= -90 AND lat <= 90)),
	lng REAL CHECK(lng IS NULL OR (lng >= -180 AND lng <= 180))
);

CREATE TABLE comments (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	comment_text VARCHAR(240) NOT NULL,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- delete comments if user deleted
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE -- delete comments if post deleted
);

CREATE TABLE likes (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,	
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, 
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	comment_id INTEGER NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
	UNIQUE (user_id, post_id, comment_id), -- user can only like post or comment one time
	CHECK (
		COALESCE((post_id)::BOOLEAN::INTEGER, 0)
		+
		COALESCE((comment_id)::BOOLEAN::INTEGER, 0)
		=
		1
	) -- ensure one likes id is only either for one post or one comment
);

CREATE TABLE posts_tags ( -- tag other user to a post / picture
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, 
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	x INTEGER NOT NULL,
	y INTEGER NOT NULL,
	UNIQUE(user_id, post_id)
);

CREATE TABLE caption_tags ( -- tag other user to a caption 
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, 
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	UNIQUE(user_id, post_id)
);

CREATE TABLE follows (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	leader_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	follower_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	UNIQUE(leader_id, follower_id)
);

CREATE TABLE hashtags (
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	title VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE hashtags_posts (
	id SERIAL PRIMARY KEY,
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	hashtag_id INTEGER NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
	UNIQUE(post_id, hashtag_id)
);








