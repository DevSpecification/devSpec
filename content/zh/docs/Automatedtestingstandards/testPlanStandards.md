---
title: "单元测试实战"
linkTitle: "单元测试实战"
weight: 30
---
## 单元测试常见名词解释

### 覆盖率

### 自动化

### Mock

对于一些不容易构造或获取的对象，例如HTTP API等需要依赖外部其他接口、运行特定环境的测试，就需要借助Mock工具来提高的单元测试覆盖率。
Mock工具往往通过替换需要模拟的对象，来给定我们期望的值。

Mock是单测的常见需求，每种语言都有成熟的Mock框架，大多数成熟的开源系统源码中都含有Mock框架的代码。

## Python单元测试框架

`Python`主流的单测框架包括`unittest`、`pytest`。

> **参见：**
>
> [doctest](https://docs.python.org/zh-cn/3/library/doctest.html#module-doctest) ---文档测试模块
>> 另一个风格完全不同的测试模块。
>
> [简单Smalltalk测试：带参模式](https://web.archive.org/web/20150315073817/http://www.xprogramming.com/testfram.htm)
>> Kent Beck开发的带参数的unittest模式的测试框架论文。
>
> [pytest](https://docs.pytest.org/)
>> 第三方单元测试框架，提供轻量化的语法来编写测试，例如：assert func(10) == 42。
>
> [Python 测试工具分类](https://wiki.python.org/moin/PythonTestingToolsTaxonomy)
>> 一个 Python 测试工具的详细列表，包含测试框架和模拟对象库。
>
> [Python 中的测试 邮件列表](http://lists.idyll.org/listinfo/testing-in-python)
>> 一个讨论 Python 中的测试和测试工具的特别兴趣小组。
>
> 随 Python 源代码分发的脚本 Tools/unittestgui/unittestgui.py 是一个一个用于发现和执行测试的用户图形界面工具。这主要是为了方便新手使用单元测试制作的。在生产环境中，测试应由一个持续集成（CI）系统运行，如 Buildbot, Jenkins ，Travis-CI, 或 AppVeyor。

### unittest(PyUnit)简单介绍

`unittest`是`python`官方标准库中自带的单元测试框架，也称为`PyUnit`。类似于`JUnit`是 `java`语言的标准单元测试框架一样。`unittest`对于`python2.7+`、`python3`使用方法一致。  
可以查看[官方文档](https://docs.python.org/zh-cn/3/library/unittest.html "查看中文官方文档")以获得更详细的介绍。

官网提供了一个示例如下：

```python
import unittest

class TestStringMethods(unittest.TestCase):

    def test_upper(self):
        self.assertEqual('foo'.upper(), 'FOO')

    def test_isupper(self):
        self.assertTrue('FOO'.isupper())
        self.assertFalse('Foo'.isupper())

    def test_split(self):
        s = 'hello world'
        self.assertEqual(s.split(), ['hello', 'world'])
        # check that s.split fails when the separator is not a string
        with self.assertRaises(TypeError):
            s.split(2)

if __name__ == '__main__':
    unittest.main()
```

大部分时候，这个示例已经能解决问题了。在这个示例中**继承自`unittest.TestCase`的`TestStringMethods`类是一个测试实例**，`TestStringMethods`类中**以`test_`开头的类方法则是会被自动执行的测试方法**。

每个测试的关键在于调用`assertEqual()`来检查预期的结果；`assertTrue()`或`assertFalse()`验证条件；或者`assertRaises()`验证是否引发了特定的异常。使用这些方法代替`assert`语句，因此测试运行者可以累积所有测试结果并生成报告。  
`setUp()`和`tearDown()`方法允许你定义将在每次测试方法之后执行的指令。在组织测试代码部分详细介绍了它们。

最后一个块显示了一个运行测试的简单方法。`unittest.main()`为测试脚本提供了一个命令行界面。当从命令行运行时，上面的脚本会产生如下所示的输出：

```Python
...
----------------------------------------------------------------------
Ran 3 tests in 0.000s

OK
```

当然也可以在运行[`unittest.main()`](https://docs.python.org/3/library/unittest.html#unittest.main)时使用`-v`选项以查看更多信息：

```Python
test_isupper (__main__.TestStringMethods) ... ok
test_split (__main__.TestStringMethods) ... ok
test_upper (__main__.TestStringMethods) ... ok

----------------------------------------------------------------------
Ran 3 tests in 0.001s

OK
```

> **参考资料：**  
> `[1] Python Software Foundation.Development Tools,unittest[EB/OL].https://docs.python.org/3/library/unittest.html, -/2021-11-10`

### Python Mock 单测实战

[`unittest.mock`](https://docs.python.org/zh-cn/3/library/unittest.mock.html#module-unittest.mock)是一个用于测试的Python库。它允许使用模拟对象来替换受测系统的一些部分，并对这些部分如何被使用进行断言判断。  
[`unittest.mock`](https://docs.python.org/zh-cn/3/library/unittest.mock.html#module-unittest.mock)提供的[`Mock`](https://docs.python.org/zh-cn/3/library/unittest.mock.html#unittest.mock.Mock)类能在整个测试套件中模拟大量的方法。创建后可以断言调用了哪些方法/属性及其参数。还可以以常规方式指定返回值并设置所需的属性。  
此外，`mock`还提供了用于修补测试范围内模块和类级别属性的[`patch()`](https://docs.python.org/zh-cn/3/library/unittest.mock.html#unittest.mock.patch)装饰器，和用于创建独特对象的[`sentinel`](https://docs.python.org/zh-cn/3/library/unittest.mock.html#unittest.mock.sentinel)。

Mock基于单位测试设计，区别于其他Mocking框架所用的“记录-重复”("record -> replay")模式，本框架基于“动作-断言”("action -> assertion")模式。

`unittest.mock`的[官方文档](https://docs.python.org/zh-cn/3/library/unittest.mock.html)上给出了一些基础示例，这里结合实际场景简单叙述：

1. 如下场景：支付是一个独立的接口，由其它开发提供，根据支付的接口返回状态去显示失败，还是成功，这个是你需要实现的功能。  
   也就是说你写一个b功能，你的同事写一个a功能，你的b功能需要根据a功能的结果去判断，然后实现对应的功能。这就是存在依赖关系，你同事开发的进度你是无法控制的
你要是等他开发完了，你再开发，那你就坐等加班吧.

2. 以下是网友写的zhifu_statues()函数功能，大概设计如下，保存为temple.py文件

    ```Python
    # -*- coding: utf-8 -*-
    # temple.py
    # 作者：上海-悠悠 QQ交流群：588402570

    def zhifu():
        '''假设这里是一个支付的功能,未开发完
        支付成功返回：{"result": "success", "reason":"null"}
        支付失败返回：{"result": "fail", "reason":"余额不足"}
        reason返回失败原因
        '''
        pass

    def zhifu_statues():
        '''根据支付的结果success or fail，判断跳转到对应页面'''
        result = zhifu()
        print(result)
        try:
            if result["result"] == "success":
                return "支付成功"
            elif result["result"] == "fail":
                print("失败原因：%s" % result["reason"])
                return "支付失败"
            else:
                return "未知错误异常"
        except:
            return "Error, 服务端返回异常!"
    ```

3. 单元测试用例设计

    ```Python
    # -*- coding: utf-8 -*-
    # 作者：上海-悠悠 QQ交流群：588402570
    from unittest import mock
    import unittest
    import temple

    class Test_zhifu_statues(unittest.TestCase):
        '''单元测试用例'''
        def test_01(self):
            '''测试支付成功场景'''
            # mock一个支付成功的数据
            temple.zhifu = mock.Mock(return_value={"result": "success", "reason":"null"})
            # 根据支付结果测试页面跳转
            statues = temple.zhifu_statues()
            print(statues)
            self.assertEqual(statues, "支付成功")

        def test_02(self):
            '''测试支付失败场景'''
            # mock一个支付成功的数据
            temple.zhifu = mock.Mock(return_value={"result": "fail", "reason": "余额不足"})
            # 根据支付结果测试页面跳转
            statues = temple.zhifu_statues()
            self.assertEqual(statues, "支付失败")

    if __name__ == "__main__":
        unittest.main()
    ```

4.单元测试是为了保证函数的每个分支都测到，以上zhifu_statues()函数有四个分支，也就是说要写四个案例，这里我只写了2个，还有2个案例可以自行练习。

> **参考资料：**  
> `[1] Python Software Foundation.unittest.mock — mock object library[EB/OL].https://docs.python.org/3/library/unittest.mock.html, -/2021-11-10`  
> `[2] 上海-悠悠.python笔记23-unittest单元测试之mock[EB/OL].https://www.cnblogs.com/yoyoketang/p/9346660.html, 2018-07-21/2021-11-10`

## Golang单元测试

## js单元测试
