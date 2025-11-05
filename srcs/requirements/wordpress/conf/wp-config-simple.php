<?php

// Database configuration using environment variables
define('DB_NAME', 'wordpress');

// Read database credentials from secrets files
$db_user = trim(file_get_contents('/run/secrets/mariadb_user'));
$db_password = trim(file_get_contents('/run/secrets/mariadb_password'));

define('DB_USER', $db_user);
define('DB_PASSWORD', $db_password);
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         '~=%kPnn+AtJtuHcktHv??pK,[<bD+mDa,08rFI`,.^:h?5(u;7p{+!phtF5~N(%<');
define('SECURE_AUTH_KEY',  '`#JJXFV}2fr;}O@|/y^OL&;1&,(%7 &y>n&u^(hK3~WG1FsE]Vox6bqp>L2#.XrB');
define('LOGGED_IN_KEY',    'R;!DXS%8)GV(60BGW!y<aqd^CL4q;XaE(z(4hqZ7cd|b>_P!W>btu6hF2C$C4wGk');
define('NONCE_KEY',        '3_%0Q@-w}yk_e_w}0YU|?~OmV)7-Z$7=jjjX!.D.bW0ifV.-Mec>haK4WG4x6Nn`');
define('AUTH_SALT',        '!sUl.EE4-moZ|AIh@z?W|A*uU4X1EVSPs]H3WLz>^<7;lU-5CDCwzn7#7kV-!&#^');
define('SECURE_AUTH_SALT', 'o+f{u0bW+Mf^Gc+2v+1Krv+NT.WHIQt.u_uZkS6t|+mU%|iA25y2sn|0F[El(a?7');
define('LOGGED_IN_SALT',   '$gC]hd$H(ks{b,ExJ},WW$>-`i8?++&gT#9456A1{rmoIK$L|9+_!y(Q9d7,EJ!`');
define('NONCE_SALT',       '(YwHO#UrR/#{wu[W[v7c9#JTZ1Wu,9)jc4gAuZ09?fqPSn{LN)Tn CSXU,, b+;9');

$table_prefix = 'wp_';

define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);

define('WP_MEMORY_LIMIT', '256M');

define('FS_METHOD', 'direct');

$domain_name = getenv('DOMAIN_NAME') ?: 'luisanch.42.fr';
define('WP_HOME', 'https://' . $domain_name);
define('WP_SITEURL', 'https://' . $domain_name);

define('WP_CONTENT_DIR', '/var/www/wordpress/wp-content');
define('WP_CONTENT_URL', 'https://' . $domain_name . '/wp-content');

define('UPLOADS', 'wp-content/uploads');

define('WP_CACHE', true);

define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', true);

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
?>
