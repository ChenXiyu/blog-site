---
title: «Practical Vim» 1
date: 2015-10-07 00:12:53
draft: false
tags: [Vim]
categories: [Vim]
---
vim使用小技巧,鉴于大家都没有时间看长博文,我把它分成短文.
## 1. `<C-a>` `<C-x>`对数字执行加减操作
* `[count]<C-a>`来使光标下的数字增加count
* `[count]<C-x>`使光标下的数字减小count


如果没有[count]，那么光标下的数字会逐一加减，再不济，光标没有在数字上也没关系，执行该命令后，会在当前行向后查找数字，并执行在第一个数字上。
***注意***: 0开头的数字表示八进制，0x开头的数字代表十六进制，所以在07和0xa上执行`<C-a>`的结果分别为：010和0xb。
## 2. 大小写反转
1. 选中一段字符，`u`,将所有字符变为小写。
2. 选中一段字符，`U`，将所有字符变为大写。
***注意****: 以上用法是在选中一段字符的基础上，不然将会执行`u`命令，撤销了上一步操作。
3. `g~`,反转大小写
4. `gu`,转换为小写,作用类似于1
5. `gU`,转换为大写,作用类似于2

## 3. 显示tab缩进
{% codeblock .vimrc %}
set listchars=tab:\.\  
{% endcodeblock %}
***注意***:最后有个空格
![显示tab缩进截图](http://7xl4y6.com1.z0.glb.clouddn.com/imageVIM显示tab截图.png)
## 4. 调用两次操作符
当一个操作符调用两次,将会作用于当前行,比如
dd:剪切当前行
cc:更改当前行
\>>:缩进当前行
<<:减小缩进当前行
yy:复制当前行
==:自动缩进一整行
## 5. 在插入模式下更正错误
* `<C-h>`删除前一个字符,同`backspace`
* `<C-w>`删除前一个单词
* `<C-u>`删除至行首

## 6. 返回普通模式
除了`<ESC>`以外,还有几个方法可以从插入模式切换到普通模式
* `<C-[>`切换到普通模式
* `<C-o>`切换到插入-普通模式(从插入模式临时切换到普通模式一次)

插入-普通模式:普通模式的一个特例,能让我们执行一次普通模式的命令,执行完毕后马上回到插入模式.
## 7. 在插入模式中使用vim寄存器
1. `<C-r>{register}`能将寄存器`{register}`中的内容插入到文本中. 有个问题就是如果你设置了`autoindent`或者`textwidth`那么插入进来的文本可能会有不必要的换行额外的缩进.
2. `<C-r><C-p>{register}`这个命令更加智能,它会按照原意插入寄存器内的文本,并修正任何不必要的缩进.

有关vim寄存器的介绍请移步到我的另外一篇[博文](/posts/vim_register/)
## 8. 在文章中使用非常用字符
* 使用`<C-v>{code}`就能输入一个字符.比如输入字符'a'可以使用`<C-v>065`,输入unicode字符需要在code前面加上一个字符'u',比如要输入`<C-v>u00bf`能输入一个反转的问号`¿`,好玩吧:P
* 想知道一个字符的编码,可以在该字符上输入`ga`,即可在状态看到该字符的编码.
* `<C-v><nondigital>`可以插入按键本身代表的字符,比如你开启了'expandtab'选项,使用空格代替'tab'键,那么使用`<C-v><Tab>`将输出一个'Tab',不管'expandtab'是否开启.
* 字符编码不太好记忆对不对?使用`<C-k>{char1}{char2}`能采用字符组合的方式来输入特殊字符,比如`<C-k><<`就能输入书名号`«`,`<C-k>12`输入½,`<C-k>34`输入¾等等,更多的二合字母请参考vim文档:h digraghs-default

## 9. 替换模式和虚拟替换模式
众所周知,`R`和`r`是使vim进入替换模式,这个替换模式是替换实际的字符,比如一个'tab'在文本显示中占据了8个空间,但是在文本中,它还是一个字符,在普通的替换模式中,使用`r`或者`R`替换'tab'字符的时候将会一次替换掉'tab'字符,而在文本显示上将会显示为一次替换了8个空格.
vim还提供一个虚拟替换,使用`gr`或者`gR`进入,这个虚拟替换的不同之处是:替换是按照屏幕显示的实际字符数来替换的.比如一个'tab'占据了8个空格,那么在替换的前面7个字符都将插入到'tab'字符的前面,只有在替换掉第8个字符时,'tab'字符才会被其取代.
ps:'tab'的宽度是可通过修改变量`tabstop`改变的.
