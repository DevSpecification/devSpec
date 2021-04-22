---
title: "Git工作流"
linkTitle: "Git工作流"
weight: 40
---


目前基于 `git` 协作工作流的模式非常多，对于初创团队可以借鉴 `gitflow` 构建协作方式。此外，通过统一的协作工作流程和开发工作流，
保证团队高效地协作开发，保持项目开发迭代周期井井有序。

团队开发与维护主要是针对项目去开发、迭代甚至是维护，使用分支能够有效地避免不同开发工作之间的相关干扰。

![gitflow](/images/gitflow.png)

## Git提交规范

当一个团队在协作开发时，针对 **git commit** 规范是十分必须的，每一次提交都务必带上说明信息，同时说明信息亦要有格式规范，
即团队要有良好的约定。目的是制定统一的标准，使得提交历史信息条理清晰，更是为了项目有条不絮地迭代以及提高开发者的效率。

> 统一团队 git commit 日志标准，便于后续代码 review ，版本发布以及日志自动化生成等等。

提交格式包含提交类别、范围模块、描述说明三部分：

```shell
git commit -m [type](:scope):[subject]
```

> 例子
> 
> ```shell
> git commit -m "feature:log:algo log by using websocket"
> ```

**提交类别**包括：

- `feature`: 新功能

- `fixed` : 修复bug

- `update` : 更新

- `docs` : 文档改变

- `style` : 代码格式改变

- `refactor` : 某个已有功能重构

- `perf` : 性能优化

- `test` : 增加测试

- `build` : 改变了build工具 如 grunt换成了 npm

- `revert` : 撤销上一次的 commit

- `chore` : 构建过程或辅助工具的变动

**范围模块**，应该使用一个词语涵盖此次提交的改动。

**描述说明**，应该简洁明了，同时更加能突出此次改动的内容即可。

## Git分支规范

* 长期存在分支或标签

- `master` | 主分支

  主分支属于线上部署的分支，是项目生产稳定运行的项目分支，该分支自能合并开发分支或热修复分支。

- `develop` | 开发分支

  开发分支与主分支必须是并行的，此分支基于运行于开发环境与测试环境。同时，从规范上面来说，尽量不要在开发分支上直接做开发，
  开发分支是由功能分支或修复分支合并叠成。

- `release`| 发行标签
  
  发行分支即是项目版本可以稳定发行的版本，可看作为一个版本迭代的分水岭，譬如`1.0.0`、`2.0.0`等。注意、此发行分支是基于主分支构建而来，
  主要用于记录版本的节点，必须基于 `master` 分支构建。

* 短期存在分支

- `feature` | 功能分支

  功能分支由需求确立而成，每新增一个需求或功能就必须建立一个功能分支，好处是各个功能独立开发不受影响，同时团队成员之间的实现协作隔离不容易产生冲突。

- `hotfix` | 热修复分支
  
  热修复分支（补丁分支）假设生产分支出现异常等 `bug` 危急的情况，需要建议一个修复分支，使得主分支合并进而解决 `bug`则需要创建热修复分支。
  > 注意:修复分支在主分支合并的同时必须同时与开发分支合并，发行版也要合并构建成小版本的发行版，测试通过后需要基于热修复分支打标签。
  

|分支名|	分支定位|	描述|	权限控制|
| --- | --- | --- | --- |
|master|	发布分支|	master应处于随时可发布的状态，用于对外发布正式版本。ps: 应配置此分支触发CI/CD，部署至生产环境。|	Maintainer可发起merge request|
|develop	|开发分支|	不可以在develop分支push代码，应新建feature/xxx进行需求开发。迭代功能开发完成后的代码都会merge到develop分支。|	Develper不可直接push，可发起merge request
|feature/xxx|	特性分支|	针对每一项需求，新建feature分支，如feature/user_login，用于开发用户登录功能。|	Develper可直接push|
|release|	提测分支|	由develop分支合入release分支。ps: 应配置此分支触发CI/CD，部署至测试环境。|	Maintainer可发起merge request|
|bug/xxx|	缺陷分支|	提测后发现的bug，应基于develop分支创建bug/xxx分支修复缺陷，修改完毕后应合入develop分支等待回归测试。	||
|hotfix/xxx|	热修复分支|	处理线上最新版本出现的bug|	Develper可直接push|
|fix/xxx|	旧版本修复分支|	处理线上旧版本的bug|	Develper可直接push|


