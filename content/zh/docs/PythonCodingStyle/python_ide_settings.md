---
title: "Python集成开发环境/编辑工具代码检查插件设置"
linkTitle: "Python集成开发环境/编辑工具代码检查插件设置"
weight: 10
---

## 常用编辑器

区别于Java或者C这类需要编译的软件，Python在开发时几乎不需要专用的编辑软件，但是一个优秀的IDE总是能在开发时提供巨大的帮助。

Python常用的编辑器有PyCharm、VS Code、vim、Eclipse with PyDev、Sublime Text、Emacs、Wing、PyScripter、The Eric Python IDE等，选择一款适自己喜欢的就好。这里主要介绍的 是PyCharm和VS Code。

## PyLint

Pylint 是一个 Python 代码分析工具，它分析 Python 代码中的错误，查找不符合代码风格标准（Pylint 默认使用的代码风格是 PEP 8，具体信息，请参阅参考资料）和有潜在问题的代码。

- Pylint 是一个 Python 工具，除了平常代码分析工具的作用之外，它提供了更多的功能：如检查一行代码的长度，变量名是否符合命名标准，一个声明过的接口是否被真正实现等等。
- Pylint 的一个很大的好处是它的高可配置性，高可定制性，并且可以很容易写小插件来添加功能。
- 如果运行两次 Pylint，它会同时显示出当前和上次的运行结果，从而可以看出代码质量是否得到了改进。

## YAPF

目前用于Python的格式化程序（如autopep8和pep8ify）都用于删除代码中的lint错误。这有很明显的局限性。

YAPF采用了不同的方法，基于Daniel Jasper开发的“'clang-format”。从本质上来说，该算法取走代码并重新排版，以符合样式指南的最佳格式，即便原始代码没有违反样式指南。这个想法也是类似于Go编程语言的gofmt工具。

其最终目标是让YAPE所产生的代码可以与程序员所写的代码一样好（前提是程序员遵循样式指南），它取代了一些维护代码的苦差。

## PyCharm安装代码审查插件

### 安装插件

不管是否安装IDE的代码格式化插件，要使用PyLint及YAPF 首先得安装他们：

```bash
pip install pylint
pip install yapf
```

> Tip: 由于PyLint审查代码时的一下问题，如果项目存在`虚拟环境`，为了避免PyLint误报找不到module，建议将`pylint`安装在虚拟环境中。

在PyCharm插件市场中搜索`PyLint`和`yapf-pycharm`两个插件，然后重启PyCharm。

![image-20210909154713560](/images/image-20210909154713560.png)

![image-20210909154858917](/images/image-20210909154858917.png)

### 配置PyLint

可以通过执行`pylint --generate-rcfile`生成配置文件模板（默认会在pylint可执行文件的所在的目录下），可以在模板文件上定制相关的统一的配置文件。配置完成后将配置文件路径填入PyCharm：

![image-20210909160427685](/images/image-20210909160427685.png)

下面是Google推荐的pylintrc配置：

