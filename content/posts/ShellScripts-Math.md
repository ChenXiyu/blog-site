---
title: ShellScripts--数学计算
date: 2015-08-08 11:56:10
draft: false
tags: [ShellScripts]
---

在shell Script中，有好几种进行数学运算的方法，虽然有几个效果差不多，在编写程序的时候使用一种方法就够了，但是我们可能还需要学习别人的程序啊，在阅读别人的程序的时候不能不认识这些东西吧。所以，留个笔记。
 
## expr 命令 ##
expr 允许在命令行上处理数学表达式，但是略显拙劣。
```
    $ expr 1 + 5    #注意在表达式中要有空格，如果写成1+5那么结果就不是我们想要的了。
```
expr命令能够识别一些不同的数学和字符串操作符：

|操作符|描述|
|:---------------------|:---------------------|
|arg1\arg2|如果没有参数是NULL或者零，返回arg1;否则返回arg2|
|arg1 & arg2|如果没有参数是null或者零，返回arg1 ， 否则返回0|
|arg1 < arg2|如果arg1 小于 arg2 返回1 ，否则返回0;|
|arg1 <= arg2|arg1 小于或者等于 arg2 返回1 ， 否则返回0|
|arg1 = arg2|arg1 等于arg2 返回1 ，否则返回0|
|arg1 != arg2|arg1 不等于arg2 返回1，否则返回0|
|arg1 >= arg2|arg1 大于等于arg2 返回1，否则返回0|
|arg1 > arg2|arg1 大于arg2 返回1 ， 否则返回0|
|arg1 + arg2|返回两参数算数和|
|arg1 - arg2|返回算数差|
|arg1 * arg2|返回算术乘积|
|arg1 / arg2|返回算术商|
|arg1 % arg2|返回两数相除的余数|
|string : regexp|如果regexp匹配到了string中的某个模式，则返回该模式|
|match string ：regexp|如果regexp匹配到了string中的某个模式，则返回该模式|
|substr STRING POS LENGTH|返回起始位置为POS 长度为LENGTH个字符的子串|
|index STRING CHARS|返回在STRING中找到的CHARS的位置，否则为0|
|length STRING|返回字符串STRING的长度|
|\+ TOKEN|将TOKEN解释成字符串，即使是一个关键字|
|(EXPRESSION)|返回EXPRESSION的值|
`以上\代表|`.注意：在使用expr命令时可能要使用'\'转义或者''转义
```
	expr 2 * 5  # ==> expr: 语法错误 
	expr 2 \* 5  # 或者 expr 2 '*' 5 ==>10
```
## 美元符号+方括号
`$[OPERATION]`
```
	var1=$[1+5]; # ==> var1=6
	var2=$[$var1*3]; #  ==>  var2=18;
```
这个比前面的要方便多了...
缺点：只能进行整数运算,这是bash shell的原因，据说Z shell 支持浮点运算。我还没有验证过。
## 美元符号+双括号
`$((OPERATION))`与$[]使用方法相同
```
	var=$((1+3)); # ==> var=4
```
## 双括号 
`(( expression ))`双圆括号允许将高级数学表达式放入比较，也支持数学计算。这里的expression可以是任意的数学赋值或者比较表达式，能够是比较表达式，也就是说可以当作test命令使用，在if while for until 结构中都可以用作条件判别语句

|expression|meanning|
|:------|:--------|
|val++|（后）自增|
|val--|（后）自减|
|++val|（前）自增|
|--val|（前）自减|
|！|逻辑求反|
|~|位求反|
|**|幂运算|
|<<|左移位|
|>>|右移位|
|&|位与|
|/|位或|
|&&|逻辑与|
|//|逻辑或|
`以上/和//表示|和||`
```
	var1=10; ((var2=$var1**3)); # ==>该句的意思是 var2=10*10*10=1000,(10的立方)
	if (($var1**2>90)) ; then echo "ok" ; fi  # ==>当var1的平方大于90时输出 ok。
```
这个东西很强大，而且在脚本中使用很直观，当见到(())时，我们就知道，这里出现了数值计算。
##  let 命令
与(())类似;
```
	$ let "$var+=1"
	$ let "var=$var+1";
```
##  bc计算器（大boss）解决浮点运算的常用方案
### 在命令行使用bc
bc 是我们学习linux时最先学习的几个命令。直接在命令行输入bc可以进入bc计算器的交互界面，可以在里面定义变量，计算表达式等操作。
```
	$ bc
	> 2+5
	> 7
```
bc计算器的浮点运算由一个叫做scale的变量控制，实际上，scale的值就是小数点后的位数，而bc默认的scale=0,所以在计算的时候需要修改scale，比如scale=4，保留小数点后四位。
```
	$ bc
	> 3.44/5
	> 0
	> scale=4
	> 3.44/5
	> .6880
```
使用-q参数可以将进入bc后输出的版权说明给屏蔽掉。使用quit退出bc
```
	$ bc
	> quit
```
### 在shellscripts中使用bc 
bc可以接受标准输入，而这个标准输入我们可以通过管道或者重定向来提供给它。bc接受标准输入后，计算输入的表达式，输出到标准输出中，我们可以通过$(commamd)或者是\`command\`来获取它的输出。
#### 用法一
```
	variable=$( echo "options; expression " | bc) ;
	
	var=$(echo "scale=4; 3.44/5;" | bc) ; # ==> var=.6880
```
#### 用法二
使用内联(inline)输入重定向**<<**
```
	variable=$(bc << EOF
	          options;
	          statements;
	          expressions;
	          EOF)

	var=$(bc << EOF
	          scale=4;
	          var1=20;
	          var2=3.1415926;
	          a1=($var1 * $var2);
	          b1 = ($var1 / $var2);
	          a1 + b1;
	          EOF)
```
常见用法就这么多，还有文件重定向等用法也是差不多的。
