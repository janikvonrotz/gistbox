USE <database>;
 
SET @username = '<username>';
SET @password = MD5('<password>');
SET @fullname = '<Firstname Lastname>';
SET @email = '<login@example.com>';
SET @url = '<http://example.com/>';
 
INSERT INTO `wp_users` (`user_login`, `user_pass`, `user_nicename`, `user_email`, `user_url`, `user_registered`, `user_status`, `display_name`) VALUES (@username, @password, @fullname, @email, @url, NOW(), '0', @fullname);
 
SET @userid = LAST_INSERT_ID();
INSERT INTO `wp_usermeta` (`user_id`, `meta_key`, `meta_value`) VALUES (@userid, 'wp_capabilities', 'a:1:{s:13:"administrator";s:1:"1";}');
INSERT INTO `wp_usermeta` (`user_id`, `meta_key`, `meta_value`) VALUES (@userid, 'wp_user_level', '10');