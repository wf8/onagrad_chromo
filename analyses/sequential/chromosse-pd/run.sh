#!/bin/bash

rm -rf temp_output
mkdir temp_output

for rep in {1..24}
do
    echo "rep = ${rep}" > ${rep}.Rev
    echo "seed(${rep})" >> ${rep}.Rev
    cat onagrad.Rev >> ${rep}.Rev
    rb ${rep}.Rev > temp_output/${rep}.out 2>&1 &
    sleep 0.5
    rm ${rep}.Rev
done
