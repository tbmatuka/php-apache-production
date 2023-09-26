#!/usr/bin/php
<?php

$phpVersions = [
    '5.6',
    '7.0',
    '7.1',
    '7.2',
    '7.3',
    '7.4',
    '8.0',
    '8.1',
    '8.2',
];

$filesToCopy = [
    'entrypoint.sh',
    'apache2-foreground.sh',
    'sudoers',
    'vhost.conf',
    'remoteip.conf',
    'trusted-proxies.lst',
];

$executableFiles = [
    'entrypoint.sh',
    'apache2-foreground.sh',
];

$dockerfileTemplate = file_get_contents('Dockerfile.template');

foreach ($phpVersions as $phpVersion) {
    printf("Building php%s config\n", $phpVersion);
    
    $dirName = 'php' . $phpVersion;
    if (!is_dir($dirName)) {
        if (!mkdir($dirName, 0755)) {
            die(sprintf("Failed to create directory %s\n", $dirName));
        }
    }
    
    foreach ($filesToCopy as $fileName) {
        if (!copy($fileName, $dirName . '/' . $fileName)) {
            die(sprintf("Failed to copy file %s\n", $fileName));
        }
    }
    
    foreach ($executableFiles as $fileName) {
        chmod($dirName . '/' . $fileName, 0755);
    }
    
    $phpPackagesFile = sprintf('packages-php%s.txt', $phpVersion);
    $phpPackages = trim(str_replace("\n", ' ', file_get_contents($phpPackagesFile)));
    
    $fixes = '';
    $fixesFile = sprintf('fixes-php%s.txt', $phpVersion);
    if (file_exists($fixesFile)) {
        $fixes = file_get_contents($fixesFile);
    }
    
    $dockerfile = $dockerfileTemplate;
    $dockerfile = str_replace('##php-version##', $phpVersion, $dockerfile);
    $dockerfile = str_replace('##php-packages##', $phpPackages, $dockerfile);
    $dockerfile = str_replace('##fixes##', $fixes, $dockerfile);
    
    file_put_contents($dirName . '/Dockerfile', $dockerfile);
}
