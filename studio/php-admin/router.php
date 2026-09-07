<?php
/**
 * PHP built-in server router for the Ink admin + API tree.
 */
$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
$root = __DIR__;
$file = $root . $uri;

if ($uri !== '/' && file_exists($file) && !is_dir($file)) {
    return false;
}

if ($uri === '/' || $uri === '') {
    header('Location: /admin/');
    exit;
}

if (strpos($uri, '/admin') === 0) {
    chdir($root . '/admin');
    $_SERVER['SCRIPT_NAME'] = '/admin/index.php';
    require $root . '/admin/index.php';
    return true;
}

if (strpos($uri, '/api') === 0) {
    chdir($root . '/api');
    $_SERVER['SCRIPT_NAME'] = '/api/index.php';
    $apiIndex = $root . '/api/index.php';
    if (file_exists($apiIndex)) {
        require $apiIndex;
        return true;
    }
}

http_response_code(404);
echo 'Not found';
return true;
