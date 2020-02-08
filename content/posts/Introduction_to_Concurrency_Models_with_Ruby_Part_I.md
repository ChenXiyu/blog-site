---
title: Ruby 并发模型介绍 第一部分 [译]
date: 2017-09-06 10:16:11
draft: false
tags:
- Ruby
- concurrency
categories:
- Ruby
---

原文地址: https://engineering.universe.com/introduction-to-concurrency-models-with-ruby-part-i-550d0dbb970
在这系列文章的第一部分,我将会介绍:
- 进程(Processes)和线程(Threads)的区别;
- GIL 是什么东西; EventMachine 和 Fibers 在 Ruby 中的使用;
- 什么时候使用哪一种模型;
- 哪些开源项目在使用它们;
- 它们的优缺点分别是什么;

![](/images/Introduction_to_Concurrency_Models_with_Ruby_Part_I/1.jpeg)
# 进程( Processes)
  跑多个进程准确的说并不是并发( concurrency ), 而是并行( parallelism ). 尽管并发和并行经常被搞混,但是他们是不一样的东西,下面是一个简单的类比:
  - 并发: 一个人用一只手拿多个球来玩抛接球游戏,不管看上去是什么效果,这个人只能在一个时间点上抓/扔一个球
  - 并行: 多个人同时的各自拿多个球玩抛接球游戏.

##  顺序执行
   假设我们有一个一定范围内的数字集合,我们要先把它转换到数组,然后找到一个指定的元素的下标:
```Ruby
range = 0...10_000_000
number = 8_888_888
puts range.to_a.index(number)
```
```Bash
$ time ruby sequential.rb
8888888
ruby test.rb  0.41s user 0.06s system 95% cpu 0.502 total
```
运行上述代码大约占用了1颗 cpu 的 500ms
##  并行执行
 我们将用并行的思想重写上面的代码:将数字集合分成两部分,用多个并行的进程来处理.使用 Ruby 标准库中的 `fork` 方法可以创建一个子进程,它将运行作为参数传入的块( block ),使用 `Process.wait` 来使父进程等待所有子进程直到所有子进程结束.
