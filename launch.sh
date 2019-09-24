#! /bin/bash



cleaning(){
    if [ $? -ne 0 ]; then
        echo "There was a problem during launch phase. Currently cleaning deployment."
        echo "Deployment has been cleaned. Exiting now."
        exit 0
    fi
}

echo "launch script starts"
echo "-----------"
./script1.sh
cleaning
# if [ $? -ne 0 ]; then
#     echo there was a pb
#     exit 1
# else
#     echo "everything was ok"
# fi

