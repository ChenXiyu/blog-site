---
title: scrum 精髓
date: 2018-11-27 20:02:03
draft: true
tags: Scrum
categories: Methodology
---
参加了ThoughtWorks在公司内部举办的敏捷教练培训，推荐的入门读物是《scrum 精髓：敏捷转型指南》，本博文会记录读书过程结合培训课程的笔记和想法、感受。博文也会随着读书/学习进度的推进更新、修订
<!--more-->
言归正传，对于一个刚刚开始系统学习scrum的同学来说，出现在脑海中的第一个问题大概就是：到底scrum是什么？书中的定义是：**Scrum 是一种用于开发创新产品和服务的敏捷方式**，抛开一切修饰语句，Scrum其实就是一系列具体的做法（way），一种方式；理解和不理解scrum的人都可以照猫画虎的执行scrum，但是照猫画虎的实践scrum并不能给你带来一枚银弹，Scrum并不能按照指定的规则解答开发过程中遇到的问题，它的意义在于赋予团队自己提出问题并解决问题的能力，scrum并不会给每个人提供一个刻板的解决方案，而是把妨碍一个组织发掘自己全部潜力的问题与浪费的地方全部暴露出来。只有真正了解了scrum各个实践如此这般设计的初衷和原则才能让scrum更好的为自己的团队服务。
<!--more-->
## 推动并影响Scrum的原则和方法
敏捷思想提出以前，业界大都采用瀑布式方法进行开发，瀑布式开发像是从传统工业生产中借鉴出来的生产方式--在“完好”的设计以后再按照一个预设的流程将预先设计“好”的产品制造出来。这种方式适合按照规定的流程批量的生产同样的产品，适合解决一个处在Cynefin框架中的繁杂域的问题。而对很多人来讲，像瀑布开发一样的计划驱动的顺序过程是合情合理的，他们觉得使用这种过程没有得到好的效果只是自己在某些方面还做的不够好，他们相信，只要做得更好，问题就一定会得到改善。
然而，问题并不在与执行，问题在于计划驱动的方法所奉行的理念根本无法适应大多数产品开发工作所固有的不确定性。
基于这种状况，敏捷思想应运而生，敏捷所遵循的理念很好的处理了高不确定性而导致很难作出宏观预测这个问题。
### 可变性和不确定性
Scrum巧用产品开发的可变性和不确定性来产生创新解决方案。
#### 积极采用有帮助的可变性
正如前面提及的，顺序开发过程把软件开发当作制造业，尽量避免任何的变数，鼓励遵循规程。但是，在软件开发中，我们的目的不是制造一个可以重复制造的产品，而是创建一个产品的单一事例，它必定是独一无二的，甚至，它的每个feature都是独一无二的，与其他feature都是不一样的。这样的产品本身就存在可变性。
#### 采用迭代和增量开发
计划驱动的方式假设我们能够一次就把事情做对，大多数部件都是到后期才集成。而Scrum 采用迭代开发和增量式开发。
迭代开发承认我们在把事情做对之前可能会做错，再把事情做好之前可能会做坏。
迭代开发本身是一种有计划的修改策略，通过多次开发来改善正在构建的特性，逐步得出一个完善的解决方案。在产品开发过程中，迭代开发是改进产品的一种非常好的方法，但是，迭代开发也有自己的局限性：遇到不确定因素时，很难事先确定需要改进多少次
增量开发基于一个古老的原则：先构建部分，再构建整体。我们把产品分解成更小的特性，先构建一部分，再从中了解它们再目标环境中使用的具体情景，然后根据更多的理解来作出调整，构建更多的特性。我们避免最后才冒出一个大的、爆发式的活动，集成所有的组件和交付整个产品。增量开发方式能够给我们提供重要的信息，使我们能够适应开发工作并改变工作方式。同样的增量开发也有自己的局限性：在逐步构建的过程中，有迷失全局的风险。
scrum综合迭代开发和增量开发的优点，弥补了单独使用任意一个的局限性。scrum使用一系列适应性迭代来同时使用这两种开发方法，这种迭代便叫做 ***冲刺***
在冲刺中，并不是一次只做一个阶段的工作，而是每次冲刺做一个特性，这样以来，冲刺结束时就能创建一个有价值的 ***产品增量***（产品的部分特性，而不是全部）。这个增量需要包含前期以开发的特性或者需要与前期以开发特性进行集成与测试，否则就不能算完成。
#### 通过检视、调整和透明来利用可变性
前面已经提到，scrum主动接受这样的事实：在产品开发中，只要是构建新的东西，就必然存在一定的可变性，Scrum还假设，产品的创建过程是及其复杂的，无法事先就给出详尽、严密的完整定义。Scrum中的核心原则就是：检视、调整和透明。这里的检视和调整不仅仅针对我们的正在构建的产品，还针对我们构建产品的方式。
而为了更好的检视与调整，我们依赖于透明性，参与创建产品的每一个人都必须能够得到与WIP相关的所有重要信息。信息透明，才能进行检视，而检视又是调整的前提。
#### 同时减少各种个样的不确定因素
通常来说软件开发是一个及其复杂的工作，具有极高的不确定性，这种不确定性可以分为两大类：
- 结果不确定性（不确定做什么）-- 围绕最终产品特性的不确定性
- 方法不确定性（不确定该怎么做）-- 围绕开发过程和技术的不确定性

