<?php
/**
 * Benchmark between different hashing algorithms
 */
include __DIR__.'/../vendor/autoload.php';

$data = 'fadslfjasdlfjasdf';
$times = 10000;

echo sprintf("Get hash of `%s` %d times\n", $data, $times);

$start = microtime(true);
for($i=0; $i < $times; $i++) {
    md5($data);
}
$time = microtime(true) - $start;
echo sprintf("%.12f seconds - md5()\n", $time);

if (extension_loaded('blake')) {
    $start = microtime(true);
    for ($i = 0; $i < $times; $i++) {
        \Blake\Hash::blake256($data);
    }
    $time = microtime(true) - $start;

    echo sprintf("%.12f seconds - \\Blake\\Hash::blake256() (Zephir extension)\n", $time);
}

$start = microtime(true);
for($i=0; $i < $times; $i++) {
    \Decred\Crypto\Hash::blake($data);
}
$time = microtime(true) - $start;

echo sprintf("%.12f seconds - \\Decred\\Crypto\\Hash::blake()\n", $time);


