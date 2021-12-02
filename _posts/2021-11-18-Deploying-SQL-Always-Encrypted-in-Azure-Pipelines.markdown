---
layout: post
title:  "CI/CD with SQL Always Encrypted"
date:   2021-11-18 11:49:00 +0000
categories: SQL CI-CD DevOps Azure-DevOps AzDOs Always-Encrypted
---

I've been working with a customer recently who is using SQL Server Always Encrypted on their database to secure database contents.
They are moving to an automated build/release pipeline for their product, and as such needed a way of deploying their databases as part of this pipeline. Broadly speaking, their application consisted of a website hosted in IIS, and databases hosted on a separate Microsoft SQL Server. The Always Encrypted keys were created from a certificate, which was deployed to the IIS server (the IIS app pool was granted access to this certificate).

![Diagram of system architecture showing relation between website, database, encryption cert, and encryption keys](/assets/images/Architecture.png)

We settled quite early on on using DAC packages (https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15#dac-concepts) to deploy the databases out.
There's a few advantages to these: 
- Database objects can be defined in Visual Studio and managed in there, as well as being source controlled
- DACPACs are declarative and for the most part idempotent (although some care needs to be taken to ensure that this is still the case when pre- and post- deployment scripts are added to the mix)

What we found pretty quickly, however, was that there's a few places where doing an automated deployment doesn't always play nicely with SQL Always Encrypted. 
To understand some of why that is, it's worth quickly going over the steps that a DACPAC will try to perform when you deploy it onto a blank DB:

1. Create the database
2. Create table schemas, users, etc.
3. Insert data using post-deployment scripts

What it won't allow us to do is to create a certificate to use with a column encryption key, or for that matter grant permissions to a certificate to use. However, the encryption key must exist before tables can be created that use that key. 
The database must also exist before an encryption key can be created, and the certificate must exist at the time the key is created.
The issue comes in because in order to bind the cert up to the encryption key, we found we needed to create the key outside of the DACPAC. This leads to a bit of a chicken-and-egg situation as the current model attempts to create the database and the columns immediately after each other which fails as there is no encryption key at that point, while creating the encryption key would fail as the database doesn't exist.

The solution to that is to split the dacpac so that it would first ensure the database existed, but do nothing else. Then we could create encyrption keys using a separate step, before running the DACPAC to deploy the rest of the artifact.
The only solution I found for that was to create a second database project inside Visual Studio, and add a same database reference to the first database project:

![Screenshot of Visual Studio showing Add Database Reference window. The reference is set to another database project in the current solution. The database location is set to "Same Database"](/assets/images/AddDBReference.png)

Note that using deployment profiles instead doesn't work, because we also wanted to stop the "minimal" deployment from running post-deployment scripts.
Building this will create a second DACPAC that did nothing but ensure the DB existed.

Additionally, there's some oddities with how query parameters have to be set up in order to insert data into a table encrypted using Always Encrypted, which can't be done using a post-deployment script in a DACPAC. 
The solution to that is to use a separate script to insert data instead of the post-deployment script - in this case we used PowerShell which called into the System.Data.SqlClient library. This was so we could pass SQL parameters in, which is a requirement when working with encrypted data.

Once that was done, the pipeline ended up consisting of the following steps. We were running these in Azure Pipelines using an agent hosted on the IIS server.

1. Deploy website
2. Ensure database exists (deploy "minimal" DACPAC)
3. Create certificate for Always Encrypted
4. Create column master key and column encryption keys
5. Grant rights to the website's IIS user to the Always Encrypted cert's private key
6. Deploy the database (deploy "main" DACPAC)

One important thing to note is that the certificate should not be created on the same machine as the SQL server. In this case the agent ran on the IIS server, although this does mean the SSDT tools needed to be installed in order to execute the DACPAC. 