传统的瀑布开发是事先全部定义需要构建的特性，先重点消除结果的不确定性，后处理方法的不确定性。然而，这种简单、线性的方法并不能降低不确定性，因为在复杂领域问题中，我们采取的行动与所处的环境是有相互制约关系的。
在scrum中，我们不会限制自己先处理一方面的不确定性以后才处理另一类的不确定性，相反的，我们采取更全面的方法，重点关注同时减少各方面的不确定性。
通过迭代开发、增量开发，并经常性的检视与调整，可以同时解决多种类似的不确定性。

### 预测和适应
在使用Scrum时，经常需要平衡预测性的事前工作与适应性的适时工作之间的关系。
#### 不到最后时刻，不轻易做决定
与顺序开发方式中必须在当前阶段就作出重要的决策并进行审批相比，scrum认为，不应该单单因为通用过程要求此时作出决定就作出不成熟的决定，在使用scrum时，我们倾向于‘不轻易做决定’这个策略。通常在‘最后责任时刻’再作出重要的、不可逆转的决定。最后决定时刻指的是：随着时间的推移，决策成本降低，拖延成本上升，当决策成本等于拖延成本时，就是最后决定时刻。
总结来说，我们应该在掌握尽可能多的信息以后才作出重要的决策
#### 承认无法一开始就把事情做对
与计划驱动所遵循的“事先就能把事情做对”不同，Scrum承认我们不可能事先确定所有需求和计划，事实上，那样的认为也很危险，因为有很大的概率会漏掉重要的知识而产生大量的低质量需求。
![计划驱动的需求获取与产品知识积累 （图片来源《scrum精髓-敏捷转型指南》）](/images/scrum1.jpg)
如上图所示，计划驱动过程中，在早期产品知识积累有限的时候就产生了绝大多数的需求，这样做是有很大的风险的，它会让我们产生我们已经消除了不确定性的错觉，一旦事情有变，就会产生巨大的浪费。
在Scrum中，我们也会预先产生需求和计划，但是，够用就好。在构建产品的过程中，一旦获取到更多的知识，我们会逐步的填充我们的需求和计划的细节。种种实际情况都会推动我们改变初衷，去做真正适用、适时的东西。
#### 偏好适应性、探索式的方式
相对传统计划驱动方式中使用已知的东西对未知东西进行预测的方式，Scrum更加倾向于采用探索式方法，在探索式方法的基础上采用适应性的试错法。这里的探索指的是通过某些活动来获取知识，比如构建原型、创建概念验证等。
如今Scrum能够使用探索式的方式很大程度归功于工具和技术的进步带来了探索成本的降低和反馈速度的提升。
在Scrum中，人们相信只要具备足够的知识，就可以得出明智、合理的最终解决方案。而在面对不确定时，不要一厢情愿的预测，要用低成本的探索方式来换取相关信息，并综合利用这些信息得出明智、合理的最终解决方案。
#### 用经济合理的方法积极主动的接受变化
我们都知道，采用顺序开发方式时，后期变更的成本会比早期变高很多。而理想状况下，我们期望：小的需求变更所造成的实现方式的变化也相对较小，因而成本变更也小（不难想象，大型变更带来的成本显然更高），而且不管变更何时出现，都应该保持这种关系。在顺序开发中，为了避免后期变更，只能提高预测的准确度，澄清系统需求及其实现过程，再加以严格的控制，力求最小化需求和设计变更。不幸的是，早期活动阶段的过度预测往往适得其反，不仅无法消除变更，反而成为项目延期、预算超支的原因。为了消除昂贵的变更，我们被迫在每个阶段都进行过度投资，做一些不必要、不切实际的工作，在没有得到干系人对工作产品的反馈来验证假设之前我们被迫在过程早期作出重要的假设，根据这些假设而产生大量的工作库存，随着时间的推移，这些假设被证实（或者被推翻）或发生变更的时候，很有可能就要修改或者放弃原有的工作成果。
在Scrum中，我们认为变更是很正常的，产品开发所固有的不确定性无法事先通过加班加点来预测，必须做好准备迎接变更。因此，我们的目标是变更成本曲线尽可能的长期保持平稳，即使在后期接受变更，开销也是经济合理的。Scrum通过WIP管理和工作流管理来趋近这个目标，与传统开发相比，使用Scrum的变更成本受时间的的影响 **更小**（但不是不受影响）
在Scrum中，很多工作都是以刚刚好的方式产生的，避免创建非必须的工件，这样，在迎接变更时，不必丢弃或修改基于假设而产生的工作，让成本和变更请求的大小更成比例。
再次强调：虽然Scrum不会像顺序开发一样库存随着时间的推移而增加，使得早期所做的工件和被迫作出的轻率决定最终导致变更成本的快速上升，但是，在Scrum中，到达某个时间点以后，变更成本和变更请求大小的比例也会变得很离谱，只是这个时间点会出现的更晚一些。
#### 在预测性的事前工作也适时工作之间作出平衡
计划驱动开发有一个基本的理念：事先得到的详细需求和计划是至关重要的，并且做事情要有先后，在scrum中，我们相信前期工作有帮助，但是不宜过度。scrum的要义是找到平衡点，即取得平衡预测性的前期工作和适应性的刚好及时的工作的平衡。
平衡一定程度上由以下几个因素推动：说构建产品的类型、待构建的产品（结果不确定性）、产品的构建方式（方法不确定性）的不确定程度以及开发中的限制。过度的调整可能让我们处于动荡中，让人觉得工作效率底下、混乱，为了能够快速开发创新产品，在我们的工作环境中，一方面要调整，一方面也要通过刚好够的预测来取得平衡，以免陷入混乱。
### 经验认知
在scrum中，我们对工作进行组织，快速产生经验认知，最初的假设一旦被确认或推翻,我们就获得了经验认知。
#### 快速验证重要的假设
所谓的假设，就是某些猜测或者看法并没有被之前的认知所验证过，但我们认为它是正确的、真实的、可靠的。与scrum相比，计划驱动开发对长期存在的假设更宽容。使用计划驱动开发，前期会产生大量的需求和计划，其中可能有很多假设得留到开发后期才能得到验证。假设本身就意味着重大的开发风险。在scrum中，我们力求假设最少，并且通过迭代开发和增量开发，将验证周期缩到最短，最快得到经验认知。
#### 利用多个认知循环并行的优势
传统循序开发是可以获得认知的，但是，依据顺序开发的特点，特性在经过构建、集成、测试以后才能获得认知，这意味着工作快结束时，才获得认知，可能没有足够的时间利用认知了。在scrum中，我们会找到并利用反馈循环来提高认知。在产品开发中，下图的模式反复出现 ![认知循环模式](/images/scrum_cognitive_cycle_pattern.jpg)
scrum 充分利用了几种预定义的认知循环，例如，每日例会是一个每日循环，冲刺评审活动是一个迭代级别的循环。
#### 组织妥善工作流以获得快速反馈
在计划驱动的开发过程中，它遵循：完成早期活动的时候，不需要后期活动的任何反馈。所以，在做完一件事以后要很长时间才能得到这件事相关的反馈，而快速对较早的阶段错误路径非常有帮助，对快速发现并利用时效性、突然出现的商机至关重要，所以scrum会力求快速反馈。使用scrum需要我们组织好工作流，在上图的认知循环中移动，迅速获取反馈。这种做法能确保工作已完成就能得到及时的反馈，快速反馈也能提供比较好的经济效益。
### WIP(work in process)
WIP指的是已经开始但是尚未完成的工作。在产品开发过程中，必须识别出WIP并进行妥善的管理。
#### 批量大小要经济合理
计划驱动倾向于采用“整体推进”，即将相同类型的工作分批汇集到一个独立的阶段中执行，在开始后续阶段之前，必须先全部完成当前阶段的所有事情（或者大体上完成所有事情）。之所以会有这种倾向，是因为相信以前制造业的规模经济原则也适用于软件开发。
Scrum支持：虽然规模经济的思想已经成为制造业的基本规则，但是把它生搬硬套到产品开发中，会造成重大的经济危害，使用scrum进行产品开发中采用小批量的方式。

