---
title: 彩色化标签云
date: 2015-08-18 23:23:13
draft: true
tags:
- hexo
- tagCloud
- html
- css
- js
categories:
- Tech

---
今天无意间看到hexo文档中的[tagcloud文档](https://hexo.io/zh-cn/docs/helpers.html#tagcloud),它说tagcloud是支持彩色的，但是我没有学过这些前端的东西啊，不过我可以试着改一改。我现在使用的主题是[jacman](https://github.com/ChenXiyu/jacman),这个主题比较简单，我自己做了些调整，包括今天要介绍的colorful tagcloud。:-）
 
标签云是我这个主题就带有的，但是这个主题的标签云只有灰黑色，比较单调，而hexo的文档中看到tagcloud是支持彩色的，于是我开始对主题进行了改造：
 
找到主题中标签云的文件`$ find themes/jacman/ | grep tagcloud`
```
themes/jacman/layout/_widget/tagcloud.ejs
```
嗯，看上去是个js文件(原谅我真的没搞过前端),打开它：
{% codeblock %}
<% if (site.tags.length){ %>
  <div class="tagcloudlist">
      <p class="asidetitle"><%= __('tagcloud') %></p>
         <div class="tagcloudlist clearfix">
            <%- tagcloud() %>
         </div>
  </div>
<% } %>
}>
{% endcodeblock %}
Orz代码完全看不懂啊，WTF!!但是，这段代码中出现了`<%- tagcloud() %>`,这和文档中的`<%- tagcloud([tags],[options]) %>`略像啊，这不就是一个默认参数的tagcloud吗？二话不说，也不管前后都看不懂，给它加上参数：
```
<% if (site.tags.length){ %>
  <div class="tagcloudlist">
      <p class="asidetitle"><%= __('tagcloud') %></p>
          <div class="tagcloudlist clearfix">
                 <%- tagcloud(site.tags, {
                                min_font: 8,
                                max_font: 23, 
                                color: true ,
                                start_color: '#000000',
                                end_color: '#00f800'
              }) %>
          </div>
   </div>
<% } %>
}>
```
这样就可以了。可以调整一下颜色区间，也可以调整下最大/小字体的大小，其他设置我没有用，可以参考前面给出的链接自行添加。(加参数的过程也出了很多问题啊,试了很多种格式的语法才奏效。总之最后照着我这个写就没有问题了。)
