#!/bin/bash

########################################################################################################
#Title: neo4j-pod-logs.sh                                                                              #
#Description: This script is designed to gather the following neo4j db logs and configurations         #
#             - debug.log.*                                                                            #
#             - neo4j.conf                                                                             #
#             - query.log.*                                                                            #
#             - $NEO4J_HOME/data/cluster-state                                                         #
#             - $NEO4J_HOME/data/transactions                                                          #
#                                                                                             #
#Usage: neo4j-pod-logs.sh <namespace>                                                                  #
#Version: 0.1                                                                                          #
########################################################################################################

#The files are located by default within the folders '$NEO4J_HOME/logs' and '$NEO4J_HOME/conf'
neo4j_data_dir="$NEO4J_HOME/data"
neo4j_conf_dir="$NEO4J_HOME/conf"
neo4j_logs_dir="$NEO4J_HOME/data/logs"

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
logdir_name="neo4j_pod_logs_${namespace}_$(date +%d-%m-%Y_%H%M%S)"
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

#Collect logs
$cmd -n ${namespace} get po --no-headers --field-selector=status.phase==Running | grep neo4j | while read -r line; do
     podname=$(echo "$line" | awk '{print $1}')
     mkdir "${logdir}/${podname}"
     $cmd cp ${namespace}/${podname}:${neo4j_logs_dir#/} ${logdir}/${podname} --retries 10 >/dev/null 2>&1
     $cmd cp ${namespace}/${podname}:${neo4j_conf_dir#/}/neo4j.conf ${logdir}/${podname}/neo4j.conf --retries 10 >/dev/null 2>&1
     $cmd cp ${namespace}/${podname}:${neo4j_data_dir#/}/cluster-state ${logdir}/${podname}/cluster-state --retries 10 >/dev/null 2>&1
     $cmd cp ${namespace}/${podname}:${neo4j_data_dir#/}/transactions ${logdir}/${podname}/transactions --retries 10 >/dev/null 2>&1
     echo "Copying the files from ${podname} ..."
done

#Create tarball archive
fname_tar="${logdir_name}.tar.gz"
echo "Creating tarball archive..."
cd /tmp
tar -czvf "$fname_tar" "$logdir_name" >/dev/null 2>&1

echo "Log files are located here: ${logdir}"
echo "Tarball archive is here: /tmp/${fname_tar}"