```
# This Pylint rcfile contains a best-effort configuration to uphold the
# best-practices and style described in the Google Python style guide:
#   https://google.github.io/styleguide/pyguide.html
#
# Its canonical open-source location is:
#   https://google.github.io/styleguide/pylintrc

[MASTER]

# Files or directories to be skipped. They should be base names, not paths.
ignore=third_party

# Files or directories matching the regex patterns are skipped. The regex
# matches against base names, not paths.
ignore-patterns=

# Pickle collected data for later comparisons.
persistent=no

# List of plugins (as comma separated values of python modules names) to load,
# usually to register additional checkers.
load-plugins=

# Use multiple processes to speed up Pylint.
jobs=4

# Allow loading of arbitrary C extensions. Extensions are imported into the
# active Python interpreter and may run arbitrary code.
unsafe-load-any-extension=no


[MESSAGES CONTROL]

# Only show warnings with the listed confidence levels. Leave empty to show
# all. Valid levels: HIGH, INFERENCE, INFERENCE_FAILURE, UNDEFINED
confidence=

# Enable the message, report, category or checker with the given id(s). You can
# either give multiple identifier separated by comma (,) or put this option
# multiple time (only on the command line, not in the configuration file where
# it should appear only once). See also the "--disable" option for examples.
#enable=

# Disable the message, report, category or checker with the given id(s). You
# can either give multiple identifiers separated by comma (,) or put this
# option multiple times (only on the command line, not in the configuration
# file where it should appear only once).You can also use "--disable=all" to
# disable everything first and then reenable specific checks. For example, if
# you want to run only the similarities checker, you can use "--disable=all
# --enable=similarities". If you want to run only the classes checker, but have
# no Warning level messages displayed, use"--disable=all --enable=classes
# --disable=W"
disable=abstract-method,
        apply-builtin,
        arguments-differ,
        attribute-defined-outside-init,
        backtick,
        bad-option-value,
        basestring-builtin,
        buffer-builtin,
        c-extension-no-member,
        consider-using-enumerate,
        cmp-builtin,
        cmp-method,
        coerce-builtin,
        coerce-method,
        delslice-method,
        div-method,
        duplicate-code,
        eq-without-hash,
        execfile-builtin,
        file-builtin,
        filter-builtin-not-iterating,
        fixme,
        getslice-method,
        global-statement,
        hex-method,
        idiv-method,
        implicit-str-concat-in-sequence,
        import-error,
        import-self,
        import-star-module-level,
        inconsistent-return-statements,
        input-builtin,
        intern-builtin,
        invalid-str-codec,
        locally-disabled,
        long-builtin,
        long-suffix,
        map-builtin-not-iterating,
        misplaced-comparison-constant,
        missing-function-docstring,
        metaclass-assignment,
        next-method-called,
        next-method-defined,
        no-absolute-import,
        no-else-break,
        no-else-continue,
        no-else-raise,
        no-else-return,
        no-init,  # added
        no-member,
        no-name-in-module,
        no-self-use,
        nonzero-method,
        oct-method,
        old-division,
        old-ne-operator,
        old-octal-literal,
        old-raise-syntax,
        parameter-unpacking,
        print-statement,
        raising-string,
        range-builtin-not-iterating,
        raw_input-builtin,
        rdiv-method,
        reduce-builtin,
        relative-import,
        reload-builtin,
        round-builtin,
        setslice-method,
        signature-differs,
        standarderror-builtin,
        suppressed-message,
        sys-max-int,
        too-few-public-methods,
        too-many-ancestors,
        too-many-arguments,
        too-many-boolean-expressions,
        too-many-branches,
        too-many-instance-attributes,
        too-many-locals,
        too-many-nested-blocks,
        too-many-public-methods,
        too-many-return-statements,
        too-many-statements,
        trailing-newlines,
        unichr-builtin,
        unicode-builtin,
        unnecessary-pass,
        unpacking-in-except,
        useless-else-on-loop,
        useless-object-inheritance,
        useless-suppression,
        using-cmp-argument,
        wrong-import-order,
        xrange-builtin,
        zip-builtin-not-iterating,


[REPORTS]

# Set the output format. Available formats are text, parseable, colorized, msvs
# (visual studio) and html. You can also give a reporter class, eg
# mypackage.mymodule.MyReporterClass.
output-format=text

# Put messages in a separate file for each module / package specified on the
# command line instead of printing them on stdout. Reports (if any) will be
# written in a file name "pylint_global.[txt|html]". This option is deprecated
# and it will be removed in Pylint 2.0.
files-output=no

# Tells whether to display a full report or only the messages
reports=no

# Python expression which should return a note less than 10 (10 is the highest
# note). You have access to the variables errors warning, statement which
# respectively contain the number of errors / warnings messages and the total
# number of statements analyzed. This is used by the global evaluation report
# (RP0004).
evaluation=10.0 - ((float(5 * error + warning + refactor + convention) / statement) * 10)

# Template used to display messages. This is a python new-style format string
# used to format the message information. See doc for all details
#msg-template=


[BASIC]

# Good variable names which should always be accepted, separated by a comma
good-names=main,_

# Bad variable names which should always be refused, separated by a comma
bad-names=

# Colon-delimited sets of names that determine each other's naming style when
# the name regexes allow several styles.
name-group=

# Include a hint for the correct naming format with invalid-name
include-naming-hint=no

# List of decorators that produce properties, such as abc.abstractproperty. Add
# to this list to register other decorators that produce valid properties.
property-classes=abc.abstractproperty,cached_property.cached_property,cached_property.threaded_cached_property,cached_property.cached_property_with_ttl,cached_property.threaded_cached_property_with_ttl

# Regular expression matching correct function names
function-rgx=^(?:(?P<exempt>setUp|tearDown|setUpModule|tearDownModule)|(?P<camel_case>_?[A-Z][a-zA-Z0-9]*)|(?P<snake_case>_?[a-z][a-z0-9_]*))$

# Regular expression matching correct variable names
variable-rgx=^[a-z][a-z0-9_]*$

# Regular expression matching correct constant names
const-rgx=^(_?[A-Z][A-Z0-9_]*|__[a-z0-9_]+__|_?[a-z][a-z0-9_]*)$

# Regular expression matching correct attribute names
attr-rgx=^_{0,2}[a-z][a-z0-9_]*$

# Regular expression matching correct argument names
argument-rgx=^[a-z][a-z0-9_]*$

# Regular expression matching correct class attribute names
class-attribute-rgx=^(_?[A-Z][A-Z0-9_]*|__[a-z0-9_]+__|_?[a-z][a-z0-9_]*)$

# Regular expression matching correct inline iteration names
inlinevar-rgx=^[a-z][a-z0-9_]*$

# Regular expression matching correct class names
class-rgx=^_?[A-Z][a-zA-Z0-9]*$

# Regular expression matching correct module names
module-rgx=^(_?[a-z][a-z0-9_]*|__init__)$

# Regular expression matching correct method names
method-rgx=(?x)^(?:(?P<exempt>_[a-z0-9_]+__|runTest|setUp|tearDown|setUpTestCase|tearDownTestCase|setupSelf|tearDownClass|setUpClass|(test|assert)_*[A-Z0-9][a-zA-Z0-9_]*|next)|(?P<camel_case>_{0,2}[A-Z][a-zA-Z0-9_]*)|(?P<snake_case>_{0,2}[a-z][a-z0-9_]*))$

# Regular expression which should only match function or class names that do
# not require a docstring.
no-docstring-rgx=(__.*__|main|test.*|.*test|.*Test)$

# Minimum line length for functions/classes that require docstrings, shorter
# ones are exempt.
docstring-min-length=10


[TYPECHECK]

# List of decorators that produce context managers, such as
# contextlib.contextmanager. Add to this list to register other decorators that
# produce valid context managers.
contextmanager-decorators=contextlib.contextmanager,contextlib2.contextmanager

# Tells whether missing members accessed in mixin class should be ignored. A
# mixin class is detected if its name ends with "mixin" (case insensitive).
ignore-mixin-members=yes

# List of module names for which member attributes should not be checked
# (useful for modules/projects where namespaces are manipulated during runtime
# and thus existing member attributes cannot be deduced by static analysis. It
# supports qualified module names, as well as Unix pattern matching.
ignored-modules=

# List of class names for which member attributes should not be checked (useful
# for classes with dynamically set attributes). This supports the use of
# qualified names.
ignored-classes=optparse.Values,thread._local,_thread._local

# List of members which are set dynamically and missed by pylint inference
# system, and so shouldn't trigger E1101 when accessed. Python regular
# expressions are accepted.
generated-members=


[FORMAT]

# Maximum number of characters on a single line.
max-line-length=80

# TODO(https://github.com/PyCQA/pylint/issues/3352): Direct pylint to exempt
# lines made too long by directives to pytype.

# Regexp for a line that is allowed to be longer than the limit.
ignore-long-lines=(?x)(
  ^\s*(\#\ )?<?https?://\S+>?$|
  ^\s*(from\s+\S+\s+)?import\s+.+$)

# Allow the body of an if to be on the same line as the test if there is no
# else.
single-line-if-stmt=yes

# List of optional constructs for which whitespace checking is disabled. `dict-
# separator` is used to allow tabulation in dicts, etc.: {1  : 1,\n222: 2}.
# `trailing-comma` allows a space between comma and closing bracket: (a, ).
# `empty-line` allows space-only lines.
no-space-check=

