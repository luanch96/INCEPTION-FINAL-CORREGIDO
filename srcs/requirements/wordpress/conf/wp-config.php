<?php

$db_user = trim(file_get_contents('/run/secrets/mariadb_user'));
$db_password = trim(file_get_contents('/run/secrets/mariadb_password'));

define('DB_NAME', 'wordpress');
define('DB_USER', $db_user);
define('DB_PASSWORD', $db_password);
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

$table_prefix = 'wp_';

define('WP_DEBUG', false);
define('WP_MEMORY_LIMIT', '256M');
define('FS_METHOD', 'direct');
define('WP_HOME', 'https://luisanch.42.fr');
define('WP_SITEURL', 'https://luisanch.42.fr');
define('WP_CONTENT_DIR', '/var/www/wordpress/wp-content');
define('WP_CONTENT_URL', 'https://luisanch.42.fr/wp-content');
define('UPLOADS', 'wp-content/uploads');
define('WP_CACHE', true);
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', true);

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
?>