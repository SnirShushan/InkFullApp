<?php
/**
 * Export all objects from Firebase Storage (GCS) using the existing service account.
 * Usage: php tools/backup/export_firebase_storage.php
 */
declare(strict_types=1);

$root = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . 'api' . DIRECTORY_SEPARATOR . 'inkapp-api-admin';
require $root . '/vendor/autoload.php';

$outDir = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . 'backups' . DIRECTORY_SEPARATOR . 'firebase';
$manifestPath = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . 'backups' . DIRECTORY_SEPARATOR . 'firebase_manifest.jsonl';
$keyPath = $root . '/api/fcm.json';
$bucket = 'ink-flutter-app.appspot.com';

if (!is_dir($outDir)) {
    mkdir($outDir, 0775, true);
}

$client = new Google_Client();
$client->setAuthConfig($keyPath);
$client->addScope('https://www.googleapis.com/auth/devstorage.read_only');
$http = $client->authorize();

$pageToken = null;
$total = 0;
$errors = 0;
$manifest = fopen($manifestPath, 'ab');

echo "Exporting gs://{$bucket} -> {$outDir}\n";

do {
    $qs = [
        'maxResults' => 200,
        'fields' => 'nextPageToken,items(name,size,contentType,updated,mediaLink)',
    ];
    if ($pageToken) {
        $qs['pageToken'] = $pageToken;
    }
    $url = 'https://storage.googleapis.com/storage/v1/b/' . rawurlencode($bucket) . '/o?' . http_build_query($qs);
    $res = $http->get($url);
    if ($res->getStatusCode() !== 200) {
        fwrite(STDERR, "List failed HTTP " . $res->getStatusCode() . ": " . $res->getBody() . "\n");
        exit(1);
    }
    $json = json_decode((string)$res->getBody(), true);
    $items = $json['items'] ?? [];
    foreach ($items as $item) {
        $name = $item['name'] ?? '';
        if ($name === '' || str_ends_with($name, '/')) {
            continue;
        }
        $dest = $outDir . DIRECTORY_SEPARATOR . str_replace(['/', '\\'], DIRECTORY_SEPARATOR, $name);
        $destDir = dirname($dest);
        if (!is_dir($destDir)) {
            mkdir($destDir, 0775, true);
        }

        $sizeRemote = isset($item['size']) ? (int)$item['size'] : -1;
        if (is_file($dest) && $sizeRemote >= 0 && filesize($dest) === $sizeRemote) {
            echo "SKIP {$name}\n";
            $total++;
            continue;
        }

        // Authenticated media download
        $dl = 'https://storage.googleapis.com/storage/v1/b/' . rawurlencode($bucket)
            . '/o/' . rawurlencode($name) . '?alt=media';
        try {
            $fileRes = $http->get($dl, ['sink' => $dest]);
            $code = $fileRes->getStatusCode();
            if ($code !== 200) {
                throw new RuntimeException("HTTP {$code}");
            }
            $row = [
                'name' => $name,
                'size' => is_file($dest) ? filesize($dest) : 0,
                'contentType' => $item['contentType'] ?? null,
                'updated' => $item['updated'] ?? null,
                'local' => $dest,
                'exported_at' => date('c'),
            ];
            fwrite($manifest, json_encode($row, JSON_UNESCAPED_SLASHES) . "\n");
            echo "OK   {$name} (" . $row['size'] . " bytes)\n";
            $total++;
        } catch (Throwable $e) {
            $errors++;
            fwrite(STDERR, "FAIL {$name}: {$e->getMessage()}\n");
            @unlink($dest);
        }
    }
    $pageToken = $json['nextPageToken'] ?? null;
} while ($pageToken);

fclose($manifest);
echo "Done. files={$total} errors={$errors}\n";
echo "Manifest: {$manifestPath}\n";