## 提交习惯

* **高频率、细粒度地提交**

    必须把大功能的实现尽可能分解成相对独立的小模块，每个小模块需要完成测试后提交到代码库，再开始下一个模块的开发。
    这样做能保证每次提交的内容高度相关，方便定位错误、解决合并冲突。
    相比之下，如果每次提交的东西很多、改动很大、时间间隔很长，那么在代码合并过程中产生的冲突就很难解决。
    
> 约定: 如果代码有改动，一天至少提交一次。


* **提交之前需进行自测与单元测试**

    提交代码前需要针对改动的代码进行自测和单元测试，确保在测试环境能平稳正常运行，否则代码提交后将无法通过持续集成的测试。

* **分支合并**

    - **主分支合并**

        主分支合并必须经过测试组测试，验收通过后才能合并。一般而言、每次迭代上线前一起合并。

    - **开发分支合并**

        开发分支合并功能分支，尽量做到 **频繁合并**，也就是说尽量将功能需求分解成 `N` 个功能模块，
        每一个功能模块完成就提交代码合并到开发分支，这样可以减少分支合并而造成冲突。

## 代码提交的实例

当前存在版本(tag)  `1.0.0`，并规划推出新版本 `1.1.0`，那么应该基于 `1.0.0` 新建版本开发分支：


```shell
git checkout -b 1.1.0_develop
```

该开发版本有很多功能并且有多人参与。研发 a 参与视频模块开发，需要从 `1.1.0_develop` 创建一个功能分支，
参考的分支命名规范是 `{version}_{function}__{author}_{datetime}`：

```shell
git checkout -b 1.1.0_video_a_20200806
```
研发 b 参与朋友圈模块开发，需要从 `1.1.0_develop` 创建一个功能分支：

```shell
git checkout -b 1.1.0_friends_group_b_20200805
```
> 切记千万不要在开发分支直接提交代码 开发分支是合并分支

开发完毕合并功能分支，处于不断合并的过程

```shell
git merge 1.1.0_video_a_20200806
git merge 1.1.0_friends_group_b_20200805
```

自测完成后，没有问题那就将功能分支删除

```shell
git branch -d 1.1.0_video_a_20200806
git branch -d 1.1.0_friends_group_b_20200805
```

提测发现有缺陷，需要基于版本迭代分支创建缺陷修复分支

```shell
git checkout -b 1.1.0_fixed_video_upload_bug_alicfeng_20200808
```

修复完成再合并到迭代分支

```shell
git merge 1.1.0_fixed_video_upload_bug_alicfeng_20200808
```

测试通过后 通过约定的方式 `tag` 即为发布版本 发布 `1.1.0` 版本

```shell
git tag -a 1.1.0 -m "release:version:1.1.0" 
```

## 线上发现缺陷后的仓库操作与协作约定

1. 基于版本标签新建热修复分支

```shell
git checkout 1.1.0
git checkout -b hotfix_video_alicfeng_20200809
```

2. 开发分支合并热修复分支 

```shell
git checkout develop
git merge hotfix_video_alicfeng_20200809
```

3. 主分支合并开发分支

```shell
git checkout master
git merge develop
```

4. 基于主分支新建新的版本标签,务必在`git`上编写更新内容

```shell
git checkout hotfix_video_alicfeng_20200809
git tag -a 1.1.1 -m "fixed:video:upload"
```

测试通过后推送到代码仓库

```shell

```