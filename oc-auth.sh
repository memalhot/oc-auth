#!/bin/bash

# set class name
CLASS_NAME="classtest"

# only get a single column
oc get ns | grep "^${CLASS_NAME}-" | awk '{print $1}' | while read ns; do
    echo "Processing namespace: $ns"

    # use default service account for coverage of all pods
    
    # binding to exising role: edit
    oc create rolebinding default-edit --clusterrole=edit \
        --serviceaccount="$ns:default" -n "$ns" \
        --as system:admin

    # create a Role for Jobs CRUD
    oc create role default-edit-jobs \
        --verb=get,list,watch,create,update,patch,delete \
        --resource=jobs -n "$ns" \
        --as system:admin

    # bind the Jobs CRUD to default service account
    oc create rolebinding default-edit-jobs --role=default-edit-jobs \
        --serviceaccount="$ns:default" -n "$ns" \
        --as system:admin

    # create a Role for pod exec
    oc create role default-edit-pods-exec \
        --verb=get,list,watch,create,update,patch,delete \
        --resource=pods/exec -n "$ns" \
        --as system:admin
    
    # bind the Pod exec role to default service account
    oc create rolebinding default-edit-pods-exec \
        --role=default-edit-pods-exec \
        --serviceaccount="$ns:default" -n "$ns" \
        --as system:admin

    oc create role default-kueue-localqueue-reader \
        --verb=get,list,watch \
        --resource=localqueues.kueue.x-k8s.io -n "$ns" \
        --as system:admin
        
    oc create rolebinding kueue-localqueue-reader \
        --role=default-kueue-localqueue-reader
        --serviceaccount="$ns:default" -n "$ns" \
        --as system:admin
        
    echo " "
done