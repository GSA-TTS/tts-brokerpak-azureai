# How to iterate on the provisioning code

You can develop and test the OpenTofu (Terraform) code for provisioning in isolation from the broker context here.

1. Copy `tofu.auto.tfvars-template` to `tofu.auto.tfvars`, then edit the content appropriately. 

1. (For Azure services) Set these four environment variables:

    - ARM_SUBSCRIPTION_ID
    - ARM_TENANT_ID
    - ARM_CLIENT_ID
    - ARM_CLIENT_SECRET

1. Start a shell inside a container based on the OpenTofu tool image. The parameters
   here carry some of your environment variables into that shell, and ensure
   that you'll have permission to remove any files that get created.

    ```bash
    $ docker run -v `pwd`:`pwd` -w `pwd` -e HOME=`pwd` --user $(id -u):$(id -g) -e TERM -it --rm -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e ARM_CLIENT_SECRET --entrypoint /bin/bash ghcr.io/opentofu/opentofu:1.9

    [within the container]
    tofu init
    tofu apply -auto-approve
    [...tinker in your editor, run tofu apply, inspect the service in Azure, repeat...]
    tofu destroy -auto-approve
    exit
