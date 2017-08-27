#!/bin/sh
set -xe

# aws configure set aws_access_key_id YOUR_KEY_HERE
# aws configure set aws_secret_access_key YOU_SECRET_HERE
# aws configure set default.region DEFAULT_REGION_HERE

service supervisord restart
