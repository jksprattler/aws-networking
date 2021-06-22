#!/bin/bash

# This script is capable of adding/deleting up to 4 CIDR prefixes on a DXGW's TGW
# For new regions, capture the specific region's DXGW associationIds by running below command from aws cloudshell and add a new line to the declare array
# aws directconnect describe-direct-connect-gateway-associations --direct-connect-gateway-id [insert_dxgwid]

# Define the ID of the DXGW association applied to the associationId parameter for each region hosted in your account and assign it to the below array:
declare -A associationIds
associationIds[us-east-1]=xxxx-xxxx-xxxx-xxxx-xxxx
associationIds[us-west-2]=xxxx-xxxx-xxxx-xxxx-xxxx
associationIds[ap-southeast-2]=xxxx-xxxx-xxxx-xxxx-xxxx
associationIds[eu-west-1]=xxxx-xxxx-xxxx-xxxx-xxxx
# # Below regions are not supported in AWS cloudshell as of June 2021 so either update these manually usin WebUI in tandem with the "dxgw-prefix-checkouts.sh" script or run from an EC2 instance w/ proper IAM role/policy capable of modifying DX config properties:
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
echo -e "\r\nHow many CIDR prefixes do you need to add/delete in $region (enter number 1-4)? "
read totalcidrs
if [[ "$totalcidrs" = "1" ]] ;then
     echo -e "\r\nWhat is the CIDR prefix you need to add/delete in $region (ex. 10.1.0.0/16)? "
     read cidr1
elif [[ "$totalcidrs" = "2" ]] ;then
     echo -e "\r\nWhat are the 2 CIDR prefixes you need to add/delete in $region separate them by a single space (ex. 10.1.0.0/16 10.2.0.0/16)? "
     read cidr1 cidr2
elif [[ "$totalcidrs" = "3" ]] ;then
     echo -e "\r\nWhat are the 3 CIDR prefixes you need to add/delete in $region separate them by a single space (ex. 10.1.0.0/16 10.2.0.0/16 10.3.0.0/16)? "
     read cidr1 cidr2 cidr3
elif [[ "$totalcidrs" = "4" ]] ;then
     echo -e "\r\nWhat are the 4 CIDR prefixes you need to add/delete in $region separate them by a single space (ex. 10.1.0.0/16 10.2.0.0/16 10.3.0.0/16 10.4.0.0/16)? "
     read cidr1 cidr2 cidr3 cidr4     
else 
     echo "Incorrect input for $totalcidrs, please re-run and specify a correct value for total # of CIDR's needed between 1-4, exiting"; exit
fi     
 
echo -e "\r\nYou entered Region: $region and CIDR(s): $cidr1 $cidr2 $cidr3 $cidr4 \t\tis that correct (y/n)? "
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
     echo -e "\r\nYou answered Yes, proceeding to run pre-checks for add/delete on the DXGW in $region\r\n"
else
     echo -e "\r\nYou answered No, please rerun script with correct values\r\n"; exit
fi

# Run the pre-checks to list current DXGW allowed prefixes for the given region 
today=$(date +"%m_%d_%Y")
aws directconnect describe-direct-connect-gateway-associations --association-id $associationId --query 'directConnectGatewayAssociations[*].allowedPrefixesToDirectConnectGateway' --output text > precheck-$region-cidrs-$today.txt
echo "################################################################################"
echo -e "PRE CHECKS for the current Allowed prefixes list in $region have been saved to:\r\nprecheck-$region-cidrs-$today.txt"
echo -e "################################################################################\r\n"

# Prompt user if adding or deleting the CIDR prefix
echo -e "\r\nAre you adding or deleting a CIDR prefix (add/delete)? "
read action
# Implement the action to add/delete all prefixes specified in prior inputs
if [[ "$action" = add && "$totalcidrs" = "1" ]] ;then
     # Add the new CIDR to the DXGW allowed prefix list for the given region
     echo -e "\r\n################################################################################"
     echo "ADDING THE NEW CIDR TO THE $region DXGW NOW"
     echo "PLEASE ALLOW ~5-10 MINUTES FOR UPDATING TO COMPLETE AND DO NOT EXIT SCRIPT"
     echo -e "################################################################################\r\n"
     aws directconnect update-direct-connect-gateway-association --association-id $associationId --add-allowed-prefixes-to-direct-connect-gateway cidr=$cidr1
elif [[ "$action" = add && "$totalcidrs" = "2" ]] ;then
     # Add the new CIDR to the DXGW allowed prefix list for the given region
     echo -e "\r\n################################################################################"
     echo "ADDING THE NEW CIDRs TO THE $region DXGW NOW"
     echo "PLEASE ALLOW ~5-10 MINUTES FOR UPDATING TO COMPLETE AND DO NOT EXIT SCRIPT"
     echo -e "################################################################################\r\n"
     aws directconnect update-direct-connect-gateway-association --association-id $associationId --add-allowed-prefixes-to-direct-connect-gateway cidr=$cidr1 cidr=$cidr2
