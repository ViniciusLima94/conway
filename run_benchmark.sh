#!/bin/bash

i="10"
while [ $i -le 100 ]
do
    ./benchmark $i $i 100000
    ((i=i+10))
done
