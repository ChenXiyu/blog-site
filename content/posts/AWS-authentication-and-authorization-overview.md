---
title: "一个AWS资源访问请求的历程(一) "
date: 2020-02-09T13:15:54+08:00
draft: false
categories: [AWS SAP]
---

从一个资源访问请求发起, 到请求真正访问到资源, 期间发生了非常多的事情, 就和“在浏览器地址栏中输入一个网站地址并敲击回车以后发生了什么?” 这样的问题类似, 我们可以就某个阶段无限的细化下去, 直到电信号如何在半导体中传导. 
 
今天的文章当然不会笼而统之的将大部分事件过一遍(我也没有时间和精力真的把所有事件细节都弄明白), 今天的文章将会关注请求的身份验证与授权上.

在进入真正的主题之前, 我们需要先澄清一下两个概念: 身份验证(Authentication)和授权(Authorization):
简单的说, 身份验证是确定你是谁(你是你妈的孩子), 授权是确定谁有什么权限(你妈的孩子有权利进入她的房子). 

举个例子: “Admin 有权限访问账单信息”这是一个授权, 而确认一个对帐单信息发起的请求是来自Admin 就是身份验证该做的事.

一般来讲授权是基于身份验证的, 即使是匿名用户(anonymous user)也是身份验证的一个结果.

好了, 在区分好了身份验证与授权以后, 我们可以继续往下看看AWS中的身份验证与授权流程了.

接触过AWS的同学都知道AWS 通过IAM 服务来做身份验证和授权,今天我们就以一个API请求为例子, 来解读一下当一个API 请求进入到AWS 以后, 它是如何通过每一个步骤最后访问到特定的资源的. 

这里为什么用一个API 请求来举例子呢? 因为在AWS中,不管你是通过CLI、SDK、还是AWS console去访问资源, 你做的都只是调用特定的API 而已, 所以用API来举例子可以说覆盖了几乎所有的情况.

如下图所示, 大体上来说, 在AWS中, 一个对资源的访问请求也只是经历了身份验证与授权两个阶段(只不过, 我们会深入到各个阶段的细节中), 最终才能访问到特定的资源, 如果身份验证和授权都通过的话.
![](/images/AWS-authentication-and-authorization-overview/1.png)

## AWS中的身份验证(Authentication)
身份验证的目的是确认请求发起的IAM实体(IAM Entities)是谁, 在AWS 中IAM实体有User 和Role, 其中的Role可以被User、Services和联合验证的用户来担任(assume). 关于User、Role、Group 等话题, 我们可以后面再聊.

AWS提供了多种认证方式:
  * 用户在console 上通过账号密码登陆.
  * 使用用户的access key来完成API 请求的认证.
  * 使用角色(Role)的security token来完成API认证.
  * 通过其他的身份提供者完成联合验证.
  * 匿名用户

通过以上方式, 你就完成了认证.

## AWS中的授权(Authorization)
完成了身份验证以后, AWS 就知道这个请求是谁发起的了, 在请求能访问到资源之前, 我们还需要经过Authorization 的过程来评估发起请求的实体到底有没有权限来访问特定的资源.

如果权限是“允许”, 那么请求就能到达特定的资源, 反之, 则不行.
AWS 的授权过程分为两个步骤: 
  * 获取请求的上下文.
  * 授权评估.

由于篇幅限制, 我们将在这一篇介绍到请求上下文, 授权评估的内容较多, 将另起一篇文章来介绍.
![](/images/AWS-authentication-and-authorization-overview/2.png)

### 获取请求上下文
在这个步骤中, AWS 会收集一些请求相关的信息, 来确定有哪些授权政策可以应用在当前请求中, 比如:
  * 欲对资源进行的操作(Actions/Operators)
  * 欲访问的资源(Resource)
  * 身份信息和身份自身所带的权限(Principal & associated identity based policy).
  * 环境数据: IP地址, User agent, SSL 可用状态(SSL enabled status), 时间
  * 欲访问的资源的相关数据: 资源的标签等信息

AWS 将用这些信息来做后续的授权评估.
获取到请求的上下文信息以后, AWS就可以根据这些上下文信息来时做授权评估了, 授权评估的细节还请待下回分解.

在下一篇中, 我们将详细了解授权评估所用的策略有哪些种类, 它们评估顺序、评估逻辑以及优先级如何等.
