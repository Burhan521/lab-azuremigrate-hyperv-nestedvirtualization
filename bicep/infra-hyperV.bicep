// Resource Group 1: Nested Hyper-V virtualization

param nestedvirtuaLocation string = 'westeurope'
param nestedvirtuaVnetName string = 'vnet-hyperv'
param nestedvirtuaVnetAddressSpace string = '10.221.0.0/24'
param nestedvirtuaDefaultSubnet string = '10.221.0.0/24'
param nestedvirtualStorageAccountName string = 'mynestedstor23121989'

// VMs
param VmSize string = 'Standard_D4s_v3'
param adminUsername string = 'microsoft'
@secure()
param adminPassword string
param VmOsType string = 'Windows' 
param VmOsPublisher string = 'MicrosoftWindowsServer' 
param VmOsOffer string = 'WindowsServer' 
param VmOsSku string = '2019-Datacenter' 
param VmOsVersion string = 'latest'

module vnet './modules/Vnet.bicep' = {
  name: 'vnet'
  scope: resourceGroup()
  params: {
    location: nestedvirtuaLocation
    vnetname: nestedvirtuaVnetName
    addressprefix: nestedvirtuaVnetAddressSpace
    defaultsubnetprefix: nestedvirtuaDefaultSubnet
  }
}

module diagnosticstorageaccount './modules/StorageAccount.bicep' = {
  name: 'diagnosticstorageaccount' 
  scope: resourceGroup()
  params:{
    storageAccountName: nestedvirtualStorageAccountName
    location: nestedvirtuaLocation
    skuName: 'Standard_LRS'
  }
}

module hyperv_vm './modules/Vm.bicep' = {
  name: 'hyperv_vm'
  scope: resourceGroup()
  params: {
    VmName: 'hyperv'
    VmLocation: nestedvirtuaLocation
    VmSize: VmSize
    VmOsType: VmOsType 
    VmOsPublisher: VmOsPublisher 
    VmOsOffer: VmOsOffer 
    VmOsSku: VmOsSku
    VmOsVersion: VmOsVersion
    VmNicSubnetId: vnet.outputs.defaultsubnetid
    adminUsername: adminUsername 
    adminPassword: adminPassword
    diagnosticsStorageUri: diagnosticstorageaccount.outputs.blobUri
    licenseType: 'Windows_Server'
    datadisksize: 1024
  }
  dependsOn:[
    vnet
    diagnosticstorageaccount
  ]
}
