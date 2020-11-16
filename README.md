# New Relic SCOM Management Pack migration guide

This guide will help you replace your existing SCOM management packs with an existing or custom built New Relic integration. New Relic provides a lot of functionality out of the box, so whenever possible those capabilities are used. The guide focussed on data retrieval, not recreating the alerts and reports from SCOM Management packs.

To get an idea of all the current packs installed you can run `Get-SCOMManagementPack | Select-Object Name,Version,FriendlyName,Description,DefaultLanguageCode |  Export-Csv scom-management-packs.csv`. Review the `scom-management-packs.csv` to see which packs are critical, as not all will be currently actively used to monitor an environment.

## Guide

For each management pack you want to replace, do the following:

### 1) Check existing replacements folder

Within this repository you can find a directory called [management packs](https://github.com/kidk/scom-tools/tree/main/management-packs) which contains existing replacement guides and scripts for management packs. Check if the one you want to replace is listed there.

### 2) Unseal SCOM Management pack

### 3) Find script behind metrics

### 4) Check if New Relic supports metric out of the box

### 5) If not, recreate functionality using Flex.

#### 5a) VBScript

#### 5b) Powershell

#### 5c) ...

### 6) Share your knowledge by creating a pull request

