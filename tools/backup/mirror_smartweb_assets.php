<?php
/**
 * Mirror smartweb static assets that still respond.
 * Usage: php tools/backup/mirror_smartweb_assets.php
 */
declare(strict_types=1);

$base = 'https://smartweb-tech.com/apps/ink/assets';
$outDir = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . 'backups' . DIRECTORY_SEPARATOR . 'smartweb' . DIRECTORY_SEPARATOR . 'assets';
$localStyles = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . 'studio' . DIRECTORY_SEPARATOR . 'php-admin' . DIRECTORY_SEPARATOR . 'assets' . DIRECTORY_SEPARATOR . 'images' . DIRECTORY_SEPARATOR . 'styles';

if (!is_dir($outDir)) {
    mkdir($outDir, 0775, true);
}

function download(string $url, string $dest): bool
{
    $dir = dirname($dest);
    if (!is_dir($dir)) {
        mkdir($dir, 0775, true);
    }
    if (is_file($dest) && filesize($dest) > 0) {
        echo "SKIP {$url}\n";
        return true;
    }
    $ctx = stream_context_create([
        'http' => [
            'timeout' => 60,
            'header' => "User-Agent: InkBackup/1.0\r\n",
            'ignore_errors' => true,
        ],
    ]);
    $data = @file_get_contents($url, false, $ctx);
    if ($data === false || strlen($data) < 32) {
        echo "FAIL {$url}\n";
        return false;
    }
    // skip HTML error pages
    if (stripos($data, '<html') !== false || stripos($data, '<!DOCTYPE') !== false) {
        echo "HTML {$url}\n";
        return false;
    }
    file_put_contents($dest, $data);
    echo "OK   {$url} (" . strlen($data) . ")\n";
    return true;
}

// 1) Copy local style icons (already in repo)
if (is_dir($localStyles)) {
    $destStyles = $outDir . DIRECTORY_SEPARATOR . 'images' . DIRECTORY_SEPARATOR . 'styles';
    if (!is_dir($destStyles)) {
        mkdir($destStyles, 0775, true);
    }
    foreach (glob($localStyles . DIRECTORY_SEPARATOR . '*.{png,jpg,jpeg,webp,gif}', GLOB_BRACE) ?: [] as $file) {
        $target = $destStyles . DIRECTORY_SEPARATOR . basename($file);
        if (!is_file($target)) {
            copy($file, $target);
            echo "COPY styles/" . basename($file) . "\n";
        }
    }
}

// 2) Known static paths on smartweb
$known = [
    'img/defult.png',
    'images/styles/Anime.png',
    'images/styles/Blackwork.png',
    'images/styles/Bold Line.png',
    'images/styles/default.jpg',
    'images/styles/Dotwork.png',
];

// Also try every local style name against smartweb
foreach (glob($localStyles . DIRECTORY_SEPARATOR . '*.{png,jpg,jpeg,webp,gif}', GLOB_BRACE) ?: [] as $file) {
    $known[] = 'images/styles/' . basename($file);
}
$known = array_values(array_unique($known));

$ok = 0;
$fail = 0;
foreach ($known as $rel) {
    $url = $base . '/' . str_replace(' ', '%20', $rel);
    $dest = $outDir . DIRECTORY_SEPARATOR . str_replace(['/', '\\'], DIRECTORY_SEPARATOR, $rel);
    if (download($url, $dest)) {
        $ok++;
    } else {
        $fail++;
    }
}

echo "Done. ok={$ok} fail={$fail}\n";
