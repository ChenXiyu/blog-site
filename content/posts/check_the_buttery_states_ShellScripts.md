---
title: 查看电池电量ShellScripts
date: 2015-10-04 00:21:01
draft: true
tags:
- linux
- ShellScripts

---
在没有电源的情况下开启图形界面是很费电的，而且linux少有像win下的那种省电软件，想延长使用时间只好用字符界面咯，但是在字符界面下看电量又是一件很蛋疼的事，今天在图书馆插头没电，想看电量难道要打开xwindow看完在关闭吗？答案当然是no。但是我也不知到怎么看Orz,在google上找了一会，无果，（其实就只是看了几个帖子）看到ubuntu论坛里有一个帖子很有启发，说有个文件夹记录了电池情况，于是打算自己写一个脚本来显示电池电量。
 
步入正题：
在`/sys/class/power_supply/BAT0/`下面有些关于电池信息的文件，
其中有`energy_full`和`energy_now`
分别是电池的最大容量和现在的电池电量。看到这里，大家应该有想法了吧。下面我就直接贴上我的代码吧。
{% codeblock bn.sh %}

##!/bin/bash

declare -i full
declare -i now
declare -i battery_now

full=`cat /sys/class/power_supply/BAT0/energy_full`
now=`cat /sys/class/power_supply/BAT0/energy_now`
battery_now=now*100/full

echo "$battery_now %"
exit 0

{% endcodeblock %}

arch系其实有acpi,此shellscript在大多数linux都能使用。
