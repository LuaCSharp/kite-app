# 上应小风筝 App

这是一个由上海应用技术大学易班工作站主导开发、服务上海应用技术大学学生的应用。
我们致力于将其打造为校内最现代、最实用的 App。欢迎同学们提出好的点子、参与开发~

**主要功能**
- [ ] 课程表
- [ ] 消费记录
- [ ] 成绩查询
- [ ] 给分查询
- [ ] 评教
- [ ] 体温上报
- [ ] 所谓 “一网通办“ 的支持
- [ ] 第二课堂
- [ ] 校园通知
- [ ] 空教室查询
- [ ] 常用电话
- [ ] 风景墙
- [ ] 二手书中介

项目来源于我们做的 [上应小风筝](https://github.com/SIT-Yiban/kite-microapp) 小程序，由于 [一些原因](WHY_DO_WE_MIGRATE.md) ，我们被迫改为 App 方式提供服务。
在这个版本的开发中，我们参考了一些优秀的开源项目，如复旦大学 [旦夕App](https://github.com/DanXi-Dev/DanXi) ，在此表示感谢。

Flutter 框架支持编译到多种目标平台。当前我们工作的重点在 Android 和 iOS 平台。Web 平台因浏览器限制跨域 POST 请求、无法嵌入 Webview 而存在一些问题。

## 构建

除非遇到关键依赖库不兼容的情况，开发团队一般会保持版本最新。当前开发版本为：
- Flutter 2.8.1
- Dart 2.15.1

编译方法：
```bash
git clone https://github.com/SIT-kite/kite-app
cd ./kite-app

# 安装依赖
flutter pub get

# 生成json序列化与反序列化代码
flutter pub run build_runner build

# 生成 splash screen
flutter pub run flutter_native_splash:create

# 打包生成 apk
flutter build apk
# 使用 Web 方式运行
flutter run
```

## 联系我们

- 在本项目中提交 issue
- 在 QQ 群中联系管理员反馈。 小程序反馈群：943110696 2021级易班新生群：147239936 （限本校学生加入）
- 地址：奉贤校区大学生活动中心309室

## 参与贡献

在每年招新期间，你可以关注一下“上海应用技术大学易班”公众号，或有关QQ群了解招新信息加入校易班工作站（欢迎来技术部！）。

你也可以直接联系我们，联系方式见 “上方” 或对有关项目提交 issue、 pull request，留下你的痕迹。

## 有关项目

| 项目 | 说明 |
|-----|-----|
| [kite-server](https://github.com/SIT-Yiban/kite-server) | 后端 API 服务 |
| kite-agent | 后端数据抓取工具（在 App 场景下被废弃） |
| kite-string | 校园网爬虫工具 |

部分项目已在 Gitee 上镜像，访问速度会快一些。

## 开源协议

项目中的代码（程序源代码、配置文件等）采用 [GPL v3](LICENSE) 协议发布。注意，如果您修改并分发本项目，您应当同意，软件的“分发“或”发布“包括”为用户提供服务“。您修改并分发项目后，应当对用户和我们（即，上海应用技术大学校易班工作站）公开全部源代码。除此之外，您（非贡献者）也不能将本项目用于比赛、论文等活动。

项目名称、标语、标志性图片等素材，仅限上海应用技术大学校易班工作站及原作者使用，或经其书面同意后使用，不对外授权。

项目引用了 [旦夕](https://github.com/DanXi-Dev/DanXi) 的部分代码，具体文件见文件首部的版权声明。
