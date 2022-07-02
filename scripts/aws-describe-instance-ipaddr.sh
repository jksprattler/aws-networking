#!/usr/bin/env bash
# script to extract and list AWS EC2 instance Names, Public IPV4 and IPV6 addresses in every region
# set your profile if running from local machine, ie: `export AWS_PROFILE=[FIXME]`

set -euo pipefail

REGIONS=$(aws ec2 describe-regions --region us-east-1 --output text --query Regions[*].[RegionName])

for REGION in $REGIONS
do
  echo -e "\nInstances in '$REGION'..";
  aws ec2 describe-instances --region "$REGION" | \
    jq -r '.Reservations[].Instances[] | "\(.Tags[]|select(.Key=="Name").Value) \(.PublicIpAddress) \(.NetworkInterfaces[].Ipv6Addresses[].Ipv6Address)"'
done
