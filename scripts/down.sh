#!/bin/bash
set -eo pipefail

# Work around the broker not having a command like `csb client list` by tracking the
# instances and bindings we've created.

if [ "$#" -lt 1 ]; then
  printf "Usage:\n\n\t\$./down.sh /path/to/workdir\n\nWorking directory must match the directory passed to up.sh."
  exit 1
fi

workdir=$1

csb=cloud-service-broker
planid=d9575f01-1d5b-4196-bea8-e0d59b6ccfd9
serviceid=2b89aa85-00c8-4507-a74b-c8f7ce95bf27

cat "${workdir}/bindings.txt" | xargs -n 2 bash -c 'cloud-service-broker client unbind --config clientconfig.yml --planid d9575f01-1d5b-4196-bea8-e0d59b6ccfd9 --serviceid 2b89aa85-00c8-4507-a74b-c8f7ce95bf27 --instanceid $1 --bindingid $2' -
echo "\n\n$(date)" >> bindings.txt.history
cat ${workdir}/bindings.txt >> ${workdir}/bindings.txt.history
rm ${workdir}/bindings.txt

cat "${workdir}/instances.txt" | xargs -I % $csb client deprovision --config clientconfig.yml --planid $planid --serviceid $serviceid --instanceid %
echo "\n$(date)" >> instances.txt.history
cat ${workdir}/instances.txt >> ${workdir}/instances.txt.history
rm ${workdir}/instances.txt

echo "Done. instances.txt and bindings.txt cleared. History recorded in instances.txt.history and bindings.txt.history."
