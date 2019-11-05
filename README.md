# MPN-Helper PowerShell Module

[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fomiossec%2FMPN-Helper%2Fbadge%3Fref%3Dmaster&style=flat)](https://actions-badge.atrox.dev/omiossec/MPN-Helper/goto?ref=master)

The goals of this module is to help to add Microsoft Partner ID to any connected Azure Tenant

First we need to register a Microsoft Partner ID on the local workstation to use it later

```powershell
set-MPNHelperLocalID -MPNID xxxxx
```

Then it can be used while connected to any Azure Subscription

```powershell
set-MPNHelperID
```

You can have informtion about the current status of an Azure Subscription 

```powershell
get--MPNHelperID
```
It return a pscustomobject with the current information and if the MPN ID is alligne with the Local MPN ID registered on the workstation
