#!/usr/bin/env bash
set -m;

cd /var/www/astesting/vendor/aerospike/aerospike-php/aerospike-connection-manager

make &

wait
