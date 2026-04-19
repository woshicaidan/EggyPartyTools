# EggyPartyTools

iOS 权限研究工具 | 蛋仔派对修改登录动画 / 图标替换基于 TrollStore + KFD 内核提权实现

---

## 关于项目

本项目为 iOS 权限体系研究 Demo，核心验证 **com.apple.private.security.no-sandbox权限** 与 **KFD 内核提权** 的实际应用。附带实现蛋仔派对（iOS）资源修改功能：自定义登录动画、替换应用图标

---

## 支持环境

- iOS 14.0 ~ 16.6.1 (arm64/arm64e)
- iOS 17.0.0 (arm64/arm64e)
- vphone-cli (iOS 26.0+)

---

## 功能列表

- 一键替换蛋仔派对登录动画(不支持国际服)
- 自定义替换 App 图标资源
- 研究级：TrollStore 无沙盒能力验证
- 研究级：KFD 提权 + 文件系统操作

---

## 使用说明

1. 通过 TrollStore 签名安装本应用 
4. 选择对应功能，按照提示导入资源文件
5. 重启游戏生效

---

## How to build

- 使用 Xcode 14+ 打开 `party.xcodeproj`
- 编译时使用默认 `entitlements.plist`
- build后使用 `party.entitlements` 进行签名
- 使用Trollstore安装

---

## 核心依赖 & 参考项目

本项目基于以下开源项目研究整合：

- [TrollStore](https://github.com/opa334/TrollStore) - opa334
- [KFD](https://github.com/felix-pb/KFD) - felix-pb
- [AuxiliaryExecute](https://github.com/Lakr233/AuxiliaryExecute) - Lakr233
- [TrollFools](https://github.com/Lessica/TrollFools) - Lessica
- [SuperIcon](https://github.com/huami1314/SuperIcons) - huami1314

---

## Entitlements 说明

| 文件 | 用途 |
|------|------|
| `entitlements.plist` | Xcode 编译专用 |
| `party.entitlements` | TrollStore 安装专用 |

---

## 免责声明

- 本项目仅用于 iOS 安全研究与个人学习
- 禁止用于商业、非法、侵权行为
- 蛋仔派对(EggyParty)相关版权归网易游戏所有

---

## License

MIT License
