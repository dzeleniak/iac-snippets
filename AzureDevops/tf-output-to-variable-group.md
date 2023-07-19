# Overview
This shows how to take an output from your terraform and add it to a variable group in your Azure Devops Library

## YAML Step
``` yml
## Export API Key as pipeline variable
- bash: |
    # Perform configuration ( Login is done using EXT_PAT )
    az devops configure --defaults organization=$(System.TeamFoundationCollectionUri) project=$(System.TeamProjectId) --use-git-aliases true
    
    res=$(terraform output -json | jq -r 'to_entries[] | select(.key=="APIKEY") | .value.value')
    echo "##vso[task.setvariable variable=APIKEY"]${res}

    # Find the ADO Variable Group
    group_id=$(az pipelines variable-group list --group-name ${{ parameters.PROJECT_VARIABLE_GROUP_NAME }} --query '[0].id' -o json)

    # add temporary uuid variable (a variable group cannot be empty)
    uuid=$(cat /proc/sys/kernel/random/uuid)
    az pipelines variable-group variable create --group-id ${group_id} --name ${uuid}

    # Delete existing variable and recreate with new value
    az pipelines variable-group variable delete --group-id ${group_id} --name STATIC_WEBAPP_API_KEY
    az pipelines variable-group variable create --group-id ${group_id} --name STATIC_WEBAPP_API_KEY --value ${res}

    # Delete the temporary variable
    az pipelines variable-group variable delete --group-id ${group_id} --name ${uuid}

  workingDirectory: ${{ parameters.TF_WORKING_DIRECTORY}}
  displayName: Export API KEY from Terraform
  env:
    AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)
```
## Considerations
- Build Service must have Administrator access for the projects Library or Variable Group
