<?php
/**
 * Local-dev profile image proxy.
 * Query: f=<filename only>
 * Tries local disk, then known remote hosts, then default placeholder.
 */
error_reporting(E_ERROR | E_PARSE);

$f = isset($_GET['f']) ? $_GET['f'] : '';
$f = basename(str_replace(["\0", '..'], '', $f));
if ($f === '' || !preg_match('/^[A-Za-z0-9._\-]+$/', $f)) {
    http_response_code(400);
    header('Content-Type: text/plain');
    echo 'bad file';
    exit;
}

$local = __DIR__ . '/assets/uploads/profile_images/' . $f;
$fallback = __DIR__ . '/assets/img/defult.png';
$cacheDir = __DIR__ . '/assets/cache';
if (!is_dir($cacheDir)) {
    @mkdir($cacheDir, 0775, true);
}

function send_file($path, $ctype = null) {
    if (!is_file($path) || filesize($path) < 32) {
        return false;
    }
    if ($ctype === null) {
        $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
        $map = [
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'webp' => 'image/webp',
        ];
        $ctype = isset($map[$ext]) ? $map[$ext] : 'application/octet-stream';
    }
    header('Content-Type: ' . $ctype);
    header('Cache-Control: public, max-age=86400');
    header('Content-Length: ' . filesize($path));
    readfile($path);
    return true;
}

// 1) Local upload
if (send_file($local)) {
    exit;
}

// 2) Cached remote fetch
$hash = sha1('profile|' . $f);
$binFile = $cacheDir . '/' . $hash . '.bin';
$metaFile = $cacheDir . '/' . $hash . '.json';
if (is_file($binFile) && filesize($binFile) > 64) {
    $meta = json_decode(@file_get_contents($metaFile), true);
    $ctype = is_array($meta) && !empty($meta['content_type'])
        ? $meta['content_type']
        : 'image/jpeg';
    if (send_file($binFile, $ctype)) {
        exit;
    }
}

$remotes = [
    'https://inkisrael.co.il/assets/uploads/profile_images/',
    'https://www.inkisrael.co.il/assets/uploads/profile_images/',
    'http://173.255.254.63/apps/inkapp/assets/uploads/profile_images/',
    'https://itapp2u.com/apps/Inkapp/assets/uploads/profile_images/',
];

$ctx = stream_context_create([
    'http' => [
        'method' => 'GET',
        'timeout' => 12,
        'header' => "User-Agent: InkLocalProfileProxy/1.0\r\nAccept: image/*\r\n",
        'ignore_errors' => true,
    ],
    'ssl' => [
        'verify_peer' => false,
        'verify_peer_name' => false,
    ],
]);

foreach ($remotes as $base) {
    $url = $base . rawurlencode($f);
    // rawurlencode can break if filename already safe; prefer plain concat for simple names
    $url = $base . $f;
    $data = @file_get_contents($url, false, $ctx);
    if ($data === false || strlen($data) < 64) {
        continue;
    }
    $ctype = 'image/jpeg';
    if (isset($http_response_header) && is_array($http_response_header)) {
        foreach ($http_response_header as $h) {
            if (stripos($h, 'Content-Type:') === 0) {
                $ctype = trim(explode(';', trim(substr($h, strlen('Content-Type:'))))[0]);
                break;
            }
        }
    }
    if (stripos($ctype, 'image/') !== 0) {
        continue;
    }
    @file_put_contents($binFile, $data);
    @file_put_contents($metaFile, json_encode(['content_type' => $ctype, 'src' => $url]));
    // Also seed local uploads folder for next time
    @file_put_contents($local, $data);
    header('Content-Type: ' . $ctype);
    header('Cache-Control: public, max-age=86400');
    header('Content-Length: ' . strlen($data));
    echo $data;
    exit;
}

// 3) Placeholder
if (send_file($fallback, 'image/png')) {
    exit;
}

http_response_code(404);
header('Content-Type: text/plain');
echo 'not found';
