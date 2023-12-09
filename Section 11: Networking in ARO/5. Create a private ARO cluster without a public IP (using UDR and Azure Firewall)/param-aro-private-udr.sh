PREFIX="aro-private-udr"

RG="${PREFIX}-rg"

LOC="eastus"

ARONAME="${PREFIX}"

VNET_NAME="${PREFIX}-vnet"

MASTER_SUBNET_NAME="master-subnet"

WORKER_SUBNET_NAME="worker-subnet"

# DO NOT CHANGE FWSUBNET_NAME - This is currently a requirement for Azure Firewall.

FWSUBNET_NAME="AzureFirewallSubnet"

FWNAME="${PREFIX}-fw"

FWPUBLICIP_NAME="${PREFIX}-fwpublicip"

FWIPCONFIG_NAME="${PREFIX}-fwconfig"

FWROUTE_TABLE_NAME="${PREFIX}-fwrt"

FWROUTE_NAME="${PREFIX}-fwrn"

FWROUTE_NAME_INTERNET="${PREFIX}-fwinternet"
