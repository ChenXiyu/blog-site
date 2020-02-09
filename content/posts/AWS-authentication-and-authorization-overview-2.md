---
title: "一个AWS资源访问请求的历程(二) "
date: 2020-02-09T13:24:11+08:00
draft: false
categories: [AWS SAP]
---
书接前文, 前面已经介绍到AWS 在授权(Authorization)阶段先拿到了请求相对应的上下文信息, 在拿到上下文信息以后就能开始做权限的评估(policy evaluation)了.

接触过IAM 的同学可能听过类似的一些IAM 授权策略的规则(如果有些名词你不太理解, 没关系, 我们后面会一个一个解释):
  * 默认情况下, 所有的请求都是被拒绝的(account root 发出来的请求除外).
  * 在任意授权策略(基于身份的授权/基于资源的授权)中显示声明的允许将会覆盖上述默认情况.
  * 如果Organization SCP、IAM permission boundary、session policy 之一(或者都)存在的话, 它们都必须要允许该请求, 不然的话, 会被看作隐式的拒绝.
  * 一个显式的拒绝可以覆盖任何其他条件.

但是大家有没有想过, 到底是什么样的一个评估逻辑支撑了上面这些规则? 
在解释评估逻辑之前, 我们需要先来了解一下IAM 都支持哪些种授权策略(policy), 以及它们的作用方式与范围.
## 授权策略(policy)解析
首先, AWS 通过Policy 来定义权限,  Policy 是AWS授权的基础, policy 是类似于下面的代码的一个定义语句:

```
{ 
    "Version": "2012-10-17”,
    "Statement": [
        {
            "Sid": "AllowS3ListRead”,
            "Effect": "Allow”,
            "Action": [ "s3:ListAllMyBuckets", "s3:HeadBucket" ],
            "Resource": "*”
        }
    ]
}
```
上述policy 定义了一个允许在所有资源上进行s3:ListAllMyBuckets 和 s3:HeadBucket 的权限.
其次, 根据Policy 应用的地方不一样, 也就区分了不同类型的policy, 接下来我们一一介绍:

**Identity-based policy(基于身份的授权策略)**
Identity-based policy 是应用在IAM 身份实体(User、一组User、Role)上的一种policy, 它将它自身所带的权限赋予该身份. 如果一个请求只有Identity-based policy 起作用, 那么就只需要Identity-based policy 中有至少一个相对应的“允许”就可以授权通过了.

**Resource-based policy(基于资源的授权策略)**
Resource-based policy 是应用在一个资源上的policy, 它给policy 定义的特定角色授予(禁止)访问该资源的权限.如果一个请求中同时有Identity-based policy 和Resource-based policy 起作用, 那么只需要两个policy 中至少有一个“允许”就可以通过授权了.

**IAM permission boundary(权限边界)**
权限边界是一种应用在IAM 身份实体(User、一组User、Role)上的特定的Policy, 它定义了该IAM 身份实体最大能通过Identity-based policy取得的权限范围, 如果你将权限边界应用在了一个身份实体上, 那么它的权限将是Identity-based Policy 和 Permission boundary 的交集. 注意: Permission boundary 针对在Resource-based Policy 中定义的权限没有作用. 它定义了Identity-based policy 所能授与权限的天花板.

**AWS Organizations service control policies (SCPs)**
组织(包含多个AWS Account)级别的Permission boundary, 它定义的是组织里面的Account 下所有授权所能取得的最大权限. 也就是说, 只要组织SCPs存在, 没有任何授权能超出它定义的范围. 它定义了一个Org 以及其下的Account 所有身份所能获取的最大权限.

**Session policies**
Session policy 是一种特殊的policy, 它被附加在一次assume role 的会话(session)中. 不管通过什么方式来assume 到一个role, 我们称这个assume role以后的交互为一个会话(session), 而你可以将一系列policy 附加到某次会话中, 这就意味着, 你为当前会话的主角(Principal) 设置了一个权限边界, 它的作用范围于Permission boundary是一模一样的(只作用于Identity based policy 而不会影响到Resource based policy).

回到我们的请求中(我们还没有忘记我们的API请求), 在一次请求的授权中, 这些policy 是可以随意组合的(只要它们被设置了), 它们可以同时出现, 也可以只出现一个或者多个.
依据这些policy的特性, 我们来看一下, 这些policy 的几种常见组合的授权边界是什么样子的:

在解释授权边界之前, 我们还是要牢记: 显式声明的Deny 将覆盖任何的Allow.

