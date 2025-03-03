#!/bin/bash
set -eo pipefail

if [ "$#" -lt 1 ]; then
  printf "Usage:\n\n\t\$./up.sh /path/to/workdir\n\n"
  exit 1
fi

workdir=$1

csb=cloud-service-broker
planid=d9575f01-1d5b-4196-bea8-e0d59b6ccfd9
serviceid=2b89aa85-00c8-4507-a74b-c8f7ce95bf27

# Instance IDs must be unique, so generate a new one
instanceid=$(uuidgen | tr "[A-Z]" "[a-z]")
echo "Instance ID: $instanceid"

# Start provisioning
$csb client provision --config clientconfig.yml --planid $planid --serviceid $serviceid --instanceid $instanceid --params "{\"model_name\": \"gpt-4o\", \"model_version\": \"2024-11-20\"}"

# Wait on provisioning to finish
state=""
while [[ "$state" != "succeeded" ]]; do
	sleep 10
	state=$($csb client --config clientconfig.yml last --instanceid $instanceid | jq -r '.response.state')
	echo "State: $state"
done

touch "$workdir/instances.txt"
echo $instanceid >> "$workdir/instances.txt"

# Let the broker settle
sleep 1

# Binding IDs must be unique, so generate a new one
bindingid=$(uuidgen | tr "[A-Z]" "[a-z]")
echo "Binding ID: $bindingid"
touch "$workdir/bindings.txt"
echo "$instanceid $bindingid" >> "$workdir/bindings.txt"

# Update smtp-client with new credentials
$csb client bind --config clientconfig.yml --planid $planid --serviceid $serviceid --instanceid $instanceid --bindingid $bindingid | jq '.response.credentials' > "$workdir/credentials.json"

echo "Done. Credentials saved to credentials.json for use with the client. GUIDs saved to instances.txt and bindings.txt. Deprovision later with down.sh."
