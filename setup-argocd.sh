#!/bin/bash

LANG=C

echo ""
echo "Installing Argo CD Operator."

oc apply -k 00-setup/argocd-operator

echo "Pause 10 seconds for the creation of the InstallPlan."
sleep 10

echo "Approving operator installation."
IPNAME=$(oc get installplan -n argocd -o jsonpath='{range .items[*].metadata}{.name}{end}')
echo "($IPNAME)"
oc patch -n argocd installplan $IPNAME --type=json -p='[{"op":"replace","path": "/spec/approved", "value": true}]'

echo "Pausing for 10 seconds for operator initialization..."

sleep 10

oc rollout status deploy/argocd-operator -n argocd

echo "Listing Argo CD CRDs."
oc get crd | grep argo


echo "Deploying Argo CD instance"

oc apply -k 00-setup/argocd

echo "Waiting for Argo CD server to start..."

sleep 15

oc rollout status deploy/argocd-server -n argocd

echo "Argo CD ready!"
