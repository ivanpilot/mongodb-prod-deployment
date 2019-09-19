#! /bin/bash
echo "hello from script 2"
echo "increase atc value by 1"
(( atc + 1 ))
echo "atc value is now ${atc}"
echo "-------------------"