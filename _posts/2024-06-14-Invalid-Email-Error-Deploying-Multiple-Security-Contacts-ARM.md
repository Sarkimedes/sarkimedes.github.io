---
layout: post
title:  "\"The provided email's format isn't valid\" when setting up email alerts from Defender for Cloud via ARM"
date:   2024-06-14 18:31:00 +0100
categories: Azure Azure_Policy Defender_For_Cloud ARM_Templates ARM
---

I've been looking at how to use Azure Policy to configure email alerts from Defender for Cloud across an Azure subscription. To do this, I'm using a `deployIfNotExists` policy effect to deploy an ARM template if a subscription doesn't have any email notifications set up in Defender.
Said ARM template looks something like this:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "emailSecurityContact": {
      "type": "string",
      "metadata": {
        "description": "Security contacts email address"
      }
    },
    "minimalSeverity": {
      "type": "string",
      "metadata": {
        "description": "Minimal severity level reported"
      }
    },
    "minimalRiskLevel": {
      "type": "string",
      "metadata": {
        "description": "Minimal attack path risk level to alert on"
      }
    }
  },
  "variables": {},
  "resources": [
    {
      "type": "Microsoft.Security/securityContacts",
      "name": "default",
      "apiVersion": "2023-12-01-preview",
      "properties": {
        "emails": "[parameters('emailSecurityContact')]",
        "isEnabled": true,
        "notificationsByRole": {
          "state": "On",
          "roles": [
            "Owner"
          ]
        },
        "notificationsSources": [
          {
            "sourceType": "Alert",
            "minimalSeverity": "[parameters('minimalSeverity')]"
          },
          {
            "sourceType": "AttackPath",
            "minimalRiskLevel": "[parameters('minimalRiskLevel')]"
          }
        ]
      }
    }
  ],
  "outputs": {}
}
```

I can test this using something like the following command (other methods of deploying ARM templates are available), and it works quite happily:
```powershell
New-AzSubscriptionDeployment `
  -TemplateFile .\securityContacts_ARM.json `
  -Location uksouth `
  -emailSecurityContact 'peter@example.nxdomain' `
  -minimalSeverity "High" ` 
  -minimalRiskLevel "Critical"
```

The stumbling block comes in when I try and set multiple email addresses. In the Azure Portal, you do this by entering a comma-separated list of addresses. Naturally I assumed that the ARM template would take in something similar:

```powershell
New-AzSubscriptionDeployment `
  -TemplateFile .\securityContacts_ARM.json `
  -Location uksouth `
  -emailSecurityContact 'peter@example.nxdomain, bob@example.nxdomain' `
  -minimalSeverity "High" `
  -minimalRiskLevel "Critical"
```

However, this spits out an error:

```
Status Message: The json value of emails failed validation, with reason: 
Emails : The provided email's format isn't valid. 
Please change it to a valid email address and try again., error tracking number: 4f68ad67-75a5-495c-8b44-52a307e5f8df (Code:BadRequest)
```

It turns out the fix is fairly simple, but the ARM template docs for this resource are totally lacking in examples so I only stumbled across it by looking up the Azure CLI command to do the same thing. Instead of using a comma, use a semicolon to separate your email list:

```powershell
New-AzSubscriptionDeployment `
  -TemplateFile .\securityContacts_ARM.json 
  -Location uksouth `
  -emailSecurityContact 'peter@example.nxdomain;bob@example.nxdomain' `
  -minimalSeverity "High" `
  -minimalRiskLevel "Critical"
```

This will give you the following result: 
![Working email alert config](/assets/images/DeployedAlerts.PNG)

