# How to iterate on the binding code

You can develop and test the Terraform code for binding in isolation from
the broker context here.

<!--
1. Copy `terraform.tfvars-template` to `terraform.tfvars`, then edit the content appropriately.
-->
1. (For Azure services) Set these four environment variables:

    - ARM_SUBSCRIPTION_ID
    - ARM_TENANT_ID
    - ARM_CLIENT_ID
    - ARM_CLIENT_SECRET

1. In order to have a development environment consistent with other
   collaborators, we use a special Docker image with the exact CLI binaries we
   want for testing. Doing so will avoid [discrepancies we've noted between development under OS X and W10](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1262#issuecomment-932792757).

   First, build the image:

    ```bash
    docker build -t brokerpak-dev:latest .
    ```

1. Then, start a shell inside a container based on this image. The parameters
   here carry some of your environment variables into that shell, and ensure
   that you'll have permission to remove any files that get created.

    ```bash
    $ docker run -v `pwd`:`pwd` -w `pwd` -e HOME=`pwd` --user $(id -u):$(id -g) -e TERM -it --rm -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e ARM_CLIENT_SECRET brokerpak-dev:latest

    [within the container]
    terraform init
    terraform apply -auto-approve
    [tinker in your editor, run terraform apply, inspect the cluster, repeat]
    terraform destroy -auto-approve
    exit