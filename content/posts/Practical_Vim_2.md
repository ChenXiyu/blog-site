---
title: «Practical Vim» 2
date: 2015-10-11 00:05:03
draft: false
tags: [Vim]
categories: [Vim]
---

## 跳转到当前行的某个字符上
* `f{char}`,向右跳转到特定的字符{char}上.
* `F{char}`,向左跳转到特定的字符{char}上.
* `;`,正向跳转.
* `,`,反向跳转.
 
## 可视模式的几个小技巧
* `gv`,重选上次的高亮区域.(如果上次被选中的行被删除了,那执行`gv`以后可能就不是你想要的结果了)
* 在可视模式下切换选区的活动端可以使用`o`.光标会从选中区域的一端跳到另一端.

## 命令行模式
{% blockquote The Old Testament of Unix %}
在洪荒时期,先出现了ed,ed是ex之父,ex为vi之父,而vi是vim之父
{% endblockquote %}
出于历史原因，在命令行模式下执行的命令都叫做Ex命令，我们可以使用Ex命令读写文件（:edit & :write),创建新的标签（:tabnew），分割窗口（:split)，操作参数列表（:prev/:next)，操作缓存区列表（:bprev/:bnext)等等，事实上，vim为几乎所有功能添加了相应的Ex命令（参见:h ex-cmd-index)
操作缓存区文本的Ex命令：

|命令|用途|
|:---|:---| 
|:[range]delete [x]|删除指定范围内的行[到x寄存器中]|
|:[range]yank [x]|复制指定范围的行[到x寄存器中]|
|:[line]put [x]|在指定行后面粘帖寄存器x中的内容|
|:[range]copy {address}|把指定范围内的行拷贝到{address}所指定的行之下|
|:[range]move {address}|把指定范围内的行移动到{address}所指定的行之下|
|:[range]join|连接指定范围内的行|
|:[range]normal {commands}|对指定范围内的每一行执行普通模式命令{commands}|
|:[range]substitute/{pattern}/{string}/[flags]|把指定范围内出现[pattern]的地方替换成[string]|
|:[range]global/{pattern}/[cmd]|对指定范围内匹配{pattern}的所有行，在其上执行Ex命令{cmd}|
[range]的定义:{start},{end} 其中start和end都是地址。`.`代表当前行的地址，`$`代表最后一行的地址，`%`代表所有行的地址，`'<`代表高亮选区行首的位置标记，`'>`代表高亮选区的最后一行（使用V选中一段文字后接着按下:,会在底栏出现`:'<,'>`，代表接下来的命令将会做用到高亮选区上。当然start和end也可以是数字，代表从start行到end行的范围。start和end同样可以是模式，比如`:/<html>/,/<\/html>/`表示从`<html>`到`</html>`这个框框内。还可以对位置进行偏移：{address}±n，n可以是行号，位置标记，或者是一个查找模式。
### 使用`:t`和`:m`命令复制和移动行
`:t`是`:copy`的缩写,挺怪异的，你可以理解成（copy To），其另一个缩写是`:co`
用法`:[range]copy {address}`
`:move`和`:copy`命令很相似，`:m`是move的简写。
`:[range]:move {address}`
tips:重复上条Ex命令只需要输入`@:`，在运行过一次`@:`以后就可以使用`@@`来重复它。
### 使用`:normal`在指定行上运行普通模式的命令
比如你需要在整个文件的每一行加上分号，如果文件只有5行，如下

    var foo = 1 
    var bar = 'a'
    var baz = 'z'
    var foobar = foo + bar
    var foobarbaz = foo + bar + baz
你可以用如下操作:`A;<ESC>`然后连续按4次`j.`,那么如果这个文件有100行呢？要按99次`j.`吗？对于影响范围广且距离远的操作你应该要想到Ex命令，而此时的normal就能解决这个问题：
你可以使用：`A;<ESC>VG:normal .`或者更加简洁的版本：`:%normal A;`
## Ex命令补全
`<C-d>`命令会让Vim显示可用的命令列表。
让vim的命令补全类似于Bash：

    set wildmode=longest,list
让vim的命令补全模式类似于zsh：

    set wildmemu
    set wildmode=full
我偏爱zsh的补全,上诉命令可以写入`~/.vimrc`也可以在命令模式下输入
## 把光标下的单词插入到命令行中
进入命令行模式以后`<C-r><C-w>`会复制光标下的单词并把它插入到命令行中。
## 命令行窗口
输入`q:`会进入命令行窗口，其中保存了你的命令历史记录，你可以在里面编辑命令，使用`<CR>`执行该命令
输入`q/`将会进入搜索命令窗口，其中保存了你的搜索记录同样可以在里面编辑和使用`<CR>`执行
`<C-f>`会直接从命令行模式切换到命令行窗口
## 不退出vim的情况下运行系统命令
`:!{cmd}`可以调用系统命令
`:shell`可以开启一个shell，来运行系统命令，使用exit退出shell，回到vim
`<C-z>`挂起当前vim进程，使用`fg`将vim放回到前台
`:read !{cmd}`读取命令的标准输出到当前缓存中
`:write !{cmd}`将当前缓存区的内容当作标准输入给{cmd}
`[range]!{cmd}`将把[range]所指定的内容传给{cmd}做为标准输入，然后用{cmd}的标准输出替换掉[range]指定的内容.相当于一个过滤器
