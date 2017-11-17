# AzureStackonAzure
This is a set of ARM Templates and scripts meant to enable the deployment of the Azure Stack Development Kit on an Azure VM using nested virtualization.  There are two current methodologies being explored.  The first is to use the standard Azure VM and extract the ASDK files into it and alter the VM to suit the ASDK requirements.  The second is to create the Azure VM from a custom image based on the CloudBuilder.vhdx file.  The azuredeploy.json file follows the former process and the azuredeploy-cloudbuilder.json follows the latter.  The parameters file will work with either template.

This is definitely a work in progress and not at all polished.  Feel free to ping me with questions/suggestions or fork and PR.
