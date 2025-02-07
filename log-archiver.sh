#!/bin/bash

##############################################################################################################
# Title: log-archiver.sh                                                                                     #
# Description:LogArchiver is designed to archive all log files from a directory, encompassing a specified    #
#             period from the start date to the end date.                                                    #
# Author: Miroslav Gospodinov                                                                                #
# Version: 0.1                                                                                               #
##############################################################################################################

# Function to display script usage
print_usage() {
    echo "Usage: $0 [-h] <YYYY-MM-DD> <YYYY-MM-DD> <DIR>"
    echo "Options:"
    echo " -h, --help      Display this help message"
}

#Function to check the date format
verifyInputDate() {
    if [[ $1 != $(date -d "$1" +%F 2>/dev/null) ]]; then
        {
            echo "Incorrect date. Please use a correct date."
            exit
        }
    else echo $1    
    fi
}

#Function to check if the directory exists
verifyDirectoryExists() {
    if ! [ -d $1 ]; then
        echo "Passed argument is not a directory!"
    fi
    echo $1
}

#Function to compare the dates
compareDates() {
    startDate="$1"
    endDate="$2"

    if [[ $endDate < $startDate ]]; then
        {
            echo "End date must be bigger than the start date"
            exit
        }
    fi
}

#Function to create a tar archive
createTarArchive() {
    find $3 -maxdepth 1 -type f -newermt $1 ! -newermt $2 | xargs tar -cvzf "$(hostname -f)_$1_$(date -d "$2-1day" +"%Y-%m-%d")".tar.gz -P -T -
}

#Check if we have arguments in the command
if [ $# -eq 0 ]; then
    {
        echo "No arguments supplied!"
        print_usage
        exit
    }
fi

#Check for argument "-h"
if [ $1 == "-h" ]; then
    {
        print_usage
        exit
    }
fi

#If we have three valid arguments, execute the command.
if [ $# -eq 3 ]; then
    {
        echo "Start date:" $(verifyInputDate $1)
        echo "End date:" $(verifyInputDate $2)
        compareDates $1 $2
        echo "Log directory:" $(verifyDirectoryExists $3)
        startDate=$1
        endDate=$(date -d "$2+1day" +%Y-%m-%d)
        createTarArchive $startDate $endDate $3
    }
else
    {
        echo "The number of arguments is not correct. Please check the command usage."
    }
fi