elif [[ "$action" = add && "$totalcidrs" = "3" ]] ;then
     # Add the new CIDR to the DXGW allowed prefix list for the given region
     echo -e "\r\n################################################################################"
     echo "ADDING THE NEW CIDRs TO THE $region DXGW NOW"
     echo "PLEASE ALLOW ~5-10 MINUTES FOR UPDATING TO COMPLETE AND DO NOT EXIT SCRIPT"
     echo -e "################################################################################\r\n"
     aws directconnect update-direct-connect-gateway-association --association-id $associationId --add-allowed-prefixes-to-direct-connect-gateway cidr=$cidr1 cidr=$cidr2 cidr=$cidr3  
elif [[ "$action" = add && "$totalcidrs" = "4" ]] ;then
     # Add the new CIDR to the DXGW allowed prefix list for the given region
     echo -e "\r\n################################################################################"
     echo "ADDING THE NEW CIDRs TO THE $region DXGW NOW"
     echo "PLEASE ALLOW ~5-10 MINUTES FOR UPDATING TO COMPLETE AND DO NOT EXIT SCRIPT"
     echo -e "################################################################################\r\n"
     aws directconnect update-direct-connect-gateway-association --association-id $associationId --add-allowed-prefixes-to-direct-connect-gateway cidr=$cidr1 cidr=$cidr2 cidr=$cidr3 cidr=$cidr4               
elif [[ "$action" = delete && "$totalcidrs" = "1" ]] ;then
     # Delete the CIDR from the DXGW allowed prefix list for the given region
     echo -e "\r\n################################################################################"
     echo "DELETING THE CIDR FROM THE $region DXGW NOW"
     echo "PLEASE ALLOW ~5-10 MINUTES FOR UPDATING TO COMPLETE AND DO NOT EXIT SCRIPT"
     echo -e "################################################################################\r\n"
     aws directconnect update-direct-connect-gateway-association --association-id $associationId --remove-allowed-prefixes-to-direct-connect-gateway cidr=$cidr1
elif [[ "$action" = delete && "$totalcidrs" = "2" ]] ;then
     # Delete the CIDR from the DXGW allowed prefix list for the given region
     echo -e "\r\n################################################################################"
     echo "DELETING THE CIDRs FROM THE $region DXGW NOW"
     echo "PLEASE ALLOW ~5-10 MINUTES FOR UPDATING TO COMPLETE AND DO NOT EXIT SCRIPT"
     echo -e "################################################################################\r\n"
     aws directconnect update-direct-connect-gateway-association --association-id $associationId --remove-allowed-prefixes-to-direct-connect-gateway cidr=$cidr1 cidr=$cidr2
elif [[ "$action" = delete && "$totalcidrs" = "3" ]] ;then
     # Delete the CIDR from the DXGW allowed prefix list for the given region
     echo -e "\r\n################################################################################"
     echo "DELETING THE CIDRs FROM THE $region DXGW NOW"
     echo "PLEASE ALLOW ~5-10 MINUTES FOR UPDATING TO COMPLETE AND DO NOT EXIT SCRIPT"
     echo -e "################################################################################\r\n"
     aws directconnect update-direct-connect-gateway-association --association-id $associationId --remove-allowed-prefixes-to-direct-connect-gateway cidr=$cidr1 cidr=$cidr2 cidr=$cidr3 
elif [[ "$action" = delete && "$totalcidrs" = "4" ]] ;then
     # Delete the CIDR from the DXGW allowed prefix list for the given region
     echo -e "\r\n################################################################################"
     echo "DELETING THE CIDRs FROM THE $region DXGW NOW"
     echo "PLEASE ALLOW ~5-10 MINUTES FOR UPDATING TO COMPLETE AND DO NOT EXIT SCRIPT"
     echo -e "################################################################################\r\n"
     aws directconnect update-direct-connect-gateway-association --association-id $associationId --remove-allowed-prefixes-to-direct-connect-gateway cidr=$cidr1 cidr=$cidr2 cidr=$cidr3 cidr=$cidr4                
else 
     echo "Incorrect input, please re-run and specify add or delete, exiting"; exit 
fi

# Monitor the status of associating the new prefix
PROGRESS=$(aws directconnect describe-direct-connect-gateway-associations --association-id $associationId --query 'directConnectGatewayAssociations[*].associationState' --output text)
while [ "$PROGRESS" = "updating" ]; do     
     echo "################################################################################"
     echo -e "\t\t\t\tUPDATING"					
     echo -e "################################################################################\r\n"
     sleep 30;
     PROGRESS=$(aws directconnect describe-direct-connect-gateway-associations --association-id $associationId --query 'directConnectGatewayAssociations[*].associationState' --output text);
done
echo -e "\r\n################################################################################"
echo "DXGW PREFIX UPDATE ON $region FOR $cidr1 $cidr2 $cidr3 $cidr4 IS COMPLETE!"    
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