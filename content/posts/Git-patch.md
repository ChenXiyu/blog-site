---
title: Git补丁
tags:
  - git
date: 2015-11-10 12:17:44
draft: false
---
git除了使用push/pull来在不同仓库将传输变更外还提供了一种比较‘古老’的方式来传输变更，那就是补丁.补丁通过邮件发送，如果是公司内网，禁掉了git原生协议/ssh端口/http协议的话，我们没法push或者pull变更，那么现在将补丁通过邮件发送是一个不错的选择。git 实现了三条特定的命令来帮助交换补丁：
 
* git format-patch 用于生成email形式的补丁;
* git send-email 通过SMTP来发送一个git补丁;
* git am 应用邮件消息中的补丁;

## 生成补丁
**git format-patch**会已邮件消息的形式生成补丁（每个提交都会生成一封邮件）。
常用的用例包括：
* 特定的提交次数: -1/-3/-6
* 提交范围：master～4..master～2
* 单次提交： origin/master

git diff机制是生成补丁的核心，git format-patch生成的内容就是在git diff的内容上加上邮件头，提交信息和提交日志等来形成一封邮件。

	$ mkdir /tmp/GitTest 
	$ cd $_
	$ git init
	$ echo A >> file 
	$ git add file
	$ git commit -m "init commit"
	$ echo B >> file ; git commit -am "B commit"
	$ echo c >> file ; git commit -am "c commit"
	$ echo d >> file ; git commit -am "d commit"
至此我已经创建了一系列的提交：

	+-------+   +-------+   +-------+   +-------+
	|       |   |       |   |       |   |       |
	|   A   |---|   B   |---|   C   |---|   D   |
	|       |   |       |   |       |   |       |
	+-------+   +-------+   +-------+   +-------+
为最近n次提交生成补丁，使用**-n**选项：

	$ git format-patch -1
	0001-d-commit.patch
	$ git format-patch -2
	0001-c-commit.patch
	0002-d-commit.patch
其中各个patch对应的提交如下图所示:

	+-------+   +-------+   +-------+   +-------+
	|       |   |       |   |       |   |       |
	|   A   |---|   B   |---|   C   |---|   D   |
	|       |   |       |   |       |   |       |
	+-------+   +-------+   +-------+   +-------+
	                 \          /\          /
	                  \        /  \        /
	                   \      /    \      /
	                    \    /      \    / 
	                     \  /        \  / 
	                      \/          \/
	          0001-c-commit.patch   0002-d-commit.patch
使用`git format-patch master~2..master`效果同上。
查看一下patch的内容：

	$cat 0001-c-commit.patch
	From 6f0a3e7cfea16fd65e699aa7d67d6179f710ff07 Mon Sep 17 00:00:00 2001
	From: ChenXiyu <xycinus@gmail.com>
	Date: Tue, 10 Nov 2015 10:50:46 +0800
	Subject: [PATCH 1/2] c commit

	---
	 file | 1 +
	 1 file changed, 1 insertion(+)

	diff --git a/file b/file
	index 3042490..c2e990f 100644
	--- a/file
	+++ b/file
	@@ -1,3 +1,4 @@
	 A
	 B
	 B
	 +c
	-- 
	2.4.3
可以看到前面一部分是邮件的头，后面一部分实际是一个diff。
当我们遇到更加复杂分支时，补丁又将如何工作呢？比如我的版本库是这个样子：

	+-------+   +-------+   +-------+   +-------+   +-------+   +-------+
	|       |   |       |   |       |   |       |   |       |   |       |
	|   A   |---|   B   |---|   C   |---|   D   |---|   e   |---|   F   |       master
	|       |   |       |   |       |   |       |   |       |   |       |
	+-------+   +--+----+   +-------+   +-------+   +-+-----+   +-------+
                	\                                /
                  	+-------+   +-------+   +-------+
                  	|       |   |       |   |       |
                  	|   X   |---|   Y   |---|   Z   |                         alt
                  	|       |   |       |   |       |
                  	+-------+   +-------+   +-------+