|好处|描述|
|---|---|
|减少周期时间|批量较小时，等待处理的工作也少，意味着等待时间不会很长，工作完成的更快|
|减少工作的变动|想象一下，在一个餐馆中，顾客零散的进进出出，现在再想象一下从一辆大巴上走下来的观光游客进入餐厅，对餐厅人流有什么影响。*没有太明白这个例子和工作变动的关系。|
|加速反馈|小批量有利于加速反馈，能够最小化错误的影响|
|减小风险|小批量以为着受变更影响的库存更少，小批量失败的可能性也更小|
|降低管理成本|大批量工作需要花费更大的成本来管理|
|积极性和紧迫性提高|小批量更容易让人专注，更有责任意识，与大批量相比，小批量更容易看到拖延和失败的后果|
|降低成本，减少计划延期|如果在大批量时出错，成本和时间安排都会出现比较大的错误，使用小批量，即使出错也不会错的太离谱|
虽然说采用小批量有好处，但也不是指我们应该让WIP 等于1，把“一个”当作目标，对工作流和整体经济来说，充其量也只是局部最优
#### 识别并管理库存资源以达到良好的流动
开始时我不太明白为什么将WIP理解成库存，现在我觉得可以这么理解，制造也的库存，可以解释为做完的商品，没有销售出去，而制造完成的产品并没有走完它的生命线，而是滞留在了其中的一个环节。在产品开发中，一个阶段的产品没有往下一个阶段推进，我们也可以将其理解为该阶段的库存。
制造业很重视库存管理，因为他们的库存是看得见的、实体的。如果存在大量的库存，而需求又发生了变化，那会导致巨大的浪费。但是，传统的软件业是很难意识到自己的库存成本的，传统开发中，批量设置的非常大，通常是100%，倾向与制造大库存，和制造业类似，产品开发中如果出现大量的WIP，后果也是很严重的，它会严重影响前面说引入的变更成本曲线。
在scrum中，开始时，确实需要一些需求，但并不是全部需求，如果太多，再需求发生变化时会出现库存浪费，但是，如果需求库存不足，又会破坏工作的快速流动，这也是一种浪费。Scrum的目标是合理的平衡适量库存和过多库存之间的关系。
#### 关注闲置工作，而非闲置人员
闲置工作是指，有些工作我们想做，但是由于其他事情的阻碍而无法做（如构建或者测试）。人员空闲指的是员工又能力做更多的工作，但是当前并没有100%的投入。一般管理方法趋向与减少人员的闲置，遗憾的是，这种方法降低一种浪费（人员空闲浪费）的同时又增加了另外一种浪费（工作停顿造成的浪费），而且大多数时候，工作停顿造成的浪费比人员空闲导致的浪费成本更高。在scrum中，我们敏锐的意识到：需要找出工作流中的瓶颈，然后集中精力消灭它，相对与让每个人都100%连轴转，这样做更加经济合理。
#### 考虑延期成本
延期成本是工作延期或里程碑延期达成所产生的财务成本。在产品开发中，我们会持续面临这种权衡；要想作出经济合理的决定，延期成本是一个需要考虑、最重要的变量。
### 进度
在使用scrum时，既不是用既定计划的执行情况来衡量进度，也不是用某个特定时期或开发阶段的工作有多大的进展来衡量工作进度，而是用已交付且验证过的结果来衡量的。
#### 根据实时信息来重新指定计划
在scrum中，我们认为盲目相信计划会让我们忽视“计划可能有错”这个事实。在scrum开发过程中，我们的目标不是满足某个计划或者某个事先认为事情该如何进展的预言。我们的目标是快速地重新制定计划并根据开发过程中不断出现的、具有重要经济价值的信息进行调整。
#### 通过验证工作结果来度量进度
在计划驱动开发中，进度的表现方式是完成一个阶段之后可以允许进入下一个阶段。因此，只要每个阶段的开始和结束都符合预期，进度就算非常好，但是，即使按照这种方式，在项目后期，完全按照计划开发出来的产品却不一定能符合客户的需要，这种按时完成但是不一定递交价值的产品算成功吗？
在Scrum中，通过构建可工作的、已验证的成果来度量进度，这些工作成果交付了价值并且可以用来验证重大的假设。在scrum中，重要的不是开始了多少工作，而是完成了多少对客户有价值的工作。
#### 聚焦于价值为中心的交付
传统的顺序开发关注的是谨慎、踏实的遵循过程，顺序开发的结构注定了只有在工作快结束时才能集成并交付特性。这种方法带来的风险是，在向客户交付所有重要价值之前，所有资源可能已经被耗尽了。
传统开发的另一个理念是，在交付特性的过程中产生的计划和文档本身也有价值。但即使这些工件真的有价值，也局限与对下游过程有价值，而非对客户有价值。即使是对客户有价值，也只有在产品交付给客户以后才能为客户创造价值。在此之前，这些工件并没有为客户创造直接的价值。
另一方面，scrum是基于客户价值为中心的开发方式，它是基于优先级排序的增量交付模型，价值最高的特性持续构建并在下一个迭代中交付。在scrum中，价值的产生是通过向客户交付可工作的资产、验证重要的假设或获取有价值的认知来实现的。我们认为中间工件并不能直接为客户带来价值，如果他们本身不能用来产生重要的反馈或获取重要的知识，就只能是一种手段。
### 执行
#### 快速前进，但不匆忙
scrum的核心目标是灵活、适应、快速。通过快速前进、快速交付、快速获得反馈并尽可能的将价值交付到客户手中，而非像计划驱动的开发方式一样指遵循计划，期望第一次就把事情做对，以期减少未来的高成本、耗时长的返工
但是，不要着急慌忙的前进，在scrum中，我们需要遵循可持续节奏的原则--人们应该以长期稳定的节奏工作。而且，充满还有可能付出代价。
要快，但是不匆忙。
#### 内建质量
在传统顺序开发中，人们需要小心、顺序的执行工作已得到高质量的产品。但是，在集成、测试以前，人们没有办法验证产品的质量，而集成、测试在整个环节的最后面
在scrum团队中，质量并不是最后测试团队测试出来的。而是团队内建到每一个迭代中的。每个冲刺结束，只有质量达标才能算是一个有价值的增量。这样便减少了后期做大量测试来验证质量的情况。
#### 采用最小够用的仪式
在scrum中，团队的目标是消除繁文缛节。因此scrum团队的仪式有个最低标准：“基本够用”。scrum关注最小够用的仪式，人们常常误解其为反文档，相反，scrum团队会去审视需要创建那些文档，如果文档不能带来价值，那么文档确实没有用。Scrum提倡尽量避免不增加任何短期和长期经济价值的工作，scrum团队应该坚信；时间和金钱最好是用于交付客户价值。