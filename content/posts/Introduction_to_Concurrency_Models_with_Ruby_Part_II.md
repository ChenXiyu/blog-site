---
title: Ruby 并发模型介绍 第二部分 [译]
date: 2017-09-09
draft: false
tags:
- Ruby
- concurrency
categories:
- Ruby
---
在这一系列的第二部分中，我们将会讨论一些更加高级的并发模型，比如：Actors，Communicating Sequential Processes, Software Transactional Memory 和 Guilds（有可能在Ruby3中会被实现的一种新的并发模型）。
<!--more-->
如果你还没有读过我们这一系列文章的[第一部分](https://chenxiyu.github.io/2017/09/06/Introduction_to_Concurrency_Models_with_Ruby_Part_I/)，那我强烈推荐你先去读一下第一篇，我们在第一篇讨论了进程，线程，GIL，EventMachine和我们在第二部分同样会提到的Fibers。
<!--more-->
![](/images/Introduction_to_Concurrency_Models_with_Ruby_Part_II/1.jpeg)
# Actors
Actors 是一种并发原语，它们可以相互之间发送消息。创建一个Actor并且定义它怎么去响应接下来会接受到的消息。它们各自拥有自己私有的状态，并且状态不可共享。所以它们只能通过发送消息来相互交互。由于没有共享的状态，那么在这里锁也没有存在的必要了。
> 不要用共享状态通信，用通信共享状态

Erlang 和 Scala 都在它们的语言层面实现了Actor并发模型，在Ruby中，[Celluloid](https://github.com/celluloid/celluloid)是当前对Actor模型最流行的实现了，在其内部，每一个Actor都在一个独立的线程中运行，并且使用Fibers 来调度方法的运行和暂停，以避免在等待其他Actor的回应的时候回阻塞其他方法的运行。
这里有一个简单的用Celluloid 来使用Actor的例子：
```Ruby
# actors.rb
require 'celluloid'
class Universe
  include Celluloid
  def say(msg)
    puts msg
    Celluloid::Actor[:world].say("#{msg} World!")
  end
end
class World
  include Celluloid
  def say(msg)
    puts msg
  end
end
Celluloid::Actor[:world] = World.new
Universe.new.say("Hello")
```
```Bash
$ ruby actors.rb
Hello
Hello World!
```
## 优势
  - 不需要手动的做多线程编程，而且没有状态共享，不用锁，几乎不会产生死锁。
  - 类似于Erlang，Celluloid实现的Actor有较好的容错，意味着如果Actor 奔溃了，它会使用[Supervisors](https://github.com/celluloid/celluloid/wiki/Supervisors)尝试的重启它。
  - Actor 模型是设计着用来处理程序的分布式问题的，它在跨多机器的伸缩性上表现优秀。

## 劣势
  - Actor在需要共享状态或者希望它按照一定的顺序执行时也许不那么管用。
  - 代码很难调试，想像一下，如果一个系统是基于许多相互交织Actor运行的。。。或者假如一个Actor修改了某些数据。。。Ruby的数据结构可不是不可变的（Immutable）。
  - 与手动操作线程相比，Celluloid 可以让你更快的构建一个复杂的系统，但是它带来了更多的[运行时消耗](http://www.mikeperham.com/2015/10/14/optimizing-sidekiq/)（runtime cost）(慢5倍，消耗8倍的内存）。
  - 不幸的是，由于Ruby实现的限制，使得在多台服务器之间使用分布式的Actor不是那么的好用，比如[DCell](https://github.com/celluloid/dcell)使用了0MQ，但是它直到现在还不能做到产品级的可用性。

## 开源实例
  - [Reel](https://github.com/celluloid/reel/) -- 基于事件的web服务器，通常与基于Celluloid 的应用一起使用。对每一个连接使用一个Actor，可以用在流播（streaming）和 WebSockets中。
  - [Celluloid::IO](https://github.com/celluloid/celluloid-io/) -- 将Actor和事件I/O（evented I/O）结合到一起，但是和EventMachine不一样，它可以让你通过创建多个Actor来在每一个进程中使用尽可能多的事件循环。

# Communicating Sequential Processes(CSP)
CSP是一种非常类似于Actor的实现，它同样是基于‘不通过共享状态来通信’的理念，但是，CSP和Actor有两点关键的不同：
  - 进程在CSP中是匿名的存在，在Actor中是有标识的。所以CSP使用特定的频道来收发消息，而Actor中是直接收发消息。
  - 在CSP中，如果接受者还没有做好接收消息的准备，那么发送者是不能发送消息的，而在Actor中，Actors可以异步的发送消息（在Celluloid中使用[async calls](https://github.com/celluloid/celluloid/wiki/Basic-usage)）。

CSP在不同语言中通过不同的方式实现：Golang通过[goroutines 和 channels](https://blog.golang.org/share-memory-by-communicating) 实现了CSP，Clojure通过[core.async](http://clojure.com/blog/2013/06/28/clojure-core-async-channels.html)库实现CSP，Crystal通过[fibers 和 channels](https://crystal-lang.org/docs/guides/concurrency.html)实现CSP。在Ruby中，有很多gem实现了CSP。比如一个叫做[concurrency-ruby](https://github.com/ruby-concurrency/concurrent-ruby/blob/df482db36caf1b0c1d69a8ff97a2407469e1e315/doc/channel.md)的库实现的一个叫做 `Channel` 的类。
```Ruby
# csp.rb
require 'concurrent-edge'
array = [1, 2, 3, 4, 5]
channel = Concurrent::Channel.new
Concurrent::Channel.go do
  puts "Go 1 thread: #{Thread.current.object_id}"
  channel.put(array[0..2].sum) # Enumerable#sum from Ruby 2.4
end
Concurrent::Channel.go do
  puts "Go 2 thread: #{Thread.current.object_id}"
  channel.put(array[2..4].sum)
end
puts "Main thread: #{Thread.current.object_id}"
puts channel.take + channel.take
```
```Bash
$ ruby csp.rb
Main thread: 70168382536020
Go 2 thread: 70168386894280
Go 1 thread: 70168386894880
18
```
我们在两个不同的线程中跑了两个操作（加法），在主线程中同步并且汇总了总值。所有这些都通过 `Channel` 完成而没有使用任何锁。
究其根本，每一个 `Channel.go` 都会在线程池中取一个独立的线程来跑，如果线程池中没有足够的空闲线程，它会自动的增加线程池的大小。
在这种有阻塞I/O的情况下，这种会释放GIl的处理是非常有用的（前一篇文章有更详细的介绍），另一方面，我们看看clojure中的core.async，它使用一个有限的数字来给线程编号，并且试图使他们‘寄停’（park），这样的处理可能会导致I/O操作[阻塞了其他的操作](https://martintrojer.github.io/clojure/2013/07/07/coreasync-and-blocking-io)。
## 优势
  - CSP的频路(Channel)能够接受的消息有个最大值限制，这也很容易理解，而Actor模型就好比有一个潜在的无限的一个邮箱可以来接受消息。
  - 使用CSP不需要把生产者和消费者进行配对，它们不需要知道彼此的存在。
  - CSP的消息在频路（Channel）中是按照发送的顺序排列的（有序的）。

> Clojure也许最终会实现支持分布式的Actor模型，在有分布式需求的时候，就必须付出一定的代价。而我认为这对于普通程序开发来说过于麻烦了。 -- [Rich Hickey](https://clojure.org/about/state#actors)

## 劣势
  - CSP通常情况下用在单一机器上，它不像Actor模型一样可以比较好的应用到分布式的系统中。
  - 在Ruby中，绝大多数对GSP的实现都没有使用混合线程模型（M:N threading model），‘goroutines’实际上是使用的Ruby的线程，也就是说使用了操作系统的原生线程，这就意味着‘goroutines’并没有那么轻量。
  - Ruby中CSP并不是很流行，活跃开发、稳定、历经住实战考验的工具也不多。

## 开源实例
  - [Agent](https://github.com/igrigorik/agent) -- Ruby中另外一种CSP实现，同样在独立的Ruby线程中运行。

# Software Transactional Memory
前面介绍的Actor和CSP都是基于消息传递的，STM是基于共享状态的并发模型。于数据库事务处理类似，它是一种非传统的基于锁的同步，以下是主要的概念：
  - 值在一个事务内是可以被改变的，但是这个值的改变只有在这个事务被提交以后才能被其他人看到。
  - 一个事务内如果发生错误，那么这个事务将被整体的中断并且回滚到事务开始前的状态。
  - 如果一个事务因为冲突而没有办法提交成功，那么这个事务会一直重试，直到成功。

[concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby)基于Clojure的[Refs](https://clojure.org/reference/refs)实现了[TVar](https://ruby-concurrency.github.io/concurrent-ruby/Concurrent/TVar.html)，下面有从一个银行转钱到另一个银行的例子：
```Ruby
# stm.rb
require 'concurrent'
account1 = Concurrent::TVar.new(100)
account2 = Concurrent::TVar.new(100)
Concurrent::atomically do
  account1.value -= 10
  account2.value += 10
end
puts "Account1: #{account1.value}, Account2: #{account2.value}"
```
```Bash
$ ruby stm.rb
Account1: 90, Account2: 110
```
  `TVar` 是一个包含了简单数据的一个对象，与 `aotomically` 一起来实现在数据的事务操作。
## 优势
  - 使用STM的程序设计比基于锁的设计要简单不少，他可以避免死锁的发生，简化了并发系统，因此你也不用考虑条件竞争的发生。
  - 在不改变系统大架构的情况下，能够比较容易的适配到使用Actor/CSP模型的系统上。

## 劣势
  - 由于STM依赖于事务的回滚，你应该保证一个事务内的任何一个操作在任何时间点上都是可以回滚的。在实际操作中，这很难保证，比如一些I/O操作（Post HTTP 请求）。
  - STM在MRI的伸缩性不好，因为GIL的存在，你没法在同一时间使用多余一个CPU，你同样没法享受在线程中I/O操作的好处因为I/O操作很难回滚。

## 开源实例
  - [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby)中的TVar，实现了STM，同时还包含了一些用于比较在MRI、JRuby、Rubinius中使用锁和使用STM的性能测试工具。
  
# Guilds
Guilds是被Koichi Sasada（Ruby核心开发者，设计了Ruby VM、fiber、GC）提议加入Ruby3的一种新的并发模型。一下有几点对Guilds想法：
  - 新的模型需要与Ruby2兼容，并且能够提供更好的并发。
  - 由于Ruby用了非常多的‘写’操作，所以使用与Elixir类似的不可变数据类型可能导致程序不可接受的慢。所以使用与Racket类似的复制共享的可变的对象也许是更好的选择，但是这个复制必须要足够快，这样的操作才能成功。
  - 如果共享可变对象是不可避免的话，那么这个数据应该是一种特殊的数据类型（与Clojure类似）。
  由以上的几点想法得到下面Guilds的核心理念：
  - Guilds 作为一种并发原语，可能包含多个线程、多个Fibers
  - 只有Guild的所有者才能操作它对应的可变的数据，所有没有必要使用锁。
  - Guild之间可以通过拷贝可变对象或者转让对象所有权来共享数据
  - 不可变的一些数据可以被所有Guild通过引用访问，而不需要拷贝（比如：数字数据，符号类型数据， `true` ， `false` ，冻结的对象）。

我们前面的的转钱的例子用Guilds实现的话，代码如下所示：
```Ruby
bank = Guild.new do
  accounts = ...
  while acc1, acc2, amount, channel = Guild.default_channel.receive
    accounts[acc1].balance += amount
    accounts[acc2].balance -= amount
    channel.transfer(:finished)
  end
end
channel = Guild::Channel.new
bank.transfer([acc1, acc2, 10, channel])
puts channel.receive
# => :finished
```
所有关于账户余额的数据都存储在一个单一的Guild中，只有通过channel发送指令才能让这个Guild操作这部分数据。
## 优势
  - 在Guilds之间没有共享可变的数据，意味着没有锁机制的必要，也不存在死锁，Guilds之间的通信在设计上是安全的。
  - Guilds鼓励使用不可变对象共享数据的方式，因为这是在Guilds间共享数据最简单最快的一种方式。从最开始就尽可能多的固化数据，例如，在文件最开始加上 `# frozen_string_literal: true`
  - Guilds是完全兼容Ruby2的，这意味着你的代码会在一个单一的Guild里面运行，你不需要对你的代码做任何改变，也不强制使用固化结构的对象。
  - 与此同时，Guilds给MRI带来更好的并发性，终于有可能使我们能够在同一个Ruby进程里面使用多个CPU。

## 劣势
  - 现在去评价性能也许还太早了，但是与线程相比，通过共享可变数据来通信还是会有一个可观的内耗。
  - Guilds允许多种并发模型同时使用，这也导致Guilds更加复杂。（比如，可以通过channel来实现GSP、通过特殊结构的可变对象来共享数据来实现STM以获取更好的性能、在单一的Guild里面使用多线程编程。。。）
  - 从资源使用的角度看，虽然说在一个进程中跑多个Guild要比直接开多个进程要轻量，但是与Ruby线程相比，它还是不那么轻量，你可能不会仅仅使用Guild去处理上万个WebSocket的连接。

## 开源实例
 由于Ruby3并没有发布，所以现在并没有开源实例。但是我很看好未来马上会有开发者投入到一些Guild友好的工具的开发中，类似于Web 服务器、后台处理进程这种。大多数这种工具可能都会允许使用混合并发方式来编程：像跑多个进程，每一个进程中跑多个Guild，每一个Guild跑多个线程。现在来说，你可以先读读Koichi Sasada的[原始提议](http://www.atdot.net/~ko1/activities/2016_rubykaigi.pdf)
# 总结
  还是那句话，并发问题没有银弹。我们文章中提到的并发模型都有各自的利弊，CSP模型在单一系统的情况下运行的最好并且没有死锁，Actor模型在使用多台机器的系统中伸缩性最好，STM使得并发编程更加简单。但是以上提到的这些模型都不是Ruby中的原生实现，也不能完全适配其他的编程语言。因为在Ruby中它们都是基于Ruby的原生并发原语实现的，要不就是线程，要不就是Fiber。不管怎么样，Guilds有可能在Ruby3中发布，这算是在实现更好的并发上先前走了一大步。
  原文地址: https://engineering.universe.com/introduction-to-concurrency-models-with-ruby-part-ii-c39c7e612bed.
