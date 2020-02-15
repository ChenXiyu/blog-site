---
title: "在EC2 上实现宿主与应用容器权限的分离(2 tiers role) "
date: 2020-02-09T13:54:40+08:00
draft: false
categories: [AWS SAP]
---

EC2 可以区分Execution role 和Task role嘛?
Officially, NO. But…
当然会有But, 对吧, 不然这篇文章要干嘛…
<!--more-->
最近在项目上做了一个比较有意思的实验, 那就是在EC2的机器上实现2层Role 的机制: EC2机器用一个role, EC2上跑的容器用另外的一个role, 熟悉的朋友可能就会想, 那我在容器里面assume role不就好了吗? 其实这是一种解决方案, 但是这种方式有一些缺陷, 而我们实现了一种通过fake metadata service来实现的更加完善的方案. 且听我慢慢道来.

## 为什么会有这样的需求?
我们项目在开发/维护一个跨account创建CI agent的平台, Ci的agent 以容器的形式跑在EC2 instance 上, 我们会给EC2 Instance赋予一个Role 以使CI agent有一定的权限完成特定的任务, 而这些权限分成两个部分: 
  * 机器正常运行需要的一些权限, 比如LogGroup的权限等
  * 跑job真正要用到的权限(由创建Agent的用户根据他们的目的定义)

在之前, 我们将这两部分权限揉到一个role里面, 而在我们以前的设计中, 我们允许用户提供这个role(通过直接指定定role arn. 这个role 包含上述两部分权限. 由于某些授权需要构建role与资源之间的信任关系, 而这个信任关系会在role 重建的过程中被破坏掉, 在这种情况下应该尽量避免相关role的重建. 所以我们提供一种选择让用户提供一个完整的role来避免role 随着agent stack的重建而重建), 用户提供的role中就必须加上我们instance运行所必须的权限, 这就会导致如果agent更新时需要新的权限, 而用户又没有及时加上必要的权限, 就会导致agent 所在的instances起不起来.

我们就想用类似ECS 的那种两层role 架构来解决这个问题: execution role 和task role, Execution role 拥有容器平台需要的权限, 而task role包含容器真正会用到的权限. 这样, 用户提供的就仅仅是一个task role, 而我们自己控制execution role, 而这样也比较符合least privilege 原则.

## 为什么在container里面assume role不是一个好的实现
现在我们可以解释一下为什么在container 里面assume role 不是一个好的实现: 在container 里面Assume role 这种实现本质就是将我们assume 到的role的credentials 放到环境变量中, 依赖AWS 官方工具读取credential 的优先级, 它会先读取环境变量中credential. 正常情况下, 我们只要将assume role 拿到的credential放在环境变量中就能被读取到.
但是我们的agent采用docker in docker 的机制, 在container 里面跑的job 也是可以跑docker 的. 如果用户在跑job的时候没有明确的将相对应的环境变量映射到job 的container 里面去的话, 它将拿不到环境变量中的credentials, 最终他会去metadata service上去取当前机器的credential, 这样, 它就拿到了一个错误的权限.
## 那如何做更好呢?
既然最后一步都是尝试访问metadata service 去拿credentials, 那我们能不能拦截这个请求呢?
基于这个思路, 我们产出一个方案: 自己在instance上起一个假的metadata service. 将所有container中出来的、意图访问metadata server的流量全都导入假的metadata service中. 
假metadata service 的职责就是响应该请求, 并将一个通过assume role 拿到的credential 给返回回去.
这样就让container 里面的credentials 获取路径就统一了, 不管容器套容器套了多少层, 最后拿role的credentials的时候都会走到我们假的metadata service上.

## 工具
思路有了, 那我们怎么来达成这个目的呢? 流量的劫持转发我们可以用iptables, 现在就差一个fake metadata service 的实现了, 难道要自己写吗? 本着不重复造轮子的精神, 上GitHub!! 还真功夫不负有心人, 找到一个不错的[实现](https://github.com/lyft/metadataproxy).

## 实现
有了工具, 那就开始动手吧!!
首先启动fake metadata service, 我们采用docker container的方式来跑这个服务, 在用它提供的库打好docker 镜像, 在EC2 机器上通过下述命令启动fake metadata service.
```bash
docker run -d -e MOCK_API=true --net=host -v /var/run/docker.sock:/var/run/docker.sock <image that you just build>
```
注意: 这里的network 要设置成host, 我们待会在解释为什么.

fake metadata service 有了, 那就要将容器的相关请求劫持下来导入到fake metadata service 上了:
```bash
LOCAL_IPV4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

/sbin/iptables \
 --append PREROUTING \
 --destination 169.254.169.254 \
 --protocol tcp \
 --dport 80 \
 --in-interface docker0 \
 --jump DNAT \
 --table nat \
 --to-destination $LOCAL_IPV4:8000 \
 --wait
```
上述命令就是将从docker0 虚拟网口出来的、欲意访问169.254.169.254:80 的tcp请求导入到本机的8080 端口上. 这里就可以理解为什么上述服务要起在host networking模式了, 因为我们要把所有通过docker0出来的访问请求都导入到fake metadata service 上, 如果我们的假的metadata service也在桥接模式下, 那我们去assume role时要拿的那个execution role credentials的请求也会被导入到假的server 上... bang!! 我们的metadata service 就不能拿到Execution role的权限了, 也就没办法去assume 到task role啦.

在做完这一步以后, 我们就只需要在运行容器的时候, 将你欲意使用的task role的arn 设置成环境变量传给容器(对我们来说这是非常好控制的, 因为CI agent container就是通过我们的编排跑起来的).

到此为止, 这台机器就能很好的实现task role和execution role的区分了, 当然了, execution role 要有权限去assume task role, 这种基础细节就不一一介绍了.

整体实现下来结构大致如下图所示:
![](/images/second-tier-role-on-ec2/1.jpeg)