当你想要在提交F和提交D之间生成补丁的话：

	$ git format-patch master~2..master
	0001-x-commit.patch
	0002-y-commit.patch
	0003-z-commit.patch
	0004-f-commit.patch
这也不难理解，要从提交D到提交F，必须将XYZ提交的所有变更应用到提交D上，而合并提交e是没有产生任何变更，所以合并提交是不生成补丁的，依次将提交XYZf的补丁打到提交D上，就能得到与提交F一模一样的内容。顺便提一下git中提交范围的计算方式：终点能回溯到达的提交减去起点能回溯到达的提交。比如上述的master～2..master这个提交范围，终点是master，终点能回溯到达的提交就是FEDCBAZYX，起点是master～2,起点能回溯到达的提交是DCBA，那么终点能回溯到达的提交减去起点能回溯到达的提交为FEZYX。
在复杂分支的情况下，如果你不确定你接下来运行git format-patch 会对哪些提交生成补丁，那么你可以使用`git rev-list --no-merge -v since..until`来验证将要生成补丁的提交。
## 邮递补丁
在生成了一系列补丁后，下一步就是通过邮件发送给另一个开发者或者发到邮件列表用于代码审查，你可以使用**git send-email**或者直接导入电子邮件用户代理（Mail User Agent）来发送邮件
ps:要使用git send-email命令你可能需要额外安装git-email包

	$git send-email -to xycinus@gmail.com 0001-c-commit.patch
	(mbox) Adding cc: ChenXiyu <xycinus@gmail.com> from line 'From: ChenXiyu <xycinus@gmail.com>'

	From: ChenXiyu <xycinus@gmail.com>
	To: xycinus@gmail.com
	Subject: [PATCH 1/3] B commit
	Date: Tue, 10 Nov 2015 12:51:42 +0800
	Message-Id: <1447131102-25455-1-git-send-email-xycinus@gmail.com>
	X-Mailer: git-send-email 2.4.3

	The Cc list above has been expanded by additional
	addresses found in the patch commit message. By default
	send-email prompts before sending whenever this occurs.
	This behavior is controlled by the sendemail.confirm
	configuration setting.

	For additional information, run 'git send-email --help'.
	To retain the current behavior, but squelch this message,
	run 'git config --global sendemail.confirm auto'.

	Send this email? ([y]es|[n]o|[q]uit|[a]ll): y
	OK. Log says:
	Sendmail: /usr/sbin/sendmail -i xycinus@gmail.com
	From: ChenXiyu <xycinus@gmail.com>
	To: xycinus@gmail.com
	Subject: [PATCH 1/3] B commit
	Date: Tue, 10 Nov 2015 12:51:42 +0800
	Message-Id: <1447131102-25455-1-git-send-email-xycinus@gmail.com>
	X-Mailer: git-send-email 2.4.3

	Result: OK
然后出现下面的错误，邮件没有发出去

	No configuration file found at /home/cxy/.esmtprc or /etc/esmtprc
应该是邮件服务器问题，我还没有折腾过邮件服务，先这样把，知道这样能够发送补丁到邮件列表或者邮箱。
## 应用补丁
Git有两条基本命令来应用补丁，分别是git am 和 git apply，其中git am 较git apply更加高级，git apply 相当于diff-patch命令中的patch，用于将补丁打到特定文件中，也就是git apply负责根据补丁对文件进行修改，而git am将根据邮件的头（form，date，subject等）内容来构造提交，所以在应用补丁时git apply是个主力，但是你并不需要手动运行它。
如果补丁中包含多个分支，就像上面的情况一样，注意使用三路合并(-3)的方式解决冲突，不然，应用补丁将不会成功。

	$ git am -3 /path/to/patch/*.patch
如果需要手动解决冲突，那么停下来等待你手动解决冲突。冲突解决后使用

	$ git am -3 --resolved
继续打补丁。直到成功。如果想终止打补丁的操作，那么可以使用

	$ git am --abort
来终止打补丁的操作。你也可以使用在当个补丁失败时选择跳过某个补丁
	
	$ git am --skip
