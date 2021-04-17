
---
title: "devSpec Go 代码审核指南"
linkTitle: "devSpec Go 代码审核指南"
weight: 20
---

本篇文章收集了 Go 代码审核过程中的常见的评论，所以一个详细的解释可以用缩写来指代。 这是一个常见错误的清单，而不是一个全面的风格指南。

你可以将此作为 [Effective Go](https://learnku.com/docs/effective-go/2020) 的补充。



### Gofmt

在你的代码上运行 gofmt 来自动修复大部分的机械样式问题。几乎所有的 Go 代码都使用 gofmt。本文档的其余部分针对非机械的样式点。

另一种方法是在 goimports 中使用 gofmt 的超集，该超集可根据需要额外添加 (和删除) 导入行。

###注释语句

参考 golang.org/doc/effective_go.html#c... 。 记录声明的注释应该是完整的句子，即使这似乎有点多余。 这种方法使它们在提取到
godoc 文档时能够很好地格式化。注释应从所描述的事物的名称开始，并以句号结束：
```go
// Request 表示运行命令的请求。
type Request struct { ...

// Encode 将 req 的 JSON 编码写入 w 。
func Encode(w io.Writer, req *Request) { ...
等等。
```

### 上下文

上下文的值。上下文类型携带跨越 API 和进程边界的安全证书、跟踪信息、截止日期和取消信号。 Go 程序沿着整个函数调用链显式地传递 Contexts ，包含从传入的 RPC 和 HTTP 请求到传出的请求。

大部分使用上下文的函数都要将其作为第一个参数：

```go
func F(ctx context.Context, /* 其他参数 */) {}
```

从来没有具体要求需要使用 `context.Background()` 的函数，但是即使你认为不需要传递上下文 ，也有可能出现错误。默认情况下，都需要传递一个上下文。当你有充分的理由认为替代方案有误的时候，才可以直接使用 `context.Background()`。

不要将上下文作为一个成员添加到结构类型；而是将 ctx 参数添加到该类型的每个方法上。一个例外是方法的签名必须要和标准库或者第三方库中的接口匹配的时候。

不要在函数签名中创建自定义的上下文类型或者使用上下文以外的接口。

如果要传递应用程序数据，请将其放在参数，方法接收器，全局变量中，或者如果它确实应该属于 Context，则放在 Context 的 Value 属性中。

所有的 Context 都是不可变的，因此可以将相同的 ctx 传递给多个共享相同截止日期，取消信号，安全凭据，跟踪等的调用。

### 复制

为避免意外的别名，从另一个包复制 struct 时要小心。例如，`bytes.Buffer` 类型包含一个 []byte 的 slice。如果复制一个 Buffer，副本中的 slice 可能会对原始数组进行别名操作，从而导致后续方法调用产生令人惊讶的效果。

通常，如果 T 类型的方法与其指针类型 *T 相关联，请不要复制 T 类型的值。

### Crypto Rand

不要使用 math/rand 来生成密钥，即使是一次性密钥。在没有种子（seed）的情况下，生成器是完全可以被预测的。使用 `time.Nanoseconds()` 作为种子值，熵只有几位。请使用 `crypto/rand` 的 `Reader` 作为替代，如果你倾向于使用文本，请输出成十六进制或 base64 编码：

```go
import (
    "crypto/rand"
    // "encoding/base64"
    // "encoding/hex"
    "fmt"
)

func Key() string {
    buf := make([]byte, 16)
    _, err := rand.Read(buf)
    if err != nil {
        panic(err)  // 出于随机性，永远都不会发生
    }
    return fmt.Sprintf("%x", buf)
    // or hex.EncodeToString(buf)
    // or base64.StdEncoding.EncodeToString(buf)
}
```

### 声明空的切片

当声明一个空 slice 时，倾向于用
```go
var t []string
```
而不是
```go
t := []string{}
```
前者声明了一个 nil slice 值，而后者声明了一个非 nil 但是零长度的 slice。两者在功能上等同，len 和 cap 均为零，而 nil slice 是首选的风格。

请注意，在部分场景下，首选非 nil 但零长度的切片，例如编码 JSON 对象时（nil 切片编码为 null，而则 []string{} 可以正确编码为 JSON array []）。

在设计 interface 时，避免区分 nil slice 和 非 nil，零长度的 slice，因为这会导致细微的编程错误。

有关 Go 中对于 nil 的更多讨论，请参阅 Francesc Campoy 的演讲 Understanding Nil。

### 文档注释

所有的顶级导出的名称都应该有 doc 注释，重要的未导出类型或函数声明也应如此。有关注释约束的更多信息，请参阅 golang.org/doc/effective_go.html#c...。

### 不要 Panic

请参阅 golang.org/doc/effective_go.html#e...。不要将 panic 用于正常的错误处理。使用 error 和多返回值。

### 错误信息

错误信息不应大写（除非以专有名词或首字母缩略词开头）或以标点符号结尾，因为它们通常是在其他上下文后打印的。即使用 `fmt.Errorf("something bad")` 而不要使用 `fmt.Errorf("Something bad")`，因此 `log.Printf("Reading %s: %v", filename, err)` 的格式中将不会出现额外的大写字母。否则这将不适用于日志记录，因为它是隐式的面向行，而不是在其他消息中组合。

### 例子

添加新包时，请包含预期用法的示例：可运行的示例，或是演示完整调用链的简单测试。

阅读有关 testable Example() functions 的更多信息。

### Goroutine 生存周期

当你生成 goroutines 时，要清楚它们何时或是否会退出。

通过阻塞 channel 的发送或接收可能会引起 goroutines 的内存泄漏：即使被阻塞的 channel 无法访问，垃圾收集器也不会终止 goroutine。

即使 goroutines 没有泄漏，当它们不再需要时却仍然将其留在内存中会导致其他细微且难以诊断的问题。往已经关闭的 channel 发送数据将会引发 panic。在 “结果不被需要之后” 修改仍在使用的输入仍然可能导致数据竞争。并且将 goroutines 留在内存中任意长时间将会导致不可预测的内存使用。

请尽量让并发代码足够简单，从而更容易地确认 goroutine 的生命周期。如果这不可行，请记录 goroutines 退出的时间和原因。

### 处理错误

请参阅 https://golang.org/doc/effective_go.html#errors。不要使用 _ 变量丢弃 error。如果函数返回 error，请检查它以确保函数成功。处理 error，返回 error，或者在真正特殊的情况下使用 panic。

### 包的导入

避免包重命名导入，防止名称冲突；好的包名称不需要重命名。如果发生命名冲突，则更倾向于重命名最接近本地的包或特定于项目的包。

包导入按组进行组织，组与组之间有空行。标准库包始终位于第一组中。
```go
package main

import (
    "fmt"
    "hash/adler32"
    "os"

    "appengine/foo"
    "appengine/user"

    "github.com/foo/bar"
    "rsc.io/goversion/version"
)
```
goimports 会为你做这件事。

### 包的匿名导入

仅出于副作用而导入的软件包（使用语法 import _"pkg"）应仅在程序的 main 包或需要它们的测试中导入。

### Import Dot

部分包由于循环依赖，不能作为测试包的一部分进行测试时，以。形式导入它们可能很有用：
```go
package foo_test

import (
    "bar/testutil" // also imports "foo"
    . "foo"
)
```
在这种情况下，测试文件不能位于 foo 包中，因为它使用的 bar/testutil 依赖于 foo 包。所以我们使用 import . 形式使得测试文件伪装成 foo 包的一部分，即使它不是。除了这种情况，不要在程序中使用 import .。它将使程序更难阅读 —— 因为不清楚如 Quux 这样的名称是否是当前包中或导入包中的顶级标识符。

### 内联错误

在 C 和类 C 语言中，通常使函数返回 -1 或 null 之类的值用来发出错误信号或缺少结果：

// 查找返回键的值，如果没有键的映射，则返回空字符串。
```go
func Lookup(key string) string

// Failing to check a for an in-band error value can lead to bugs:
Parse(Lookup(key))  // 返回 "parse failure for value" 而不是 "no value for key"
Go 对多返回值的支持提供了一种更好的解决方案。函数应返回一个附加值以指示其他返回值是否有效，而不是要求客户端检查内联错误值。此附加值可能是一个 error，或者在不需要解释时可以是布尔值。它应该是最终的返回值。

// 查找并返回键的值，如果没有键的映射，则ok = false。
func Lookup(key string) (value string, ok bool)
这可以防止调用者错误地使用返回结果：

Parse(Lookup(key))  //  编译时错误
并有利于写出更健壮和可读性更强的代码：

value, ok := Lookup(key)
if !ok {
    return fmt.Errorf("no value for %q", key)
}
return Parse(value)
```
此规则适用于公共导出函数，但对于未导出函数也很有用。

返回值如 nil，""，0 和 -1 在他们是函数的有效返回结果时是可接收的，即调用者不需要将它们与其他值做分别处理。

某些标准库函数（如 “strings” 包中的函数）会返回内联错误值。这大大简化了字符串操作，代价是需要程序员做更多事。通常，Go 代码应返回表示错误的附加值。

### 缩进错误处理

要缩进错误处理逻辑，不要缩进常规代码。这样可以改进代码的可读性，读者可以快速地浏览逻辑主干。例如，不要写：
```go
if err != nil {
    // error handling
} else {
    // normal code
}
相反，应该这样写：

if err != nil {
    // 错误处理
    return // 或者继续执行。
}
// 一般代码
如果 if 语句中有初始化逻辑，像这样：

if x, err := f(); err != nil {
    // 错误处理
    return
} else {
    // 使用变量 x
}
那就把初始化移到外面，改成这样：

x, err := f()
if err != nil {
    // 错误处理
    return
}
// 使用变量 x
```

### 首字母缩写

名称中的单词是首字母或首字母缩略词（例如 "URL" 或 "NATO" ）需要具有相同的大小写规则。例如，"URL" 应显示为 "URL" 或 "url" （如 "urlPony" 或 "URLPony" ），而不是 "Url"。举个例子：ServeHTTP 不是 ServeHttp。对于具有多个初始化 “单词” 的标识符，也应当显示为 "xmlHTTPRequest" 或 "XMLHTTPRequest"。

当 "ID" 是 "identifier" 的缩写时，此规则也适用于 "ID" ，因此请写 "appID" 而不是 "appId"。

protocol buffer 生成的代码是个例外，对人和对机器的要求不能一样，人编写的代码要比机器编写的代码保持更高的标准。

### 接口

总的来说，Go 的接口要包含在使用方的包里，不应该包含在实现方的包里。实现方只需要返回具体类型（通常是指针或结构体），这样一来可以将新方法添加到实现中，而不需要扩展重构。

不要在 API 的实现者端定义 "for mocking" 接口；反而是要定义公开的 API，用真实的实现进行测试。

不要先定义接口再用它。脱离真实的使用场景，我们都不能确定一个接口是否有存在的价值，更别提设计接口的方法了。
```go
package consumer  // consumer.go

type Thinger interface { Thing() bool }

func Foo(t Thinger) string { … }
package consumer // consumer_test.go

type fakeThinger struct{ … }
func (t fakeThinger) Thing() bool { … }
…
if Foo(fakeThinger{…}) == "x" { … }
```
```go
// 不要这样做！！！
package producer

type Thinger interface { Thing() bool }

type defaultThinger struct{ … }
func (t defaultThinger) Thing() bool { … }

func NewThinger() Thinger { return defaultThinger{ … } }
```
应该返回具体的类型，让消费者来 mock 生产者的实现：
```go
package producer

type Thinger struct{ … }
func (t Thinger) Thing() bool { … }

func NewThinger() Thinger { return Thinger{ … } }
```

### 代码行长度

在 Go 代码中没有行长度的标准规定，避免不舒服的长度就好；类似的，长一些代码可读性更强时，也不要刻意换行。

大多数非自然（在方法调用和声明的过程中）的换行，都是可以避免的，只要选择合理数量的参数列表和合适的变量名。一行代码过长，往往是因为代码中的各个名字太长了，去掉那些长名字就好了。

换句话说，在语义的分割点换行，而不是单单看行的长度。万一你发现某一行太长了，要么改名，要么调整语义，往往就解决问题了。

实际上，关于一个函数有多长也是一样的建议。这里没有一个 “一个方法不能超过 N 行” 的规定，但是程序中肯定会存在行数太多的函数、功能过于微弱的函数，而解决方案是改变这个函数边界，而不是执着在代码行数上。

### 混合首字母大小写

参考 golang.org/doc/effective_go.html#m...，即使 Go 中混合大小写的规则打破了其他语言的惯例，也是适用的。例如，非导出的常量要命名成 maxLength，而不是 MaxLength 或者 MAX_LENGTH。

也可以参阅 Initialisms.

### 命名结果参数

考虑一下 godoc 中的样式。命名结果参数如下：
```go
func (n *Node) Parent1() (node *Node) {}
func (n *Node) Parent2() (node *Node, err error) {}
```
在 godoc 中会卡顿；最好使用：
```go
func (n *Node) Parent1() *Node {}
func (n *Node) Parent2() (*Node, error) {}
```
另一方面，如果函数返回两个或三个相同类型的参数，或者从上下文中看不出结果的含义，则在某些上下文中添加名称可能会很有用。不要仅仅为了避免在函数内部声明 var 而命名结果参数；可能牺牲了一些简短的实现方式，但付出了不必要的 API 冗长性。
```go
func (f *Foo) Location() (float64, float64, error)
```
不够清晰：
```go
// Location 返回 f 的经度和纬度。
// 负值分别表示南和西。
func (f *Foo) Location() (lat, long float64, err error)
```
如果函数只有几行，则可以使用裸返回。一旦它是一个中等大小的函数，请明确说明您的返回值。结论：仅仅因为它使您能够使用裸返回值而命名结果参数是不值得的。文档的清晰性始终比在函数中保存一两行更为重要。

最后，在某些情况下，您需要命名结果参数，以便在延迟的闭包中对其进行更改。这么做总是对的。

### 裸返回

请参阅 Named Result Parameters.

### 包注释

像 godoc 提出的所有注释一样，包注释必须出现在 package 子句的旁边，且不能有空行。
```go
// Package math provides basic constants and mathematical functions.
package math
```
```go
/*
Package template implements data-driven templates for generating textual
output such as HTML.
....
*/
package template
```
对于 「package main」 的注释，在二进制名称后可以使用其他样式的注释 (并且可以使用大写形式，如果使用的话请大写)，例如，对于 package main 目录中的 seedgen 您可以这样写：
```go
// Binary seedgen ...
package main
```
或
```go
// Command seedgen ...
package main
```
或
```go
// Program seedgen ...
package main
```
或
```go
// The seedgen command ...
package main
```
或
```go
// The seedgen program ...
package main
```
或
```go
// Seedgen ..
package main
```
以上都是举例，它们的合理变体是可以接受的。

请注意，以小写单词开头的句子不属于程序包注释的可接受选项。因为这些都是公开可见的，应该用适当的英语写，包括大写句子的第一个单词。 当二进制名是第一个单词时，即使它与命令行调用的拼写不完全匹配，也需要将其大写。

有关评注惯例的更多信息，参见 https://golang.org/doc/effective_go.html> 。

### 包名

对包中名称的所有引用都将使用包名完成，因此可以从标识符中省略该名称。 例如，如果你正在使用 chubby 包，则不需键入 ChubbyFile ，因为客户端会将其写为 `chubby.ChubbyFile`。 相反，命名为 File 的这种方式，客户端会将它写为 `chubby.File` 。 避免使用像 util 、 common 、 misc 、 api 、 types 和 interfaces 这样无意义的包名。 详见 <http://golang.org/doc/effective_go.html#包-名称> 及 <http://blog.golang.org/package-names> 。

### 参数传递

不要只是为了节省几个字节就将指针作为函数参数传递。如果一个函数在整个过程中只引用它的参数 x 作为 *x，那么这个参数不应该是一个指针。常见的例子包括传递指向字符串 (*string) 的指针或指向接口值 (*io.Reader) 的指针。在这两种情况下，值本身都是固定大小，可以直接传递。这个建议不适用于大型结构体 ，甚至不适用于可能变大的小型结构体。

### 方法接收者命名

方法接收者的名称应该反映其身份；通常，其类型的一个或两个字母缩写就足够了（例如用 "c" 或 "cl" 表示 "client" ）。不要使用通用名称，例如 "me"，"this" 或 "self"，这是面向对象语言的典型标识符，这些标识符赋予该方法特殊的含义。在 Go 语言中，方法接收者只是函数的一个参数而已。方法接收者的命名不必像方法的其他参数那样具有描述性，因为它的作用是显而易见的，没有任何文档目的。命名可以非常短，因为它几乎将出现在该类型的每个方法的每一行中；熟悉意味着简洁。使用上也要保持一致：如果你在一个方法中叫将接收器命名为 "c"，那么在其他方法中不要把它命名为 "cl"。

### 方法接收者类型

选择到底是在方法上使用值接收者还是使用指针接收者可能会很困难，尤其是对于 Go 新手程序员。如有疑问，请使用指针接收者，但有些情况下用值接收者更有道理，性能更好，例如小的不变结构或基本类型的值。以下是一些有用的指导：

如果接收者是 map，func 或 chan，则不要使用指针。如果接收者是 slice 并且该方法不重新切片或不重新分配切片，则不要使用指针
如果该方法需要改变接收者的值，则必须用指针。
接收者内含有 `sync.Mutex` 或者类似的同步域，那就必须指针，以避免拷贝。
接收者是一个大数据结构或者数组，指针会效率更高。 多大才算大？假设它相当于将其包含的所有元素作为参数传递给方法。如果感觉太大，那么对接收者来说也太大了。
函数或方法（同时执行或调用某方法时继续调用相关方法或函数）是否会使接收者发生变化？在调用方法时，值类型会创建接收者的副本，因此外部更新将不会应用于此接收者。如果必须在原始接收者中看到更改效果，则接收者必须是指针。
如果接收者是一个结构、数组、slice，且内部的元素有指针指向一些可变元素，那更倾向于用指针接收，来提供更明确的语义。
若接收者是一个小对象或数组，概念上是一个值类型（比如 `time.Time`），并且没有可变域和指针域，或者干脆就是 int、string 这种基本类型，适合用值接收者。值接收者可以减少垃圾内存，通过它传递值时，会优先尝试从栈上分配内存，而不是堆上。但保不齐在某些情况下编译器没那么聪明，所以这个在用之前要 profiling 一下。
最后，要是把握不准，就用指针。

### 同步函数

首选同步函数 - 直接返回结果或在返回异步函数之前完成任何回调或通道操作的函数。

同步函数使 goroutines 能够在调用中本地化，从而使其在生命周期中更显得合理，避免泄漏和数据竞争。它们也更容易测试：调用者可以传递输入并检查输出，而不需要轮询或同步。

如果调用者需要更多的并发，可以从一个单独的 goroutine 调用函数来轻松地添加它。 但是，在调用方删除不必要的并发是相当困难的，有时是不可能的。

### 有用的失败测试

失败的测试应该体现有用的信息，说明什么是错误的，什么是输入，什么是实际得到的，什么是预期的。 编写一组 assertFoo 帮助程序可能很诱人，但请确保您的帮助程序产生有用的错误消息。假设调试失败测试的人不是您，也不是您的团队。 典型的 Go 测试失败案例如下：
```go
if got != tt.want {
    t.Errorf("Foo(%q) = %d; want %d", tt.in, got, tt.want) //或 Fatalf ，如果测试不能测试任何超过此时的点
}
```
请注意，这条命令结果 != 预期，消息也使用该命令。 一些测试框架鼓励反写这些内容： 0 != x 表示 “预期 0 ，得到 x ” 等等。 但 Go 并不鼓励这样写。

如果看起来需要不少的代码，那您可能希望编写一个表格驱动测试。

在使用具有不同输入的测试助手时，另一种消除失败测试歧义的常见技术是用不同的 TestFoo 函数将每个调用者包装起来，因此使用该名称测试时失败：
```go
func TestSingleValue(t *testing.T) { testHelper(t, []int{80}) }
func TestNoValues(t *testing.T)    { testHelper(t, []int{}) }
```
在任何情况下，您都有义务在测试失败时将有用的信息传递给将来调试代码的人。

### 变量名称

Go 中的变量名称尽可能短为妙，言简意赅，尤其是对于那些处于有限空间中的局部变量更是如此。例如： 用 c 而不是 lineCount； 用 i 而不是 sliceIndex 。

基本准则：当变量首次被使用时离声明的位置越远，变量名称必须更具描述性。对于方法接收者的名称来说，一个或者两个字母就足够了。普通变量比如 loop indices 、 readers 的名称用一个字母（i , r）指代就可以。非常规事物和全局变量则需使用更具描述性的名字。