```Ruby
# parallel.rb
range1 = 0...5_000_000
range2 = 5_000_000...10_000_000
number = 8_888_888
puts "Parent #{Process.pid}"
fork { puts "Child1 #{Process.pid}: #{range1.to_a.index(number)}" }
fork { puts "Child2 #{Process.pid}: #{range2.to_a.index(number)}" }
Process.wait
```
```Bash
$ time ruby parallel.rb
Parent 32771
Child2 32867: 3888888
Child1 32865:
ruby parallel.rb  0.40s user 0.07s system 153% cpu 0.309 total
```
由于每一个进程都只处理集合中的一半的数据, 以上代码比顺序执行的代码稍微快一些,并且占用了多于1个 CPU, 运行时的进程树类似于:
```Ruby
# \ - 32771 ruby parallel.rb (parent process)
#  | - 32865 ruby parallel.rb (child process)
#  | - 32867 ruby parallel.rb (child process)
```
## 优势
  - 进程间不会共享内存，所以你不能在一个进程中修改另一个进程的数据，这使得写代码和调试代码更加简单
  - 在[Ruby MRI](https://en.wikipedia.org/wiki/Ruby_MRI)中，由于GIL（global interpreter lock，后文会有更多关于GIL的信息）的存在，进程是唯一可以使用多余一个CPU核心的方式，在有些方面，比如做数学运算的时候，这种方式也许是很有用的。
  - 开子进程在避免内存溢出上可能有帮助，一旦进程完成，它将释放所有的资源

## 劣势
  - 由于进程不能共享内存，它们将会占用很多内存--意思就是说：跑上百个进程也许是个问题。值得注意的是，从Ruby 2.0 以后， `fork` 使用操作系统的[写时复制（Copy-On-Write）机制](https://en.wikipedia.org/wiki/Copy-on-write)，这使得进程间可以共享内存，前提是这块内存不会被写入不同的值。
  - 创建和销毁进程是很慢的
  - 使用进程可能也要考虑进程间通信，比如:[DRb](https://ruby-doc.org/stdlib-2.4.1/libdoc/drb/rdoc/DRb.html)
  - 当心[孤儿进程(orphan processes)](https://en.wikipedia.org/wiki/Orphan_process)（父进程已经结束或者被杀掉的子进程）和 [僵尸进程(zombie processes)](https://en.wikipedia.org/wiki/Zombie_process)（已经结束但是仍然占据这进程表的子进程）

## 开源实例
  - [Unicorn](https://bogomips.org/unicorn/) server -- 它先加载应用代码，HTTP请求到来时，通过复制（forks）主进程（master process）来产出子进程作为worker来响应实际的HTTP请求。
  - [Resque](https://github.com/resque/resque) 用于处理后台任务 -- 它会运行一个worker， 然后通过复制（fork）子进程来顺序的执行后台任务

# 线程（Threads）
尽管从Ruby 1.8版本开始，Ruby 就使用操作系统原生的线程（threads），由于MRI中GIL的存在，即使你有多个CPU，在一个进程中任意给定的时间点上，只有一个线程可以被执行，GIL同样存在于其他的一些编程语言中，比如Python
## 为什么GIL会存在
这有好些原因，比如：
- 避免在C库（C extensions）中发生条件竞争(race condition),不用考虑线程安全（threads-safety）
- 实现起来更加简单，不用考虑Ruby的数据结构线程安全性

早在2014年的时候，松本行弘就开始考虑[逐步移除GIL](https://twitter.com/yukihiro_matz/status/495219763883163648)，因为它并没有完全保证我们的Ruby 代码是线程安全的，并且限制了我们更好的使用并发。(译者注：GIL的存在是为了保证Ruby底层C代码的线程安全，而不是Ruby代码的线程安全，GIL也没有提供任何应用接口供Ruby应用开发者使用，而上面说的使得实现简单是指在用C实现Ruby 解释器时更简单，而不是开发Ruby代码时更简单。！！！GIL不能保证Ruby代码线程安全！！！）
## 条件竞争（Race-conditions）
这里有一个条件竞争的简单事例：
```Ruby
# threads.rb
@executed = false
def ensure_executed
  unless @executed
    puts "executing!"
    @executed = true
  end
end
threads = 10.times.map { Thread.new { ensure_executed } }
threads.each(&:join)
```
```Bash
$ ruby threads.rb
executing!
executing!
```
我们创建了10个线程来执行 `ensure_executed` 方法，并且对10个线程分别调用了一次 `join` 方法，主线程将会等待所有子线程完成。由于线程共享了变量 `@executed` ,上述代码输出了两次 `executing!` ,我们对变量 `@variable` 的读取和写入不是原子操作，那么在一个线程读取完这个变量以后；修改这个变量以前，这个变量的值也许已经被其他线程给修改了。
## GIL 和 I/O阻塞
GIL不允许在同一个时间执行多个线程不代表线程就没有用武之地了，当线程遇到阻塞式的I/O操作（HTTP 请求，DB 查询，磁盘读/写，甚至是 `sleep` ）时，它会释放GIL
```Ruby
# sleep.rb
threads = 10.times.map do |i|
  Thread.new { sleep 1 }
end
threads.each(&:join)
```
```Bash
$ time ruby sleep.rb
ruby sleep.rb  0.08s user 0.03s system 9% cpu 1.130 total
```
可以看到，10个线程都休眠了1s并且几乎在同一时间运行结束。当一个线程进入休眠，它会将执行权交到其他线程，而不会阻塞GIL
## 优势
  - 更少的内存占用，使得创建上千个线程变得可行，在创建和销毁时速度更快
  - 在I/O阻塞式操作很多时，线程变得非常有用
  - 在需要的时候，可以访问其他线程的内存块

## 劣势
  - 需要非常小心的考虑同步以避免条件竞争的问题，通常使用锁定原语（locking primitives），而有时候又会因此导致死锁发生。以上这些都导致这种线程安全的代码非常难以开发、测试和调试。
  - 使用线程，你不仅仅要保证你的代码是线程安全的，你还要保证你所依赖的代码是线程安全的。
  - 创建越多的线程，将会有越多的资源和时间花在线程间上下文的切换上，将会导致越少的时间花在实际工作的处理中。

## 开源实例
   - [Puma](https://github.com/puma/puma) 服务器 -- 允许进程使用多个线程（集群模式）。与Unicorn 类似，它会提前加载应用代码，并且复制主进程，每一个子进程都有自己的线程池。在大多数情况下，线程都运行的非常不错，因为每一个HTTP请求都可以被一个单独的线程所处理，而且在不同的请求之间没有多少资源需要共享。
   - [Sidekiq](https://github.com/mperham/sidekiq) 后台任务处理 -- 默认情况下跑一个进程，25个线程，每个线程分时的处理一个后台任务。

# EventMachine
EventMachine（又称 EM）是一个用C++和Ruby实现的gem，它使用[反应器模式（Reactor Pattern）](https://en.wikipedia.org/wiki/Reactor_pattern)为Ruby提供了事件驱动I/O（event-driven I/O）的特性, 基本上可以让你的Ruby代码看上去像Node.js。在EM内部，在轮训事件循环期间，EM使用Linux的select()来查看是否有新的输入进入文件描述符。
通常使用EM的理由是：遇到很多I/O操作，而又不想自己手动的操作线程去处理I/O。手动操作线程有点困难而从资源的角度看，时常手动操作线程的开销又有点大。使用EM，不用任何特殊处理，你可以使用一个线程处理多个HTTP请求
```Ruby
# em.rb
EM.run do
  EM.add_timer(1) do
    puts 'sleeping...'
    EM.system('sleep 1') { puts "woke up!" }
    puts 'continuing...'
  end
  EM.add_timer(3) { EM.stop }
end
```
```Bash
$ ruby em.rb
sleeping...
continuing...
woke up!
```
上述例子展示了怎么使用 `EM.system` 来异步运行一个系统命令（I/O操作），并将传入的块当做回调，传入的回调会在系统命令完成后被执行。
## 优势
  - 可以使用单线程为网页服务器、代理服务器等慢网络应用带来卓越的性能
  - 使用它可以避免复杂的多线程编程，复杂的多线程编程的不利之处我们前面已经讨论过了。

## 劣势
  - 所有的I/O操作都需要支持EM异步，这就意味着你应该使用指定的操作系统、DB适配器、HTTP客户端、等等。which can result in monkey-patched versions, lack of support and limited options.
  - 在一个事件循环周期内主线程所完成的工作应该尽可能小，同时，这使得使用[Defer](http://www.rubydoc.info/github/eventmachine/eventmachine/EventMachine.defer)成为可能，Defer会在在线程池中拿一个单独的线程来执行代码，然而它仍然有可能导致我们之前讨论过的多线程的问题。
  - 由于有太多的错误情况需要处理和多重回调的存在，使用这种方式开发复杂的系统是很困难的。回调地狱也是有可能发生在Ruby中的，但是可以通过Fiber来避免，下面我们会讨论到。
  - EM 本身就是一个巨大的依赖库: 17K 行Ruby代码加上10K行C++代码

## 开源实例
   - [Goliath](https://github.com/postrank-labs/goliath/) -- 单线程异步服务器
   - [AMQP](https://github.com/ruby-amqp/amqp) -- RabbitMQ 的客户端，然而这个gem的作者推荐使用不基于EM的版本：[Bunny](http://rubybunny.info/), 需要注意的是，现在都倾向于将工具迁移至尽量少的使用EM的实现方式上。例如：[ActionCable](https://github.com/rails/rails/tree/master/actioncable) 的作者决定使用更底层的[nio4r](https://github.com/socketry/nio4r)，[sinatra-synchrony](https://github.com/kyledrake/sinatra-synchrony)的作者使用[Celluloid](https://github.com/celluloid/celluloid)将其重写了一遍；等等

# Fibers
[Fibers](https://ruby-doc.org/core-2.4.1/Fiber.html)是Ruby中一种用来实现轻量级协同并发操作的原语，它包含在Ruby标准库中，它可以手动的暂停、恢复和安排执行（scheduled），如果你对Javascrip 比较熟悉的话，它有点像ES6中的Generators(我们有一篇文章介绍[Generator and Redux-Saga](https://engineering.universe.com/what-is-redux-saga-c1252fc2f4d1)),可以在一个线程内运行数以万计的Fibers。
通常情况下，我们将Fibers配合EM使用来避免使用回调并且使代码看上去是同步运行的。所以以下代码：
```Ruby
EventMachine.run do
  page = EM::HttpRequest.new('https://google.ca/').get
  page.errback { puts "Google is down" }
  page.callback {
    url = 'https://google.ca/search?q=universe.com'
    about = EM::HttpRequest.new(url).get
    about.errback  { ... }
    about.callback { ... }
  }
end
```
  可以被重写成：
  ```Ruby
EventMachine.run do
  Fiber.new {
    page = http_get('http://www.google.com/')
    if page.response_header.status == 200
      about = http_get('https://google.ca/search?q=universe.com')
      # ...
    else
      puts "Google is down"
    end
  }.resume
end
def http_get(url)
  current_fiber = Fiber.current
  http = EM::HttpRequest.new(url).get
  http.callback { current_fiber.resume(http) }
  http.errback  { current_fiber.resume(http) }
  Fiber.yield
end
```
根本上说，`Fiber#yield` 会把控制权交还到调用者，并且返回最后一个传入 `Fiber#resume` 的参数。
## 优势
  - Fibers 允许你通过重新排布嵌套回调的方式来精简你的异步代码

## 劣势
  - Fibers 并没有真正的解决并发问题
  - 在应用层面上很少使用

## 开源实例
  - [em-synchrony](https://github.com/igrigorik/em-synchrony) 一个库，由Google的一位性能工程师（a performance engineer）Ilya Grigorik开发，在不同客户端上将Fibers集成进EM，支持的客户端有：MySql2，Mongo，Memcached等等。

# 结论
并发问题没有银弹，你需要权衡你的需求来选择一个合适的并发模型。举个例子来说，如果在资源足够的情况下需要运行一些CPU和内存密集型的代码--请使用进程。需要响应像HTTP请求这样的I/O操作的话--使用线程。对最大吞吐量有比较高要求的话--使用EventMachine。
在这一系列文章的第二部分，我们将会讨论像Actors（Erlang，Scala）、Communication Sequential Processes（Go，Crystal）、Software Transactional Memory（Clojure）、Guilds（也许会在Ruby3实现的一种并发模型）等并发模型，敬请期待。
