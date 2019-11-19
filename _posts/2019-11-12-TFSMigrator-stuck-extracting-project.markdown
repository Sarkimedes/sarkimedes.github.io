---
layout: post
title:  Azure DevOps migrator tool stuck during "Extracting project" step in validation
date:   2019-11-12 14:33:00 +0000
categories: Azure_DevOps Migration Azure_DevOps_Server
---

Recently I worked on an Azure DevOps Server upgrade and migration to Azure DevOps Services for a client.
After upgrading Azure DevOps Server and when running the validation tool: 
```
migrator.exe validate /collection:<name>
``` 
it seemed to stick during project process validation (on "extracting Project 1 of x"). It stayed at this point for around half an hour.

Usually, this tool doesn't take long to run without at least reporting some info back.
In this case, simply restarting the tool resolved the issue.
