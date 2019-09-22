#! /bin/bash
# set -e

timer=1
while [ "${timer}" -le 3 ]; do
    sleep 1
    if [ "${timer}" -lt 3 ]; then
        printf '.'
    else
        echo '.'
    fi
    (( timer++ ))
done
echo ALL GOOD



########################################################################################################################

# if [ "${1:0:2}" = "--" ]; then
#     shift

#     if [ "${#}" -ne 6 ]; then
#         echo "You must provide the required arguments." 
#         exit 1
#     fi

#     arg1=${1}
#     arg2=${2}
    
#     shift 2

#     if [ "${1:0:2}" = "-u" ]; then
#         shift
#         username="${1}"
#         shift

#         if [ "${1:0:2}" = "-p" ]; then
#             shift
#             password="${1}"
#         else
#             echo "You must provide a password."
#             exit 1
#         fi
#     elif [ "${1:0:2}" = "-p" ]; then
#         shift
#         password="${1}"
#         shift
#         if [ "${1:0:2}" = "-u" ]; then
#             shift
#             username="${1}"
#         else
#             echo "You must provide a username."
#             exit 1
#         fi
#     else
#         echo "You must provide a username and a password in the correct order."
#         exit 1
#     fi

#     echo "arg 1 was ${arg1}"
#     echo "arg 2 was ${arg2}"
#     echo "username is ${username}"
#     echo "password is ${password}"

#     # echo "remaining args are ${@}"

# else
#     echo "Please provide arguments."
#     exit 1
# fi

########################################################################################################################


# echo "declare variale atc=0"
# atc=0
# echo "atc is ${atc}"

# echo about to launch script 1 and 2
# echo ...
# echo "-------------------"

# ./script1.sh
# ./script2.sh
# echo Back to launch script
# echo "atc is finally at ${atc}"