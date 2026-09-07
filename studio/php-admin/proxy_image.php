<?php
/**
 * Local-dev image proxy/cache with optional downscale for faster emulator loads.
 * Query: u=<remote url>&w=<max width, default 720>
 */
error_reporting(E_ERROR | E_PARSE);

$url = isset($_GET['u']) ? $_GET['u'] : '';
$maxW = isset($_GET['w']) ? (int)$_GET['w'] : 720;
if ($maxW < 120) $maxW = 120;
if ($maxW > 1600) $maxW = 1600;

if ($url === '' || !filter_var($url, FILTER_VALIDATE_URL)) {
    http_response_code(400);
    header('Content-Type: text/plain');
    echo 'bad url';
    exit;
}

$parts = parse_url($url);
$host = isset($parts['host']) ? strtolower($parts['host']) : '';
$allowed = [
    'firebasestorage.googleapis.com',
    'storage.googleapis.com',
    'lh3.googleusercontent.com',
];
$ok = false;
foreach ($allowed as $allow) {
    if ($host === $allow || substr($host, -strlen('.' . $allow)) === '.' . $allow) {
        $ok = true;
        break;
    }
}
if (!$ok) {
    http_response_code(403);
    header('Content-Type: text/plain');
    echo 'host not allowed';
    exit;
}

$cacheDir = __DIR__ . '/assets/cache';
if (!is_dir($cacheDir)) {
    @mkdir($cacheDir, 0775, true);
}

$hash = sha1($url . '|w' . $maxW);
$metaFile = $cacheDir . '/' . $hash . '.json';
$binFile = $cacheDir . '/' . $hash . '.bin';

if (is_file($binFile) && is_file($metaFile) && filesize($binFile) > 64) {
    $meta = json_decode(@file_get_contents($metaFile), true);
    $ctype = is_array($meta) && !empty($meta['content_type'])
        ? $meta['content_type']
        : 'image/jpeg';
    header('Content-Type: ' . $ctype);
    header('Cache-Control: public, max-age=604800');
    header('Content-Length: ' . filesize($binFile));
    readfile($binFile);
    exit;
}

$ctx = stream_context_create([
    'http' => [
        'method' => 'GET',
        'timeout' => 25,
        'header' => "User-Agent: InkLocalProxy/1.1\r\nAccept: image/*\r\n",
        'ignore_errors' => true,
    ],
    'ssl' => [
        'verify_peer' => true,
        'verify_peer_name' => true,
    ],
]);

$data = @file_get_contents($url, false, $ctx);
if ($data === false || strlen($data) < 32) {
    // fallback placeholder
    $fallback = __DIR__ . '/assets/img/defult.png';
    if (is_file($fallback)) {
        header('Content-Type: image/png');
        header('Cache-Control: public, max-age=60');
        readfile($fallback);
        exit;
    }
    http_response_code(502);
    header('Content-Type: text/plain');
    echo 'fetch failed';
    exit;
}

$ctype = 'image/jpeg';
if (isset($http_response_header) && is_array($http_response_header)) {
    foreach ($http_response_header as $h) {
        if (stripos($h, 'Content-Type:') === 0) {
            $ctype = trim(substr($h, strlen('Content-Type:')));
            // strip params
            $ctype = trim(explode(';', $ctype)[0]);
            break;
        }
    }
}

// Reject non-image bodies (HTML error pages etc.)
if (stripos($ctype, 'image/') !== 0) {
    $fallback = __DIR__ . '/assets/img/defult.png';
    if (is_file($fallback)) {
        header('Content-Type: image/png');
        readfile($fallback);
        exit;
    }
    http_response_code(502);
    exit;
}

$outData = $data;
$outType = $ctype;

if (function_exists('imagecreatefromstring')) {
    $src = @imagecreatefromstring($data);
    if ($src !== false) {
        $sw = imagesx($src);
        $sh = imagesy($src);
        if ($sw > $maxW) {
            $nw = $maxW;
            $nh = (int)round($sh * ($maxW / $sw));
            $dst = imagecreatetruecolor($nw, $nh);
            imagealphablending($dst, false);
            imagesavealpha($dst, true);
            imagecopyresampled($dst, $src, 0, 0, 0, 0, $nw, $nh, $sw, $sh);
            ob_start();
            imagejpeg($dst, null, 78);
            $outData = ob_get_clean();
            $outType = 'image/jpeg';
            imagedestroy($dst);
        }
        imagedestroy($src);
    }
}

@file_put_contents($binFile, $outData);
@file_put_contents($metaFile, json_encode(['content_type' => $outType, 'src' => $url, 'w' => $maxW]));

header('Content-Type: ' . $outType);
header('Cache-Control: public, max-age=604800');
header('Content-Length: ' . strlen($outData));
echo $outData;