**Identity-Based Policy + Resource-Based Policy**
Identity-Based Policy 附在一个特定的User 或者Role上, 给该User/Role 赋予/拒绝它所指定的权限, Resource-Based Policy 附着在Resource上, 给特定的Principal(User和Role 只是Principal的一个子集, 这个我们后面再聊) 赋予/拒绝访问该资源的权限, 如果Identity-Based Policy 和Resource-Based Policy 同时被使用的话, 只要它们其中一个授权了该请求, 那么请求就被授权了.也就是说, 如果两者同时被使用的话, 那么请求的权限边界将是两个Policy 权限的并集.
![](/images/AWS-authentication-and-authorization-overview-2/1.png)
**Identity-Based Policy + IAM Permission Boundary**
IAM Permission Boundary 是给User/Role 设置的权限边界, 所以, 如果Identity-Based Policy和Permission Boundary 同时出现的话, 该请求的权限边界将是两个policy 的交集. 
![](/images/AWS-authentication-and-authorization-overview-2/2.png)
**Resource-Based Policy + IAM Permission Boundary**
上文提到了, IAM Permission Boundary 不作用于Resource-Based Policy, 所以, 这两者的组合的权限边界完全等于Resource-based Policy 的权限.
![](/images/AWS-authentication-and-authorization-overview-2/3.jpeg)

**Organization SCPs + Identity-based/Resource-based policy**
上文提到Org SCPs 是在Org 及其Account级别的授权边界, 所以, 所有权限都不能超过它授权的边界. 所以有效权限是它们的交集.
![](/images/AWS-authentication-and-authorization-overview-2/4.jpeg)

**Organization SCPs + Identity-Based Policy + IAM Permission Boundary**

Permission Boundary 和Organization 都对边界做了限制, 所以有效权限是三个policy的交集.
好了, 在有了这么多关于Policy的知识以后, 我们就可以来看看AWS 底层是一个什么评估逻辑来支撑了以上关于Policy的规则.
![](/images/AWS-authentication-and-authorization-overview-2/5.jpeg)

## Policy的评估逻辑

总的来说, 我们的请求在这个阶段会经历4个阶段评估:
  * 全局policy 的Deny 评估
  * 组织/Account 授权边界的评估
  * 基于资源的授权评估
  * 基于用户的授权评估(包含下图中的最后三步)

这4个阶段可以拆分成6个步骤, 也就是说, AWS对policy的评估总共分为6个步骤, 分别对应于不同的policy的评估(除了第一步), 如下图所示, 我们接下来就一个一个步骤的看一遍.
![](/images/AWS-authentication-and-authorization-overview-2/6.jpeg)
下面我们就拆开它们来看看:
  * 显示拒绝授权: 这一步是从所有应用到该请求的policies(从context 中、org设置中、session中能找到所有应用的policy) 中将显示声明的Deny语句先评估一遍, 看看是否有和本条请求的Action 和Resource 相匹配的, 如果有, 那么评估结果将直接返回为拒绝(Deny). 这也是为什么显式声明的Deny的优先级最高的原因.
  * Organizations SCPs的评估: 如果有Org SCPs存在的话, 那么第二步就会去判断SCPs 是否允许该请求的, 如果允许, 那么我们可以去评估接下来的policy, 否则将会返回评估结果为拒绝. 这也是为什么说Org SCPs 是所有情况下授权的最大边界的原因.
  * Resource-based policy的评估: 如果评估继续, 那么就进入到了Resource-Based Policy的评估. 在这个阶段中, 只要Resource-based policy 有授权了该请求, 那么评估结果就是允许, 否则将继续往下评估.
      Note: 这里有一个例外: 如果在Resource-Based policy中指定的pricipal 是某个特定的用户或者角色的ARN, 那么这条授权语句将被加到用户或者角色的Identity-Based policy中, 在这种情况下, session policy是可以限制住这样一条授权的.
  * 基于用户的授权评估: IAM permission Boundaries的评估: 如果Resource-based policy没有允许这条请求, 那么评估继续, 进入Permission boundary的评估. 如果Permission Boundary存在的话, Permission Boundary 必须显式的允许, 否则评估结果将会返回拒绝. 也就不会进入后面的Identity-based policy的评估了, 这也是说Permission Boundary 是Identity-based policy的授权上界.
  * Session policies: 如果permission Boundary 不存在或者允许了该请求, 那么就进入到下一个阶段, session policy的评估. 如果session policy 不存在或者允许了该请求, 那评估将进入下一个阶段, 否则, 请求将被拒绝, 这也就是为什么session policy是另一层boundary 的原因.
  * Identity-Based policy: 最后, 进入Identity-based policy的评估, 由于这是评估的最后阶段, 如果这个部分还没有任何语句允许授权的话, 那么最终的结果将是拒绝, 反之就是允许授权.

那么到这里, 我们的身份验证和授权阶段就已经走完了, 资源请求经历整个流程以后, 就能确定是否允许访问相关资源了.

需要注意的是, 这里描述的是在同一个Account 中的授权逻辑(或者请求已经进入到了目标Account中了), 如果是跨Account的请求, 请求在出自己所在的Account的时候, 还会有一次授权校验, 请求需要在自己的Account 通过了授权, 才能发出去. 这也是为什么跨Account 请求的授权需要两个Account 都显式的允许(不管是Identity-based 还是Resource-based)才可以正确授权的原因. 
