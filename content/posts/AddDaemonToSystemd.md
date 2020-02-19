---
title: 做一个Systemd的Daemon
date: 2015-11-04 22:35:47
draft: true
tags: [systemd]
---

以前都是使用supervisor来启动需要自动启动的进程,比如说:shadowsocks,minecraft的服务器端等等.以前在使用Archlinux的时候shadowsocks的进程是做成一个systemd的daemon的,今天在和赵睿大神交谈后提到了这个问题,于是开始在[ArchWiki](wiki.archlinux.org)中学习将一个进程做成Daemon的方法,记录如下:
 
## 步骤介绍
1. 在`/usr/lib/systemd/system`或者`/etc/systemd/system`(经依云指正,推荐个人用户将systemd的配置文件放在/etc/systemd下)目录下写入该Daemon的配置文件,
2. 运行`systemctl daemon-reload`让systemd重新加载daemon配置文件
3. 此时就能使用`systemctl`来管理我们的daemon了

## 配置文件
先贴出[文档](http://www.freedesktop.org/software/systemd/man/systemd.unit.html)
一般情况下配置文件有三个段:分别是**Unit**,**Service**,**Install**.
1. Unit:一般写入该daemon的基本信息,比如:description等等
2. Service:一般写入该daemon运行的命令,运行用户,运行优先级等
3. Install:使用systemctl enable 让daemon开机自启需要这个段的内容.

看看我shadowsocks Daemon的例子把:

        [Unit]
        Description=shadowsocks local 
        After=network.target
        [Service]
        ExecStart=/usr/bin/sslocal -c /etc/shadowsocks.json
        [Install]
        Alias=ShadowSocksLocalServer.service
现在有个问题:我在enable 该service以后,开机还是没有自动启动,用systemctl status 查看状态是属于enable状态的.
## 相关链接
1. [SysV](https://wiki.archlinux.org/index.php/SysVinit_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)
2. [LSB](https://zh.wikipedia.org/wiki/Linux%E6%A0%87%E5%87%86%E8%A7%84%E8%8C%83)
