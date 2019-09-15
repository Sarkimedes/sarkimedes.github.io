---
layout: post
title:  "BizTalk 2016 throttling due to database size"
date:   2019-09-15 11:18:00 +0100
categories: BizTalk throttling troubleshooting
---

## The problem

Recently, a customer a reported a problem where requests which went through their BizTalk server were timing out.
If they restarted the BizTalk host instances, this restored normal operation for a few minutes, but things started timing out again after that.

### Further diagnostics

In the event log on the BizTalk server, there were messages saying that BizTalk had started throttling performance due to database size.
These were logged as warnings with an event source of **BizTalk Server**.

To dig further into it, we ran **Performance Monitor** with the following counters.

Under **BizTalk:Message Box:General Counters**:

- **Instances-Total Number**
- **Spool Size**
- **Tracking data size**

Under **BizTalk:Message Box:Host Counters**:

- **Host Queue - Instance State Msg Refs - Length**
- **Host Queue - Length**
- **Host Queue - Number of Instances**
- **Host Queue - Suspended Msgs - Length**

We also had to change the graph in Performance Monitor from a line to a report, so that we could see the relevant numbers.

This highlighted that the Spool Size was over 500,000. This is referring to the Spool table in BizTalk's message box database, which is one of the locations where physical data for messages in BizTalk are stored while BizTalk is processing them.

## What caused it

If BizTalk's message box grows too big, BizTalk will automatically start to throttle message throughput (the rule of thumb is to keep it under 5GB). There is a little bit of time between BizTalk starting up and throttling kicking in, which was why restarting the host instances restored service for a short time.

## How we solved it

There were two stages to solving this: first, manually purging the message box; and then making sure that BizTalk was automatically purging messages (credit to my colleagues [@rikhepworth](https://twitter.com/rikhepworth) and [@CaptainShmaser](https://twitter.com/CaptainShmaser) for pointing us towards the steps here).

The process for doing this was as follows:

1. Stop the BizTalk host instances
2. Execute the stored procedure **bts_CleanupMsgbox** under database **BizTalkMsgDb**. This will return an exit code (0 = success).

If this stored procedure doesn't exist, there is a script to create it called **msgbox_cleanup_logic.sql**. This is normally located on the BizTalk server under \Program Files\Microsoft BizTalk ServerSchema\ .

Purging the message didn't entirely fix the problem, as the database's transaction log also needed to be cleared up.
To do this, we needed to back the DB up (changing recovery model to Simple), and then shrink the DB files.
As the databases were in an availability group we needed to demote the DB first and then add it to the AG after we'd finished with it. 

To ensure automatic message purging happens, there is a set of SQL agent jobs that need to be enabled on the agent hosting **BizTalkMsgDb**.
The full list of SQL agent jobs in BizTalk can be found on the [Microsoft Support site](<https://support.microsoft.com/en-us/help/919776/description-of-the-sql-server-agent-jobs-in-biztalk-server>).

The important ones for this specific issue are the following:

- **MessageBox_Message_ManageRefCountLog_BizTalkMsgBoxDb**
- **MessageBox_Parts_Cleanup_BizTalkMsgBoxDb**
- **MessageBox_UpdateStats_BizTalkMsgBoxDb**
- **MessageBox_Message_Cleanup_BizTalkMsgBoxDb** - *Note: this last one needs to be present, but should be left disabled. It is called by MessageBox_Message_ManageRefCountLog_BizTalkMsgBoxDb*

## References

BizTalk perf counters:

<https://docs.microsoft.com/en-us/biztalk/core/message-box-performance-counters>

<https://docs.microsoft.com/en-us/biztalk/core/host-throttling-performance-counters>

An explanation of how BizTalk stores messages (including the role of the Spool table):

<https://gautambiztalkblog.com/2015/07/15/how-messages-are-stored-in-the-messagebox/>

Steps to purge messages taken from:

<http://www.malgreve.net/2008/08/08/how-to-purge-biztalkmsgdb/>

Steps to truncate SQL taken from:

<https://www.sqlshack.com/sql-server-transaction-log-backup-truncate-and-shrink-operations/>
