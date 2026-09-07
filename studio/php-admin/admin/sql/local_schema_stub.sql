-- Minimal local schema so the admin panel can load without a full production dump.
SET NAMES utf8mb4;

-- Settings used by layouts / MY_Controller
INSERT INTO tbl_settings (field_name, field_value)
SELECT v.field_name, v.field_value FROM (
  SELECT 'footer_text' AS field_name, 'Ink Admin' AS field_value UNION ALL
  SELECT 'favicon', '' UNION ALL
  SELECT 'danger_color', 'red' UNION ALL
  SELECT 'success_color', 'green-jungle' UNION ALL
  SELECT 'warning_button_color', 'yellow-crusta' UNION ALL
  SELECT 'admin_email', 'ink-app@admin.com' UNION ALL
  SELECT 'admin_phone', '' UNION ALL
  SELECT 'layout', 'layout/ltf_default' UNION ALL
  SELECT 'theam_color', 'default' UNION ALL
  SELECT 'name', 'Ink' UNION ALL
  SELECT 'app_logo', ''
) AS v
WHERE NOT EXISTS (
  SELECT 1 FROM tbl_settings s WHERE s.field_name = v.field_name
);

UPDATE tbl_settings SET field_value='layout/ltf_default' WHERE field_name='layout' AND (field_value='' OR field_value='layout/default');

