#!/usr/bin/env bash

##################################################################################################
#Title: pod_logs.sh                                                                              #
#Description: This script is designed to gather all pod logs, detailed pod information, and      #
#             events within a specified namespace.                                               #                                                                #
#                                                                                                #
#Usage: pod_logs.sh <namespace>                                                                  #
#Version: 0.1                                                                                    #
##################################################################################################

#Check if kubectl/oc command exists
if command -v kubectl &> /dev/null; then
    cmd="kubectl"
elif command -v oc &> /dev/null; then
    cmd="oc"
else
    echo "Neither kubectl or oc is installed !"
    exit 1
fi
  
namespace=$1
logdir_name="pod_logs_${namespace}_$(date +%d-%m-%Y_%H%M%S)"
logdir="/tmp/${logdir_name}"

print_usage() {
    echo "Usage: $0 [-h] <namespace>"
    echo "Options:"
    echo " -h, --help      Display this help message"
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

echo "Using output dir ${logdir}"
mkdir "${logdir}"

if [ $? -ne 0 ]; then
  echo "Error: Failed to create directory."
  exit 1
fi

#Collect all logs pod and describe
$cmd -n ${namespace} get po --no-headers | while read -r line; do
    podname=$(echo "$line" | awk '{print $1}')
    $cmd -n "$namespace" describe pod "$podname" > "${logdir}/${podname}.describe"
    for container in $($cmd get pod -n "$namespace" "$podname" -o jsonpath="{.spec.containers[*].name}"); do
        fname_log="${logdir}/${podname}.${container}.log"
        echo "$fname_log"
        $cmd -n "$namespace" logs "$podname" "$container" > "$fname_log"
        fname_previous_log="${logdir}/${podname}.${container}.previous.log"
        echo "$fname_previous_log"
        $cmd -n "$namespace" logs -p "$podname" "$container" > "$fname_previous_log" 2> /dev/null
    done
done 

#Collect all events
$cmd -n "$namespace" get events > "${logdir}/events.log"
echo "${logdir}/events.log"

#Create tarball archive
fname_tar="${logdir_name}.tar.gz"
echo "Creating tarball archive..."
cd /tmp
tar -czvf "$fname_tar" "$logdir_name" >/dev/null 2>&1

echo "Log files are located here: ${logdir}"
echo "Tarball archive is here: /tmp/${fname_tar}"
