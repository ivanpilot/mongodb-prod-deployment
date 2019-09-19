#! /bin/bash
set -e

echo "declare variale atc=0"
atc=0
echo "atc is ${atc}"

echo about to launch script 1 and 2
echo ...
echo "-------------------"

./script1.sh
./script2.sh
echo Back to launch script
echo "atc is finally at ${atc}"