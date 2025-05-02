# Log management scripts
This repository contains log management scripts designed to assist with daily operations and maintenance tasks.

* **log-archived.sh** script archive all log files from a directory, encompassing a specified period from the start date to the end date.
* **log-cleaner.sh** script remove all log files from a directory, encompassing a specified period from the start date to the end date.
* **pod-logs.sh** script gather all logs, detailed pod information, and events within a specified namespace.
* **neo4j-pod-logs.sh** script is designed to gather the following neo4j db logs and configurations "debug.log.*", "neo4j.conf", "query.log.*",
    "$NEO4J_HOME/data/cluster-state" and "$NEO4J_HOME/data/transactions"
                                         