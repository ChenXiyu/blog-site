---
title: "AWS KMS 授权的“坑”"
date: 2020-02-09T14:00:50+08:00
draft: false
categories: [AWS SAP]
---
<!--more-->
前面两篇文章中介绍了AWS 中的授权模式, 大概概括下来就是:
  * 能够真正提供授权只有Identity Based policy 和 Resource-based policy.
  * Org SCPs、Permission boundary、session policy 都是用于限定范围的, 不能真正的授权操作.
  * Org SCPs 是同时作用于I-B 和 R-B 的. 而permission boundary 和 session policy 只能作用于I-B.
  * 在Org SCPs 不存在或者允许的情况下, 只要Resource-based policy 授权了请求, 那么请求就授权了, 不然就得去看Identity-Based policy.

要注意的是, 这些是在AWS授权中一些通用的原则, 但是, 有些resource 是一些特例, 比如AWS KMS 的授权就不能完全套用第四条, 它有自己的一些小特性. 而且, 针对KMS CMK 的授权, 除了有Identity Based policy 和 Resource-Based policy 以外, 还有一个KMS Grant 可以用来授权, 这个我们会在最后介绍.

接下来我们就来看看AWS KMS 的授权逻辑是什么样的吧.

我们可以通过以下几种方式来控制KMS 的访问:

  * 使用Key policy(Resource-Based Policy)
  * 在KMS CMK的授权中, Key Policy 是必要的, 我们可以只使用Key Policy 来进行授权, 这就意味着我们的授权的范围完整的定义在Key Policy 中, 而不像其他的资源分散在多个地方(Identity-Based Policy)
  * 组合使用Key Policy 和 Identity-Based Policy
    先要说明的是, 我们不能仅仅只用Identity-Based Policy 来对KMS CMK 授权, 这是KMS 授权中非常特别的一个点, 像上面说到的, Key Policy 是必要的. 使用这种组合的方式来授权KMS的访问, 意味着你允许通过Identity-Based Policy的方式来授权访问, 那么如何允许呢? 我们需要在Key Policy中加上一个特殊的policy, 我们后文揭晓.
  * 组合使用Key Policy 和 Grants
    和上一条组合使用的方式一致, Key Policy是必要的. 使用这种方式以为着我们允许有权限的实体(User、Role、Service)能够通过创建Grants将权限委托给其他的实体(User、Role、Service), 关于Grants 的介绍我们后文会有.

到这里我们就能看出一个非常大的区别了, 对于大多数AWS 的Resource 来说, Identity-Based policy 是唯一的授权方式(因为大部分Resource 没有支持Resource-Based policy), 还有一小部分Resource 提供了Resource-Based Policy或其他的授权机制(像Grant)来补充Identity-Based Policy, 但对绝大多数Resource来说, 这些补充都不是必选的, 而在KMS 这里, 这是不成立的, Resource-Based policy 才是主角, 它才是必须的, 其他的才是备选的. 我们要么单独使用Resource-Based Policy 来完成授权, 要么组合Resource-Based Policy 和Identity-Based policy 或 grants 来使用.


## Key Policy
Key policy 本质就是Resource based policy, 所以对特定用户的授权还是一样的去理解. 如果我们在Key Policy 中写了授权某个特定用户某个权限, 那么有这一条授权就够了. 而关于如何写这些polcy 文档我们不会在这个文章中介绍, 可以参考这个文章.
不一样的是, 前文说到了它在KMS授权中是个必要的部分, 它不是可选的.
而在创建KMS CMK的时候AWS 可能会帮我们创建默认的Key Policy(除非使用CLI/SDK创建并且提供了Key Policy). 通过CLI/SDK 和AWS console 创建的默认Key Policy 有一些不同, 但是这些不是我们今天要讨论的点, 有兴趣的同学可以参考这个文章, 我们今天看看它为我们创建的相同部分, 来理解KMS 授权中与普通资源授权的不同点.
我们要讨论的共同部分如下代码块所示:
```json
{
  "Sid": "Enable IAM User Permissions",
  "Effect": "Allow",
  "Principal": {"AWS": "arn:aws:iam::111122223333:root"},
  "Action": "kms:*",
  "Resource": "*"
}
```
按照我们通常的理解: 哦, 这不就是授权该Account下所有请求嘛. 我以前就是这么理解的, 然后就掉坑里了...
正确的理解是:
  * 授权account的Root用户有权限管理该CMK
  * 与其他资源不同的是, CMK 默认对Root 用户的访问是拒绝的, 所以如果不显式的给Root 用户赋予权限的话, Root 就没有权限管理该CMK, 而如果CMK 的拥有者被删除了的话, 那就只有发Ticket 给AWS 请求帮助了.
  * 允许Identity-Based Policy 来授权该 AWS CMK (其实Sid里面已经写到了)
  * 前面提到了 Identity-Based Policy是不能单独授权CMK的, 我们必须要Key Policy 来允许, 而这个操作就是这个允许.

所以, 在看到KMS CMK 的Key Policy 中出现这个文档的时候不要再认为他是授权整个Account了.

## Identity-Based Policy
在有了上节提到的Key Policy 以后, 我们就可以正常的使用Identity-Based Policy 来给IAM 实体来授权了.

## Grants
除了key policy 以外, AWS KMS 还支持 grant 这种授权方式, 简单的说就是有权限的人可以创建授权(令牌)来赋予其他人访问KMS的权限. 而这个令牌是可以被销毁的. 这个令牌只能用来授权, 不能用来拒绝某些权限.
我们当然可以用Key policy 来完成所有的授权, 但是我们一般把Key Policy 中定义的权限考虑成“静态的“, 而我们一般视Grant为临时的、程序自动话的、更小粒度的授权.
它的使用也非常的简单: 创建Grant 就可以了. 而创建Grant 所需要的参数和我们写Policy所要提供的参数非常相似, 比如说:
```bash
$ aws kms create-grant \\
    --key-id 1234abcd-12ab-34cd-56ef-1234567890ab \\
    --grantee-principal arn:aws:iam::111122223333:user/exampleUser \\
    --operations Decrypt \\
    --retiring-principal arn:aws:iam::111122223333:role/adminRole \\
    --constraints EncryptionContextSubset={Department=IT}
```
key-id 对应我们的Resource, grantee-principal 对应我们的 Principal, Operations 就是Actions, constraints 就是类似与Condition, retiring-principal 是指定那个用户可以调用API 来retire 这个grant, 这个是Policy 中没有的.

## 跨Account 授权
跨Account 授权和其他资源还是一样的, 需要同时在Key policy 和Identity-based policy/grant 中赋予权限才能完成跨Account的授权.

理解了上面的点, 那就应该很容易理解AWS KMS 的权限评估流程了:
![](/images/the-tricky-point-on-KMS-authorization/1.jpeg)

照旧: 如有理解偏差, 还望不吝斧正
