#!/bin/sh

DIR=$(dirname $0)

cd $DIR

docker build -t php74 --network host .

