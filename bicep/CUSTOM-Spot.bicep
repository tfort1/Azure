param adminUsername string
param enableAcceleratedNetworking bool
param licenseType string
param location string
param networkInterfaceName string
param offer string
param osDiskName string
param osDiskType string
param publisher string
param secureBoot bool
param securityType string
param sku string
param subnetName string
param timeZone string
param virtualMachineComputerName string
param virtualMachineName string
param virtualMachineSize string
param virtualNetworkId string
param vTPM bool

@secure()
param adminPassword string

var vnetId = virtualNetworkId
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterface 'Microsoft.Network/networkInterfaces@2017-06-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
  }
  dependsOn: []
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        name: osDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: publisher
        offer: offer
        sku: sku
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        timeZone: timeZone
        enableAutomaticUpdates: false
      }
    }
    licenseType: licenseType
    priority: 'Spot'
    evictionPolicy: 'Deallocate'
    billingProfile: {
      maxPrice: -1
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output adminUsername string = adminUsername