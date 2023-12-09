##!/usr/bin/env bash

set -e

. ./param-aro-private-udr.sh

# Create Resource Group
az group create --name $RG --location $LOC

# Create virtual network with ARO subnets

az network vnet create --resource-group $RG --name $VNET_NAME --address-prefixes 10.0.0.0/21
	
az network vnet subnet create --resource-group $RG --vnet-name $VNET_NAME --name $MASTER_SUBNET_NAME --address-prefixes 10.0.0.0/23

az network vnet subnet create --resource-group $RG --vnet-name $VNET_NAME --name $WORKER_SUBNET_NAME --address-prefixes 10.0.2.0/23

# Dedicated subnet for Azure Firewall (Firewall subnet name cannot be changed)

az network vnet subnet create --resource-group $RG --vnet-name $VNET_NAME --name $FWSUBNET_NAME --address-prefix 10.0.4.0/24

# Create a standard SKU public IP resource that will be used as the Azure Firewall frontend address

az network public-ip create -g $RG -n $FWPUBLICIP_NAME --sku "Standard"

# Install Azure Firewall CLI extension

az extension add --name azure-firewall

# Deploy Azure Firewall

az network firewall create -g $RG -n $FWNAME -l $LOC --enable-dns-proxy true

# Configure Firewall IP Config

az network firewall ip-config create -g $RG -f $FWNAME -n $FWIPCONFIG_NAME --public-ip-address $FWPUBLICIP_NAME --vnet-name $VNET_NAME

# Capture Firewall IP Address for Later Use

FWPUBLIC_IP=$(az network public-ip show -g $RG -n $FWPUBLICIP_NAME --query "ipAddress" -o tsv)
FWPRIVATE_IP=$(az network firewall show -g $RG -n $FWNAME --query "ipConfigurations[0].privateIPAddress" -o tsv)

# Create UDR and add a route for Azure Firewall

az network route-table create -g $RG --name $FWROUTE_TABLE_NAME
az network route-table route create -g $RG --name $FWROUTE_NAME --route-table-name $FWROUTE_TABLE_NAME --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address $FWPRIVATE_IP
az network route-table route create -g $RG --name $FWROUTE_NAME_INTERNET --route-table-name $FWROUTE_TABLE_NAME --address-prefix $FWPUBLIC_IP/32 --next-hop-type Internet #needed only if you plan to use a Public Load Balancer, that would cause assymentric routing. This route would solve the assymetric routing issue.

# Associate route table with next hop to Firewall to the ARO subnet

az network vnet subnet update -g $RG --vnet-name $VNET_NAME --name $MASTER_SUBNET_NAME --route-table $FWROUTE_TABLE_NAME

az network vnet subnet update -g $RG --vnet-name $VNET_NAME --name $WORKER_SUBNET_NAME --route-table $FWROUTE_TABLE_NAME

# Create the ARO clsuter
az aro create --resource-group $RG --name $ARONAME --vnet $VNET_NAME --master-subnet $MASTER_SUBNET_NAME --worker-subnet $WORKER_SUBNET_NAME --worker-vm-size Standard_F4s_v2 --apiserver-visibility Private --ingress-visibility Private --outbound-type UserDefinedRouting --pull-secret @pull-secret.txt
