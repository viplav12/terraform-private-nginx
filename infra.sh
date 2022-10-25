#!/usr/bin/env bash
echo "*****Initializing terraform with a local backend*****"
terraform init
echo "***** Terraform plan file *****"
terraform plan
echo "***** Terraform apply *****"
terraform apply
echo "***** Combining README and terraform module usage in Release Notes *****"
echo "Defining Release Notes file ..."
MODULE_FILE="$(pwd)/Module.md"
RELEASE_NOTES="$(pwd)/Release-Notes.md"
echo "Copy the content of README to Release Notes"
cp "$(pwd)/README.md" "${MODULE_FILE}"
printf "\n# Module Usage\n" >> "${MODULE_FILE}"
echo "Check if the release notes are already present"
if [ -f "$RELEASE_NOTES" ]; then
  echo "Release Notes already present"
else
  echo "***** Publishing Release Notes *****"
  docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs >> ${MODULE_FILE}
  cp "${MODULE_FILE}" "${RELEASE_NOTES}"
fi
echo "Everything Done...!! Happy assignment !!"