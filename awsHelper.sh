#!/usr/bin/env bash

command=${1}
intip=${2}


function getpubip {
    aws ec2 describe-instances | grep IpAddress | grep -B1 -A1 ${intip} |grep PublicIpAddress | grep -o -P "\d+\.\d+\.\d+\.\d+"

}


case "$command" in
      getawspub)
        getpubip intip
        ;;

      *)
       echo $"Usage: $0 {getawspub 10.0.0.1}"
       exit 1
       ;;
esac



