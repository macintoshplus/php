#!/bin/sh

DIR=$(dirname $0)

cd $DIR

docker build -t php72 --network host .

