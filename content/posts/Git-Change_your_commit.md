---
title: 'Git:更改你的提交'
date: 2015-08-15 18:15:23
draft: false
tags:
- git

---
只要没有人有该版本库中的某个部分的副本，那么你就可以修改该部分的提交,如果一个分支公开了，可能存在于其他版本库中，那么你就不应该重写或修改该分支的任何已公开部分。
 
## git reset 
该命令会将版本库和工作目录改变为已知状态。git reset 调整HEAD引用指向给定的提交，默认情况下还会更新索引以匹配该提交。**破坏性强**。
git reset 有三个主要的选项：\--soft,\--mixed,\--hard
* \--sort
    将HEAD引用指向给定的提交，索引和工作目录的内容保持不变。
* \--mixed(默认选项)
    将HEAD引用指向给定的提交，索引内容也跟着改变以适应新的提交，工作目录的内容不改变。
* \--hard
    HEAD指向给定提交，索引内容也改变以符合新HEAD，工作目录改变为索引，前面为提交的工作将全部丢弃。

|选项|HEAD|索引|工作目录|
|:---------:|:-----------:|:------------:|:-----------:|
|\--soft|T|F|F|
|\--mixed|T|T|F|
|\--hard|T|T|T|
git reset 将把原始的HEAD值放到`ORIG_HEAD`中
### 常见用法
* 恢复索引
    根据git reset 默认选项为--mixed可以想到一个应用场景：你将某个文件修改了，并且使用git add将其加入到索中了，但是现在你想将索引恢复到原来的状态，这时你就可以使用`git reset HEAD [FILENAME]`来使索引恢复到原来的样子了。
* 重做或清除分支上的最近提交
    在你的git仓库中，如果你觉得你最近的提交是不漂亮的，想重新规划该提交，这时你就可以使用git reset命令来是HEAD切换到master^上去，然后修改为你觉得漂亮的一个版本，然后再提交。使用git reset的时候可以根据需要选择前面介绍的三个选项。(尽量不要这么做，因为后面将介绍的git commit --amend设计来专门做这个)当然，如果你想抛弃很多个提交来在某个历史节点上来构建新的历史git reset是可以做到的。

**注意**:千万不要使用git reset在不同分支间来修改HEAD，git reset将不会切换分支，这样新的提交很大可能不是你想要的，尽量避免，改变分支应该使用git checkout。
## git cherry-pick
在当前分支上应用给定提交引入的变更(pick某个历史记录中的提交，将其引入的变更patch到当前分支的HEAD上),可见命名也是非常形象的！
### 常见用法
- 把版本库中一个分支的特定提交引入到一个不同的分支中
    etc:在dev分支中修复了一个bug并提交了F，在release分支中也有这个bug，但是现在dev分支的HEAD在H上，合并可能引入G和H未成熟的代码，所以使用git cherry-pick来将F提交直接应用到release分支上就可以了。
- 重建一系列提交，通过一个分支选定一部分提交，然后把他们按不同序列引入新分支
    主要用于需要打乱提交序列的引入。其参数允许为提交的范围，如:x..z

## git revert
与git cherry-pick大致相同，但是它是应用给定提交的你过程。它会引入一个新的提交来抵消给定提交的影响。git revert不修改历史记录，相反的是它向历史记录中添加一个新的提交,该命令是用于整个提交。
### 常见用途
- 撤销可能深埋在历史记录中的某个提交的影响。
    比如要撤销master的操作，可以使用`git revert master`这样在master分支上会新建一个提交，该提交应该是和执行命令的master~1是一样的。

## git commit --amend
用于修改当前分支最近一次提交。使用这条命令意味着提交内容基本相同，但是需要某些方面的调整或者清理。该命令还可以编辑提交的元信息，比如联系人，邮箱地址等。
### 常见用途
- 在刚刚作出提交后，修改录入提交的错误。

## git rebase
用来改变一串提交以什么为基础,git rebase可以将分支在其他分支上向前/后移植(嫁接)
### 常见用途
- 保持你正在开发的一系列提交相对于另一个分支是最新的
    那通常是master或者另一个版本库的追踪分支
- 配合--onto选项，把一条分支上的开发线整个一直到完全不同的分支上。

变基操作一次只迁移一个提交，从各自原始提交位置迁移到新的提交基础，每一个移动都可能有冲突需要解决。如果发现冲突，rebase操作会临时挂起进程以便手动解决冲突，一旦冲突解决完毕，索引都更新了以后，使用`git rebase --continue`命令恢复变基操作。如果你觉得该提交没有价值可以使用`git rebase --skip`来跳过这个提交。如果你认为不应该进行变基操作，可以使用`git rebase --abort`来中止操作，并把版本库恢复到变基之前的状态。
### git rebase -i
`-i --interasctive`,该命令允许你对历史提交进行重新排序，编辑，删除，合并多个提交或把一个提交分离为多个提交。
`$ git rebase -i master~3`  
你将到编辑器里面编辑一个文件：
```
 pick 68d8d3e second commit
 pick 5844135 third commit

 ## Rebase 69b916d..5844135 onto 69b916d (2 command(s))
 ##
 ## Commands:
 ## p, pick = use commit
 ## r, reword = use commit, but edit the commit message
 ## e, edit = use commit, but stop for amending
 ## s, squash = use commit, but meld into previous commit
 ## f, fixup = like "squash", but discard this commit's log message
 ## x, exec = run command (the rest of the line) using shell
 ##
 ## These lines can be re-ordered; they are executed from top to bottom.
 ##
 ## If you remove a line here THAT COMMIT WILL BE LOST.
 ##
 ## However, if you remove everything, the rebase will be aborted.
 ##
 ## Note that empty commits are commented out
```
前两行列出你在命令行里面指定的可编辑的提交范围内的提交，提交最初是按照从老到新的顺序排列的，每个提交都有一个动词`pick`,如果你离开编辑器，这些提交将被按照顺序被pick，应用到目标分支上，然后提交。根据文件中的提示，pick可以改为reword，edit，squash，fixup，exec或者直接删掉该行.
