-- Change Siteurl & Homeurl
UPDATE wp_options SET option_value = replace(option_value, 'http://www.oldsiteurl.com', 'http://www.newsiteurl.com') WHERE option_name = 'home' OR option_name = 'siteurl'

-- Change GUID
UPDATE wp_posts SET guid = REPLACE (guid, 'http://www.oldsiteurl.com', 'http://www.newsiteurl.com')

-- Change URL in Content
UPDATE wp_posts SET post_content = REPLACE (post_content, 'http://www.oldsiteurl.com', 'http://www.newsiteurl.com')

-- Change Image Path Only
UPDATE wp_posts SET post_content = REPLACE (post_content, 'src="http://www.oldsiteurl.com"', 'src="http://yourcdn.newsiteurl.com"')
UPDATE wp_posts SET guid = REPLACE (guid, 'http://www.oldsiteurl.com', 'http://yourcdn.newsiteurl.com') WHERE post_type = 'attachment'

-- Update Post Meta
UPDATE wp_postmeta SET meta_value = REPLACE (meta_value, 'http://www.oldsiteurl.com','http://www.newsiteurl.com')

-- Change Default "Admin" Username
UPDATE wp_users SET user_login = 'Your New Username' WHERE user_login = 'Admin'

--Reset Password
UPDATE wp_users SET user_pass = MD5( 'new_password' ) WHERE user_login = 'your-username'

-- Assign all articles by Author B to Author A
SELECT ID, display_name FROM wp_users
UPDATE wp_posts SET post_author = 'new-author-id' WHERE post_author = 'old-author-id'

-- Delete Revision
DELETE FROM wp_posts WHERE post_type = "revision"

-- Delete Post Meta
DELETE FROM wp_postmeta WHERE meta_key = 'your-meta-key'

-- Export all Comment Emails with no Duplicate
SELECT DISTINCT comment_author_email FROM wp_comments

-- Delete all Pingback
DELETE FROM wp_comments WHERE comment_type = 'pingback'

-- Delete all Spam Comments
DELETE FROM wp_comments WHERE comment_approved = 'spam'

-- Deleting All Unapproved Comments
DELETE FROM wp_comments WHERE comment_approved = 0

-- Identify Unused Tags
SELECT * From wp_terms wt
INNER JOIN wp_term_taxonomy wtt ON wt.term_id=wtt.term_id WHERE wtt.taxonomy='post_tag' AND wtt.count=0

-- Disable Comments on Older Posts
UPDATE wp_posts SET comment_status = 'closed' WHERE post_date < '2010-01-01' AND post_status = 'publish'

-- Globally disable pingbacks/trackbacks for all users
UPDATE wp_posts SET ping_status = 'closed'

-- Identify & Delete Posts that are over 'X' Days Old
SELECT * FROM `wp_posts`
WHERE 'post_type' = 'post'
AND DATEDIFF(NOW(), `post_date`) > X

-- Removing Unwanted Shortcodes
UPDATE wp_post SET post_content = replace(post_content, '[tweet]', '' )

-- Change Your WP Posts Into Pages and Vice-Versa
UPDATE wp_posts SET post_type = 'page' WHERE post_type = 'post'
 
-- Disable or Enable All WordPress Plugins
UPDATE wp_options SET option_value = 'a:0:{}' WHERE option_name = 'active_plugins'