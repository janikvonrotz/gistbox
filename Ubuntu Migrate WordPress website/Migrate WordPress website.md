# Introduction

This guide assumes that you're going to migrate a WordPress website from one server to an other.

# Requirements

* Ubuntu server
* Nginx
* Nginx minimal website
* php5-fpm
* php5-mysql, php5-mcrypt
* Nginx php5-fpm website
* MySQL
* Increased Max Upload for php5-fpm website
* phpMyAdmin
* WordPress website


# Instructions

Export the WordPress `wp-content` directory from the existing installation.

Upload it to the home directory `/home/[user]/wp-content` on the new server.

Copy the `wp-content` directory to the new WordPress installation `/var/www/[wordpress]/wp-content`.

    sudo cp -r /home/[user]/wp-content/* /var/www/[wordpress]/wp-content/

Export the existing SQL WordPress database with phpMyAdmin.

Import the SQL WordPress database export into the new database with phpMyAdmin.

Update permissions for the www-data group.

    sudo chown www-data:www-data /var/www/[wordpress] -R 

## Update obsolete urls

In case you are going the change to url of the WordPress website f.g. `http://` to `https://` or `http://www.oldsiteurl.com` to `http://www.newsiteurl.com` update the WordPress database with a custom SQL statement.

Here is an example for url update using SSL only.

```sql
UPDATE wp_posts SET post_content = REPLACE (post_content, 'http://', 'https://');
UPDATE wp_posts SET post_content_filtered = REPLACE (post_content_filtered, 'http://', 'https://');
UPDATE wp_posts SET guid = REPLACE (guid, 'http://', 'https://');
UPDATE wp_posts SET pinged = REPLACE (pinged, 'http://', 'https://');

UPDATE wp_postmeta SET meta_value = REPLACE (meta_value, 'http://', 'https://');

UPDATE wp_options SET option_value = REPLACE (option_value, 'http://', 'https://');

UPDATE wp_comments SET comment_author_url = REPLACE (comment_author_url, 'http://', 'https://');

UPDATE wp_commentmeta SET meta_value = REPLACE (meta_value, 'http://', 'https://');
```

