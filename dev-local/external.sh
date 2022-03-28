#!/bin/bash

LASTUPDATED=$(date -r $1)

echo '{"lastupdated":"'$LASTUPDATED'"}' | jq .