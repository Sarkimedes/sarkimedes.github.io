---
layout: post
title:  "Deleting merged Git branches from your local machine"
date:   2022-07-26 19:16:00 +0100
categories: Git
---

This line of PowerShell will delete local Git branches which have already been merged to `main`:

```
git branch --merged main | %{ $_.TrimStart() } | sls -NotMatch -Pattern '^(\* )?main$' | % { git branch -d $_ }
```
