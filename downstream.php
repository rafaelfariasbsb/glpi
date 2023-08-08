<?php

// config
defined('GLPI_CONFIG_DIR') or define('GLPI_CONFIG_DIR',     (getenv('GLPI_CONFIG_DIR') ?: '/etc/glpi'));

if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
   require_once GLPI_CONFIG_DIR . '/local_define.php';
}

// marketplace plugins
defined('GLPI_MARKETPLACE_ALLOW_OVERRIDE') or define('GLPI_MARKETPLACE_ALLOW_OVERRIDE', false);

// runtime data
defined('GLPI_VAR_DIR')         or define('GLPI_VAR_DIR',         '/var/lib/glpi/files');

define('GLPI_DOC_DIR',        GLPI_VAR_DIR . '/data-documents');
define('GLPI_CRON_DIR',       GLPI_VAR_DIR . '/_cron');
define('GLPI_DUMP_DIR',       GLPI_VAR_DIR . '/_dumps');
define('GLPI_GRAPH_DIR',      GLPI_VAR_DIR . '/_graphs');
define('GLPI_LOCK_DIR',       GLPI_VAR_DIR . '/_lock');
define('GLPI_PICTURE_DIR',    GLPI_VAR_DIR . '/_pictures');
define('GLPI_PLUGIN_DOC_DIR', GLPI_VAR_DIR . '/_plugins');
define('GLPI_RSS_DIR',        GLPI_VAR_DIR . '/_rss');
define('GLPI_SESSION_DIR',    GLPI_VAR_DIR . '/_sessions');
define('GLPI_TMP_DIR',        GLPI_VAR_DIR . '/_tmp');
define('GLPI_UPLOAD_DIR',     GLPI_VAR_DIR . '/_uploads');
define('GLPI_CACHE_DIR',      GLPI_VAR_DIR . '/_cache');

// log
defined('GLPI_LOG_DIR')         or define('GLPI_LOG_DIR',         '/var/log/glpi');

// use system cron
define('GLPI_SYSTEM_CRON', true);

