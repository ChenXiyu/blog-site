---
title: 字体安装
date: 2015-10-05 22:29:08
draft: true
tags:
- font
categories:
- Tech
---
记录一下今天安装source code pro 字体的过程
 
## 字体欣赏
![](/images/install_fonts.png)
 
## source code pro 介绍
source code pro 是一款开源的等宽字体，非常适合写代码,个人认为非常漂亮，可惜中文支持的并不好看，但是在终端里面就没有几个中文，所以设置成终端字体是非常棒的。[source code pro github repos](https://github.com/adobe-fonts/source-code-pro)
## 下载
```
wget https://github.com/adobe-fonts/source-code-pro/archive/2.010R-ro/1.030R-it.tar.gz
```
## 安装
### 解包
```
tar -xvf source-code-pro-2.010R-ro-1.030R-it.tar.gz
```
### 拷贝到**`~/.fonts/`**下
```
mkdir ~/.fonts 
cp source-code-pro-2.010R-ro-1.030R-it/OTF/*.otf ~/.fonts/
```
### 安装
```
fc-cache -f -v
```
## 全局安装
如果你想全局安装该字体请将**`~/.fonts/`**替换为**`/usr/local/share/fonts/`**
## fc-cache
fc-cache - build font information cache files
