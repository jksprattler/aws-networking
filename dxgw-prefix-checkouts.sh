#!/bin/bash

# For new regions, capture the specific region's DXGW associationIds by running below command from aws cloudshell and add a new line to the declare array
# aws directconnect describe-direct-connect-gateway-associations --direct-connect-gateway-id [insert_dxgwid]

# Define the ID of the DXGW association applied to the associationId parameter for each region hosted in your account and assign it to the below array:
declare -A associationIds
associationIds[us-east-1]=xxxx-xxxx-xxxx-xxxx-xxxx
associationIds[us-west-2]=xxxx-xxxx-xxxx-xxxx-xxxx
associationIds[ap-southeast-2]=xxxx-xxxx-xxxx-xxxx-xxxx
associationIds[eu-west-1]=xxxx-xxxx-xxxx-xxxx-xxxx
# Below regions are not supported in AWS cloudshell as of June 2021 so either update these manually usin WebUI in tandem with the "dxgw-prefix-checkouts.sh" script or run from an EC2 instance w/ proper IAM role/policy capable of modifying DX config properties:
associationIds[ap-southeast-1]=xxxx-xxxx-xxxx-xxxx-xxxx
associationIds[eu-west-2]=xxxx-xxxx-xxxx-xxxx-xxxx

# Prompt user for input on region, CIDR prefix and confirmation of input
echo "What region are you updating the allowed prefixes list on (ex. us-east-1)? "
read region
# Check the DXGW Association ID for the given region
associationId="${associationIds[$region]}"
if [[ -z "$associationId" ]]; then
     echo -e "\r\nERROR: '$region' is an invalid region, exiting"
     exit 1
fi

# Run the pre-checks to list current DXGW allowed prefixes for the given region 
today=$(date +"%m_%d_%Y")
aws directconnect describe-direct-connect-gateway-associations --association-id $associationId --query 'directConnectGatewayAssociations[*].allowedPrefixesToDirectConnectGateway' --output text > precheck-$region-cidrs-$today.txt
echo -e "\r\n################################################################################"
echo -e "PRE CHECKS for the current Allowed prefixes list in $region have been saved to:\r\nprecheck-$region-cidrs-$today.txt"
echo -e "################################################################################\r\n"

echo -e "\r\nPause and go to WebUI to update the DXGW allowed prefixes on $region. Did you complete updating the prefix from WebUI (y/n)? "
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
     echo -e "\r\nYou answered Yes, proceeding to run status updates on association and post-checks for add/delete on the DXGW in $region\r\n";
     echo -e "\r\n################################################################################"
     echo "PLEASE ALLOW ~5-10 MINUTES FOR UPDATING TO COMPLETE AND DO NOT EXIT SCRIPT"
     echo -e "################################################################################\r\n"
     sleep 10;
else
     echo -e "\r\nYou answered No, exiting checkouts script, you'll need to run manual post checks if you've already updated the prefixes\r\n"; exit
fi

# Monitor the status of associating the new prefix
aws directconnect describe-direct-connect-gateway-associations --association-id $associationId
PROGRESS=$(aws directconnect describe-direct-connect-gateway-associations --association-id $associationId --query 'directConnectGatewayAssociations[*].associationState' --output text)
while [ "$PROGRESS" = "updating" ]; do     
     echo "################################################################################"
     echo -e "\t\t\t\tUPDATING"					
     echo "################################################################################"
     sleep 20;
     PROGRESS=$(aws directconnect describe-direct-connect-gateway-associations --association-id $associationId --query 'directConnectGatewayAssociations[*].associationState' --output text);
done
echo -e "\r\n################################################################################"
echo "DXGW PREFIX UPDATE ON $region IS COMPLETE!"    
echo -e "################################################################################\r\n"

# Run the post-checks to list current DXGW allowed prefixes for the given region
aws directconnect describe-direct-connect-gateway-associations --association-id $associationId --query 'directConnectGatewayAssociations[*].allowedPrefixesToDirectConnectGateway' --output text > postcheck-$region-cidrs-$today.txt

echo "################################################################################"
echo -e "POST CHECKS for the current Allowed prefixes list in $region have been saved to:\r\npostcheck-$region-cidrs-$today.txt"
echo -e "################################################################################\r\n"
echo -e "Below output contains the DIFF run against the PRE and POST check files, run 'man diff' if needed:\r\n"
diff -u precheck-$region-cidrs-$today.txt postcheck-$region-cidrs-$today.txt
echo -e "\r\nBelow output contains the # of prefixes currently allowed on the $region DXGW:"
cat postcheck-$region-cidrs-$today.txt | wc -l
echo -e "\r\n################################################################################"
echo "THIS NUMBER SHOULD BE WELL BELOW THE AWS LIMIT OF 40"
echo "################################################################################"