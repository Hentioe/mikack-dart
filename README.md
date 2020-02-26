# mikack-dart

mikack 库的 Dart 绑定和包装。

## 基本介绍

本项目是 [Mikack](https://github.com/Hentioe/mikack) 生态的一部分，是官方实现的下游绑定，主要用于 **Flutter** 应用。

## 使用教程

本项目是一个规范的 Dart package，包含有一个大约 10MB 左右的 native 库。通常 BUG 由上游修复，本项目仅更新 API。

添加依赖：

```yaml
dependencies:
  mikack:
    git: git@github.com:Hentioe/mikack.git
```

### 基本 API

通常来讲，不推荐直接调用绑定函数，所以本库在原生 API 的基础上进行了一组封装，会有些许风格差异。

首先导入必要的包：

```dart
import 'package:mikack/mikack.dart';
// 通常你不需要主动创建任何基本模型，如有必要请导入以下文件
// import 'package:mikack/src/models.dart' as models;
```

#### 获取平台列表

```dart
var platformList = platforms();
```

#### 过滤平台列表

首先需要获取标签：

```dart
var tagList = tags();
// 假装用户选择了一些标签
var includeTags = // 需包含的标签
var excludeTags = // 需排除的标签
```

将标签列表作为参数

```dart
var filteredPlatforms = findPlatforms(includeTags, excludeTags);
```

如果不需要指定包含或排除的标签，传递空列表即可。

#### 获取漫画列表

```dart
var platform =  // 假装选中了一个平台
var page =      // 分配一个页码

var comics = platform.index(page);
```

#### 搜索漫画列表

```dart
var platform = // 假装选中了一个平台
var keywords = // 假装输入了一些关键字

var comics = platform.search(keywords);
```

#### 载入漫画章节

```dart
var platform =  // 假装选中了一个平台
var comic =     // 假装选中了一部漫画

platform.fetchChapters(comic);
comic.chapters; // 章节列表已经填充好了
```

#### 获取页面资源

```dart
var platform =  // 假装选中了一个平台
var chapter =   // 假装选中了一个漫画章节

// 创建页面迭代器
var pageIter = platform.createPageIter(chapter);  // 传递章节是为了填充更多的元数据
var address = pageIter.next();                    // 获取下一页的资源地址

var currentPage =   // 假装有个自增的当前页码
if (currentPage < chapter.pageCount) {
  pageIter.next();  // 翻页
} else {
  // 到底啦
}
```

#### 下载页面资源

大多平台对图片资源进行了一些基本安全措施，例如通过 `Referer` 头的防盗链。客户端开发者不需要解决资源的下载问题，因为库帮你做了。

获取 HTTP headers 用于下载图片：

```dart
var chapter = // 假装选中了一个漫画章节

// 获取下载该章节必要的 HTTP 头数据（Map 结构）
var headers = chapter.pageHeaders;

// 将 headers 附加到链接下载中
// 自行发挥，略
```

## 存在的问题

- Dart VM 的 TLS 查找存在问题

  暂时无法解决，需要绕 VM 环境。所以无论你将本库用于服务端程序还是 Flutter 应用开发，都建议进行 native 编译。
