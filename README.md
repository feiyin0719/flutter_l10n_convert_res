# flutter_l10n_convert_res

A new Flutter package project.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.io/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

一个flutter国际化工具，可以从安卓的strings.xml生成flutter的arb格式，配合https://github.com/long1eu/flutter_i18n  可以方便实现国际化

## 使用方法
添加依赖
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_l10n_convert_res:
    git:
      url:  https://github.com/feiyin0719/flutter_l10n_convert_res.git
```
`
flutter pub pub run flutter_l10n_convert_res:main -s assets/res -o assets/arbs -p strings
`
其中-s为安卓xml文件目录  即values-* 所在的目录
-o 为arbs文件输出目录 -p 为输出文件前缀 默认为strings