# Maximum number of lines in a module
max-module-lines=99999

# String used as indentation unit.  The internal Google style guide mandates 2
# spaces.  Google's externaly-published style guide says 4, consistent with
# PEP 8.  Here, we use 2 spaces, for conformity with many open-sourced Google
# projects (like TensorFlow).
indent-string='  '

# Number of spaces of indent required inside a hanging  or continued line.
indent-after-paren=4

# Expected format of line ending, e.g. empty (any line ending), LF or CRLF.
expected-line-ending-format=


[MISCELLANEOUS]

# List of note tags to take in consideration, separated by a comma.
notes=TODO


[STRING]

# This flag controls whether inconsistent-quotes generates a warning when the
# character used as a quote delimiter is used inconsistently within a module.
check-quote-consistency=yes


[VARIABLES]

# Tells whether we should check for unused import in __init__ files.
init-import=no

# A regular expression matching the name of dummy variables (i.e. expectedly
# not used).
dummy-variables-rgx=^\*{0,2}(_$|unused_|dummy_)

# List of additional names supposed to be defined in builtins. Remember that
# you should avoid to define new builtins when possible.
additional-builtins=

# List of strings which can identify a callback function by name. A callback
# name must start or end with one of those strings.
callbacks=cb_,_cb

# List of qualified module names which can have objects that can redefine
# builtins.
redefining-builtins-modules=six,six.moves,past.builtins,future.builtins,functools


