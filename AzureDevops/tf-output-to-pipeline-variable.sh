# This will grab a single variable and make it available in your ADO pipeline
res=$(terraform output -json | jq -r 'to_entries[] | select(.key=="<SOME OUTPUT FROM YOUR TERRAFORM>") | .value.value')
echo "##vso[task.setvariable variable=< VARIABLE NAME TO REFERENCE >"]${res}