CREATE TABLE IF NOT EXISTS `tbl_customer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `email` varchar(255) DEFAULT '',
  `phone` varchar(64) DEFAULT '',
  `cnt_code` varchar(16) DEFAULT '',
  `register_type` varchar(16) DEFAULT '1',
  `user_type` varchar(16) DEFAULT '1',
  `business_type` varchar(16) DEFAULT '0',
  `status` varchar(16) DEFAULT '1',
  `is_delete` varchar(8) DEFAULT '0',
  `sub_id` int DEFAULT 0,
  `post_limit` int DEFAULT 0,
  `signature_image` varchar(255) DEFAULT '',
  `profile_image` varchar(255) DEFAULT '',
  `device_type` varchar(16) DEFAULT '',
  `udid` varchar(255) DEFAULT '',
  `login_token` varchar(255) DEFAULT '',
  `app_version` varchar(64) DEFAULT '',
  `ip_registered` varchar(64) DEFAULT '',
  `register_date` datetime DEFAULT NULL,
  `date_added` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `address` text,
  `lat` varchar(64) DEFAULT '',
  `lng` varchar(64) DEFAULT '',
  `radius` varchar(64) DEFAULT '',
  `place_id` varchar(255) DEFAULT '',
  `is_notify` varchar(8) DEFAULT '0',
  `styles` text,
  `about_text` text,
  `city_name` varchar(255) DEFAULT '',
  `address_lat` varchar(64) DEFAULT '',
  `address_lng` varchar(64) DEFAULT '',
  `address_place_id` varchar(255) DEFAULT '',
  `is_business` varchar(8) DEFAULT '0',
  `is_email_send_plan_upgrade` varchar(8) DEFAULT '0',
  `image_name` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_subscription` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cust_id` int DEFAULT 0,
  `product_id` varchar(255) DEFAULT '',
  `expire_date` datetime DEFAULT NULL,
  `is_sub_active` varchar(8) DEFAULT '0',
  `status` varchar(16) DEFAULT '1',
  `is_delete` varchar(8) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_request` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `phone` varchar(64) DEFAULT '',
  `email` varchar(255) DEFAULT '',
  `uid` int DEFAULT 0,
  `business_id` int DEFAULT 0,
  `artists_uid` varchar(255) DEFAULT '',
  `tattoo_size` varchar(255) DEFAULT '',
  `styles` text,
  `description` text,
  `image1_id` varchar(255) DEFAULT '',
  `image2_id` varchar(255) DEFAULT '',
  `image3_id` varchar(255) DEFAULT '',
  `image1_name` varchar(255) DEFAULT '',
  `image2_name` varchar(255) DEFAULT '',
  `image3_name` varchar(255) DEFAULT '',
  `request_images` text,
  `front_side` text,
  `back_side` text,
  `front_data` text,
  `back_data` text,
  `is_contact_request` varchar(8) DEFAULT '0',
  `is_read` varchar(8) DEFAULT '0',
  `date_added` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_report_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uid` int DEFAULT 0,
  `reported_by_uid` int DEFAULT 0,
  `comment` text,
  `status` varchar(16) DEFAULT '0',
  `date_added` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_report_posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pid` int DEFAULT 0,
  `owner` int DEFAULT 0,
  `reported_by_uid` int DEFAULT 0,
  `comment` text,
  `status` varchar(16) DEFAULT '0',
  `date_added` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_post` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uid` int DEFAULT 0,
  `image_name` varchar(255) DEFAULT '',
  `status` varchar(16) DEFAULT '1',
  `is_delete` varchar(8) DEFAULT '0',
  `date_added` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uid` int DEFAULT 0,
  `title` varchar(255) DEFAULT '',
  `status` varchar(16) DEFAULT '1',
  `is_delete` varchar(8) DEFAULT '0',
  `date_added` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_posts_document` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pid` int DEFAULT 0,
  `file_name` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_posts_read` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pid` int DEFAULT 0,
  `uid` int DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_posts_view` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pid` int DEFAULT 0,
  `uid` int DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fname` varchar(255) DEFAULT '',
  `lname` varchar(255) DEFAULT '',
  `name` varchar(255) DEFAULT '',
  `email` varchar(255) DEFAULT '',
  `phone_number` varchar(64) DEFAULT '',
  `city_id` int DEFAULT 0,
  `country_id` int DEFAULT 0,
  `postal_code` varchar(32) DEFAULT '',
  `price_tier` varchar(64) DEFAULT '',
  `profile_image` varchar(255) DEFAULT '',
  `status` varchar(16) DEFAULT '1',
  `is_delete` varchar(8) DEFAULT '0',
  `push_on` varchar(8) DEFAULT '0',
  `device_type` varchar(16) DEFAULT '',
  `udid` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_cities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `city_name` varchar(255) DEFAULT '',
  `is_delete` varchar(8) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_country` (
  `id` int NOT NULL AUTO_INCREMENT,
  `country_name` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `parent_id` int DEFAULT 0,
  `is_parent` varchar(8) DEFAULT '0',
  `seq` int DEFAULT 0,
  `is_delete` varchar(8) DEFAULT '0',
  `status` varchar(16) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `product_id` varchar(255) DEFAULT '',
  `barcode` varchar(255) DEFAULT '',
  `category_id` int DEFAULT 0,
  `price` decimal(12,2) DEFAULT 0,
  `price1` decimal(12,2) DEFAULT 0,
  `pid` int DEFAULT 0,
  `page_url` varchar(255) DEFAULT '',
  `status` varchar(16) DEFAULT '1',
  `is_delete` varchar(8) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_product_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pid` int DEFAULT 0,
  `image` varchar(255) DEFAULT '',
  `seq` int DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_pages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `status` varchar(16) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_slider` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT '',
  `status` varchar(16) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_styles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) DEFAULT '',
  `name` varchar(255) DEFAULT '',
  `name_en` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_acl_action` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_code` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tbl_user_notification` (
  `id` int NOT NULL AUTO_INCREMENT,
  `uid` int DEFAULT 0,
  `pid` int DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE VIEW `view_posts` AS
SELECT p.*,
  0 AS view_count,
  0 AS read_count,
  0 AS view_count_total,
  0 AS read_count_total
FROM tbl_posts p;

CREATE OR REPLACE VIEW `view_products` AS
SELECT p.*, c.name AS category_name
FROM tbl_products p
LEFT JOIN tbl_category c ON p.category_id = c.id;

CREATE OR REPLACE VIEW `view_user` AS
SELECT u.* FROM tbl_users u;

CREATE OR REPLACE VIEW `view_category` AS
SELECT c.* FROM tbl_category c;
