---
title: "跨Account 授权S3访问的三种方式"
date: 2020-02-06T23:11:18+08:00
draft: false
tags: [AWS, S3, Permissions]
categories: [AWS SAP]
---
在这篇文章中, 我们整理一下跨Account 授权S3 访问的三种方式. 他们分别是, Bucket policy, Cross Account role 和 S3 ACL.
<!--more-->
前两种其实前面讲过的Resource based policy 和 Identity based policy, 也是跨Account授权访问其他种类resource可以用到的通用方法, 最后一种S3 ACL 是S3特殊的一种授权方式, 在前两种能够达成目的的情况下, AWS 推荐使用前两种方式, S3 ACL已经被AWS标记成了老旧的方式(legacy way), 但是, 如果你已经使用了ACL 并且它工作良好, 那你也没有必要花精力将它改到Bucket policy上来. 那么接下来我们就一起看一下这三种授权方式的异同吧. 

## **S3 ACLs**
### **S3 ACLs 是什么?**

**一个** S3 ACL 是一个附加在S3 Object 或者S3 Bucket上的一个子资源(sub-resource). 它定义了哪个AWS account 或者group 能够有权限访问这个Bucket/Object, 并且它还会定义权限类型(读、写 等等), 当我们创建一个Bucket 或者Object 的时候, AWS S3 会创建一个相对应的默认ACL, 这个默认的ACL赋予资源的所有者所有权限.

### **S3 ACLs 如何配置?**

S3 ACLs 的配置如下图所示, 只需要提供Account Canonical ID(理解为它等同于Account ID)、配置相关权限的授权就可以了:
![ACLs configure console](/images/three-way-to-access-s3-bucket-acrossing-accounts/1.png)

### **S3 ACLs 与其他两种方式有何异同?**

- **作用域**

根据它的特性, 它与其他两者最主要的区别是它既可以附着在Bucket 上, 也可以附着在Object上, 而通过Bucket policy 和Identity based policy 来限制Object的访问的话, 只能将需要限制的Objects 写到policy的Resource字段中, 而这些policy 最终还是附着在Bucket/Identity 上面的.

- **Object的访问权限.**

如果我们通过S3ACL 授权其他的Account 来访问, 那么其他Account 的用户在该Bucket 里面创建的Object 的权限就只有Owner(默认情况下), 即使你是Bucket 的owner, 你依然没有任何权限访问别人创建的Object 除非创建者显示的赋予你(Bucket owner)权限.


**S3 ACLs总结:** S3 ACLs 可以应用在Bucket 上也可以应用在Object上来跨Account 授权, 使用ACLs 授权所创建的Object 将默认只属于创建者, 即使是Bucket owner 也没有权限访问. S3 ACLs 是一种legacy的授权方式. 其授权访问方式如下图所示:
![ACLs](/images/three-way-to-access-s3-bucket-acrossing-accounts/3.png)

## **Bucket Policy**

Bucket Policy 就是附着在Bucket上的Resource-based policy, 我们可以通过如下代码跨Account 授权:

    {
    	"Version": "2012-10-17",
    	"Statement": [
    		{
    			"Sid": "Allow xxxxx account",
    			"Effect": "Allow",
    			"Principal": {"AWS": "1111111111"},
    			"Action": "s3:PutObject",
    			"Resource": "arn:aws:s3:::examplebucket/*"
    		}
    }

Principal 中既可以写{"AWS":"1111111111"}, 也可以写{"AWS": "arn:aws:iam::1111111111:root"}, 这都是指代某个Account, 特别是后面这个写法, 很多人理解成某个Account的root 用户, 这种理解是不对的, 这代表着某个Account.

和ACLs 类似,  如果通过上述代码授权跨Account的访问, 那么(默认情况下)Object的权限将只属于Object的创建者, 即使Bucket Owner也没有权限去访问这种Object, 但是, 在使用ACL授权的情况, 这种状况似乎是无解的,出发创建者授权给Bucket owner, 但是, 在使用Bucket policy授权时, 我们作为Bucket owner是可以采取一定的措施来避免这种情况发生的:

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "Allow xxxxx account",
          "Effect": "Allow",
          "Principal": {
            "AWS": "1111111111"
          },
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::examplebucket/*"
        },
        {
          "Sid": "Deny Object that not grant permission to bucket owner",
          "Effect": "Deny",
          "Principal": {
            "AWS": "1111111111"
          },
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::examplebucket/*",
          "Condition": {
            "StringNotEquals": {
              "s3:x-amz-acl": "bucket-owner-full-control"
            }
          }
        }
      ]
    }

我们可以设置一个拒绝授权的条件: 如果不给Bucket Owner 赋予full access 那么就拒绝这次请求.

**总结:**  和ACLs相比, Bucket policy 只能应用在Bucket上, 但是可以通过设置具体资源的方式来限制Object 的访问, 与使用ACLs授权相同, 使用bucket policy 授予其他Account权限, 默认情况下Object只属于创建者, 但是Bucket policy 可以设置“如果不赋予Bucket Owner 所有权的话, 就拒绝”的policy. 起授权访问图示如下图:
![Bucket Policy](/images/three-way-to-access-s3-bucket-acrossing-accounts/2.png){:height="100px" width="400px"}

## **Cross Account Role:**

cross Account role 的方式就是在资源所在的Account中创建一个用来访问资源的role, 并且允许Account A中的Principal 来Assume, Account A中的principal 通过assume 到这个role上来获取访问S3 bucket 的权限. 这里对S3资源的授权本质就是Identity-based policy.

使用这种方式, Object的所有权还是在资源所在的Account 里面, 因为创建Object的是那个被Assume的role而已.
其授权访问图示如下图:
![Cross Account Role](/images/three-way-to-access-s3-bucket-acrossing-accounts/4.png)

**最后, 至于以上三种方式何时何地使用完全取决与你自己的使用场景, 依据三种方式的特性具体情况具体分析.**
