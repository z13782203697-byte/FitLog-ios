# FitLog iOS

原生 SwiftUI 健身记录应用。

功能：
- 月历布局
- 点击日期查看历史训练
- 每条记录显示距当前过去的天 / 小时 / 分钟
- 记录训练项目、重量、组数、次数和备注
- 快捷项目：胸、背、腿、肩、二头、三头、跑步、卧推、深蹲、硬拉
- SwiftData 本地保存
- 不依赖第三方服务

## 开发环境
- iOS 17+
- SwiftUI
- SwiftData
- Xcode 15+
- 使用 XcodeGen 生成工程

GitHub Actions 会在 macOS Runner 上生成 Xcode 工程并编译 iOS Simulator 版本，用来验证源码可以通过编译。

> 真机安装 IPA 需要 Apple Developer 证书与签名配置。
