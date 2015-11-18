# vcloud-scripts
Some scripts for Vcloud to ease mass import into Vcloud.

---

- **Requirement:**

	1. vca-vcli from Vmware.
	2. crudini package

- **Usage:**
	1. batch-import-vm.sh "CSV File" "credential file"
	
		Import OVA/OVF from a list in a CSV file into the private catalog.
		
		- CSV format:
		
			"Resource Pool,templateVapp,VappName,VappNetwork,VappIP,vCPU,vRAM,ova/ovf path"

		- Credential file:
		
			Sample file in creds-vcloud-sample

	2. batch-create-vm.sh "CSV File" "credential file"
	
		Create Vapps from a list in a CSV file.
		
	3. vcloud-api-func.
	
		Set of functions used into the scripts above. Can also be used directly on shell.
		