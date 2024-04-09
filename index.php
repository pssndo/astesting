<?php

use Aerospike\Client;
use Aerospike\Key;
use Aerospike\Bin;
use Aerospike\WritePolicy;
use Aerospike\ReadPolicy;

require_once __DIR__ . '/vendor/autoload.php';

try {
    $socket = "/tmp/asld_grpc.sock";
    $client = Client::connect($socket);
    var_dump($client->socket);
} catch (AerospikeException $e) {
    var_dump($e);
}

$key = new Key("memstorage", "set_name", 1);


//PUT on differnet types of values
$wp = new WritePolicy();
$bin1 = new Bin("bin1", 111);
$bin2 = new Bin("bin2", "string");
$bin3 = new Bin("bin3", 333.333);
$bin4 = new Bin("bin4", [
    "str",
    1984,
    333.333,
    [1, "string", 5.1],
    [
        "integer" => 1984,
        "float" => 333.333,
        "list" => [1, "string", 5.1]
    ]
]);

$bin5 = new Bin("bin5", [
    "integer" => 1984,
    "float" => 333.333,
    "list" => [1, "string", 5.1],
    null => [
        "integer" => 1984,
        "float" => 333.333,
        "list" => [1, "string", 5.1]
    ],
    "" => [ 1, 2, 3 ],
]);

$client->put($wp, $key, [$bin1, $bin2, $bin3, $bin4, $bin5]);

//GET
$rp = new ReadPolicy();
$record = $client->get($rp, $key);
var_dump($record->bins);

//UPDATE
$client->prepend($wp, $key, [new Bin("bin2", "prefix_")]);
$client->append($wp, $key, [new Bin("bin2", "_suffix")]);

//DELETE
$deleted = $client->delete($wp, $key);
var_dump($deleted);
