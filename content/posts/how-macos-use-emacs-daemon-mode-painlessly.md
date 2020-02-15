---
title: MacOS 下无痛使用emacs daemon mode
date: 2017-06-14 10:16:11
draft: true
tags:
- emacs
- MacOs
categories:
- emacs
---
OK, 既然说是无痛，那么我先解释一下我关于使用‘传统’方式打开emacs的痛点：
<!--more-->
- 启动慢（虽然不是很慢而我也并没有经常重启），其实启动慢主要体现在，我在GUI中使用emacs编辑文件，在terminal下想做一次git commit类似的操作，有时这个操作需要打开一个默认的编辑器，而我设置的这个编辑器就是emacs，传统做法上就是直接打开一个emacs的进程，这个进程会重新读取配置文件，加载一份新的进程
- 在GUI里面打开的文件，在terminal中不能编辑

使用emacs daemon 就能解决上述痛点，只有一个emacs daemon进程，buffer在不同的emacs client将是可以共享的，而terminal上的默认编辑器设置为emacs client的话，每次打开消耗的时间就只有一个连接emacs daemon的时间，几乎是秒开。<!--more-->
本笔记记录一种在MacOs下使用Emacs daemon mode的方式，该方案会在第一次试图打开emacs的时候启动emacs daemon，然后开始运行emacs client，如果emacs daemon在运行，就会直接打开emacs client。
当然啦，emacs daemon的打开方式也可以是在开机的时候就启动，个人认为这样有一个缺点：拖慢开机速度，但是，对于我来说区别不大，我的Mac不是频繁的重启，但是我还是选择在第一次试图使用emacs的时候再启动。
以daemon模式启动emacs是很简单的，在任何命令行环境使用如下命令便可启动emacs daemon
```Bash
  /path/of/emacs --daemon
```
我的需求是：
- spotlight／Alfred 启动Emacs daemon 并且打开 Emacs client
- spotlight／Alfred 关闭（重启）Emcas daemon
- Emacs client 以GUI方式启动

没有使用Alfred的同学可以使用spotlight + [Automator](https://zh.wikipedia.org/wiki/Automator) 来实现，Automator是MacOS自带的一个工具，
这个工具允许用户定义一个工作流程，这个工作流程可以包含一系列预定义的动作，而我们用它来定义一个工作流，这个工作流里面有一个动作，就是运行一个启动Emacs daemon的脚本程序。
使用Alfred来实现的话，思路是一样的，Alfred 有workflow，所以不需要使用Automator。下面将列出两个脚本，分别用于启动和关闭emacs daemon。
## 打开Emacs daemon
```Bash
  ([ -n "$(ps aux |  grep -v grep | grep -i 'emacs.*--daemon')" ] || /usr/local/bin/emacs --daemon) && /usr/local/bin/emacsclient -c -n &
```
这段脚本的作用是：如果当前没有emacs daemon进程在运行，那么用 `/usr/local/bin/emacs --daemon` 命令去启动emacs daemon，并且在启动后，打开emacs client，
如果有emacs daemon进程在运行，直接运行 `/usr/local/bin/emacsclient -c -n &` 来启动emacs client 用于文本编辑
## 杀掉Emacs daemon
```Bash
if(test -n "$(ps aux | grep -v grep | grep -i 'emacs.*--daemon')") then
  /usr/local/bin/emacsclient -e '(kill-emacs)'
fi
```
这条命令的作用是：使用emacs client 给emacs daemon 发送一段e-lisp 代码让daemon 运行，而这段e-lisp代码就是用来让daemon 自杀的，如果daemon已经卡死了，那么这段代码是没有办法杀掉daemon的，只能给daemon发送 `kill -9` 了
具体使用Automator的步骤就不赘述了，不管是使用Automator + spotlight 还是使用Alfred，只要创建两个工作流，分别使用上述两个命令就可以了。
