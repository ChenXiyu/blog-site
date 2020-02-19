---
title: "Durability 和 Availability"
date: 2020-02-09T12:59:04+08:00
draft: fasle
categories: [AWS SAP]
---

作为第一语言非英语的学习者, 在接触云相关的服务/概念的时候, 可能经常被一些概念搞的云里雾里, 比如Authentication/Authorization、governance/compliance/auditing、 Durability/Availability 等等. 
 
如果能尽早的弄清楚这些概念, 我们也能更好的理解云服务和更好的利用相关数据来帮助我们演进我们的架构.

今天我们就来理清楚一下Durability、Availability的含义:


## Durability(耐久度)

Durability(耐久度)通常就是用来衡量数据丢失的可能性的.


举个例子来说, 如果你家里有一份非常重要的文件, 然后你复印了一份这个文件, 并将这个复印件存在了银行的保险柜里面, 那么你的这个行为就是增加了该文件的Durability(耐久度), 所有文件的附件同时被摧毁的可能性大大降低了(想象一下家里着火同时银行保险柜被炸掉的可能性).


让我们用AWS S3 作为具体的例子来给Durability 做一个定义. 在S3中, Durability(耐久度)定义的是一个数据(object)有多大的可能性在一年以后仍然能保持完整(不丢失). AWS 用百分比了衡量Durability, 100% 的Durability(耐久度)意味着这个数据(Object)不存在丢失的可能性, 90%的Durability(耐久度)意味着如果你存了一个文件, 然后这个文件就会有10%的可能性在一年以后丢失.

那AWS SLA中的” S3 标准存储类型的数据(object)拥有99.999999999%的durability(耐久度)“意味着什么呢?


它意味着如果你在AWS S3中存了1000亿个文件, 那么一年以后,你有可能会丢失掉一个文件.


## Availability(可用性)

Availability(可用性)用来衡量一个服务可以被使用用的可能性.


举个例子就是, 你可能有自己喜欢的理发师, 而你只能在他们提供服务的时候去使用他们的服务, 而他们提供服务的时间段, 就是一个有限的Availability. 


对你来说, 增加更多可选的理发师将提高你要使用的理发服务的Availability(可用性), 在临近的县城(多区域)增加更多可选的理发师将更大的增加理发服务的可用性, 因为你再需要担心小型陨石将你附近的理发店全部摧毁而没有办法获得理发服务了(区域灾难导致的服务不可用).


在AWS 中 Availability同样是用百分数来衡量的, SLA中提到的99.99% Availability的保证, 意味着该服务将在99.99%的时间里面是保证可以提供服务的.


了解了Durability 和 Availability, 你是不是还听到过Reliability? Accessibility?那他们又是什么意思? 又有什么区别呢?

请看下回分解.