[LOGGING]

# Logging modules to check that the string format arguments are in logging
# function parameter format
logging-modules=logging,absl.logging,tensorflow.io.logging


[SIMILARITIES]

# Minimum lines number of a similarity.
min-similarity-lines=4

# Ignore comments when computing similarities.
ignore-comments=yes

# Ignore docstrings when computing similarities.
ignore-docstrings=yes

# Ignore imports when computing similarities.
ignore-imports=no


[SPELLING]

# Spelling dictionary name. Available dictionaries: none. To make it working
# install python-enchant package.
spelling-dict=

# List of comma separated words that should not be checked.
spelling-ignore-words=

# A path to a file that contains private dictionary; one word per line.
spelling-private-dict-file=

# Tells whether to store unknown words to indicated private dictionary in
# --spelling-private-dict-file option instead of raising a message.
spelling-store-unknown-words=no


[IMPORTS]

# Deprecated modules which should not be used, separated by a comma
deprecated-modules=regsub,
                   TERMIOS,
                   Bastion,
                   rexec,
                   sets

# Create a graph of every (i.e. internal and external) dependencies in the
# given file (report RP0402 must not be disabled)
import-graph=

# Create a graph of external dependencies in the given file (report RP0402 must
# not be disabled)
ext-import-graph=

# Create a graph of internal dependencies in the given file (report RP0402 must
# not be disabled)
int-import-graph=

# Force import order to recognize a module as part of the standard
# compatibility libraries.
known-standard-library=

# Force import order to recognize a module as part of a third party library.
known-third-party=enchant, absl

# Analyse import fallback blocks. This can be used to support both Python 2 and
# 3 compatible code, which means that the block might have code that exists
# only in one or another interpreter, leading to false positives when analysed.
analyse-fallback-blocks=no


[CLASSES]

# List of method names used to declare (i.e. assign) instance attributes.
defining-attr-methods=__init__,
                      __new__,
                      setUp

# List of member names, which should be excluded from the protected access
# warning.
exclude-protected=_asdict,
                  _fields,
                  _replace,
                  _source,
                  _make

# List of valid names for the first argument in a class method.
valid-classmethod-first-arg=cls,
                            class_

# List of valid names for the first argument in a metaclass class method.
valid-metaclass-classmethod-first-arg=mcs


[EXCEPTIONS]

# Exceptions that will emit a warning when being caught. Defaults to
# "Exception"
overgeneral-exceptions=StandardError,
                       Exception,
                       BaseException
```

### 配置YAPF

使用命令`yapf --style-help > yapf_style.cfg`生成YAPF的配置文件，将`yapf_style.cfg`放在工程目录下，或者与要格式化的文件在同一目录

如果想一劳永逸的话，可以将`yapf_style.cfg`改名为`style`，直接放入`$HOME/.config/yapf/`下，其中HOME目录在windows上需要自己设置添加进PATH，Linux和Mac os就是~，这时yapfArgs可以不写入配置。

如果要使用`Google-Python-Style-Guide`中的代码规范，可以在配置文件中加入下列语句：

```
# YAPF uses the Google Python style
based_on_style = google
indent_width: 4
```

### 使用YAPF插件

PyCharm中使用YAPF及PyLint工具还是比较方便的：

![image-20210909163242645](/images/image-20210909163242645.png)

如上图，我们可以在`Code > Reformat code (YAPF)`中格式化文件，也可以在编写时直接使用快捷键(`Meta+Alt+L`)。

### 使用PyLint插件

一般来讲，安装完之后PyCharm底部会出现如下窗口：

![image-20210909163656145](/images/image-20210909163656145.png)

在本窗口可以选择单文件扫描、模块扫描或工程扫描，扫描完成PyLint会有相应结果提示。
