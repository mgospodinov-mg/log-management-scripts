#!/bin/bash

##############################################################################################################
# Title: log-cleaner.sh                                                                                     #
# Description:Log-Cleaner is designed to remove all log files from a directory, encompassing a specified    #
#             period from the start date to the end date.                                                    #
# Author: Miroslav Gospodinov                                                                                #
# Version: 0.1                                                                                               #
##############################################################################################################

# Function to display script usage
print_usage() {
    echo "Usage: $0 [-h] <YYYY-MM-DD> <YYYY-MM-DD> <DIR> [--dry-run]"
    echo "Options:"
    echo " -h, --help      Display this help message."
    echo " --dry-run       Execute the command in a dry-run mode."
}

#Function to validate date format
verify_input_date() {
    if [[ $1 != $(date -d "$1" +%F 2>/dev/null) ]]; then
        {
            echo "Incorrect date. Please use a correct date."
            exit
        }
    fi
}

#Function to check if the directory exists
verify_directory_exists() {
    if ! [ -d $1 ]; then
        {
            echo "Passed argument is not a valid directory!"
            exit
        }
    fi
    echo $1
}

#Function to compare the dates
compare_dates() {
    startdate="$1"
    enddate="$2"

    if [[ $enddate < $startdate ]]; then
        {
            echo "End date must be bigger than the start date"
            exit
        }
    fi
}

#Check if we have arguments in the command
if [ $# -eq 0 ]; then
    {
        echo "No arguments supplied!"
        print_usage
        exit
    }
fi

#Check for argument "-h", "--help"
case $1 in
"-h")
    print_usage
    exit
    ;;
-*)
    echo "Invalid command option!"
    exit
    ;;
esac

#Remove files from the directory based on their dates.
delete_files() {
    verify_input_date $1
    startdate=$1
    echo "Start date: $startdate"
    verify_input_date $2
    enddate=$2
    echo "End date: $enddate"
    compare_dates $1 $2
    verify_directory_exists $3
    path=$3
    enddate=$(date -d "$2+1day" +%Y-%m-%d)

    if [ -n "$4" ]; then
        if [ $4 == "--dry-run" ]; then
            {
                dry_run=true
            }
        else
            {
                echo "Incorrect argument $4"
                print_usage
                exit
            }
        fi
    fi

    if [ $dry_run ]; then
        {
            echo "The script is going to delete the following files:"
            find $path -maxdepth 1 -type f -newermt $startdate ! -newermt $enddate -print
        }
    else
        {
            find $path -maxdepth 1 -type f -newermt $startdate ! -newermt $enddate -delete
        }
    fi
}

if [ $# -eq 3 ] || [ $# -eq 4 ]; then
    {
        delete_files $1 $2 $3 $4
    }
else
    echo "The number of arguments is not correct. Please check the command usage."
fi
