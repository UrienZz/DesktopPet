# WindowPet macOS 重写设计文档

## 一、概述

本文档定义了 `WindowPet` 的 macOS 原生重写方案。新版本将采用 `SwiftUI + AppKit bridge` 的实现方式，聚焦于单宠物桌面悬浮、应用内 Trello 面板、菜单栏入口，以及保留旧项目中部分设置能力。

本次重写明确保留：

- 单宠物桌面悬浮
- 应用内 Trello 面板
- 菜单栏图标入口
- 设置窗口
- 内置宠物切换
- 姿势/动画预览
- 大小控制

本次重写明确不保留：

- 多宠物
- 自定义导入宠物
- 宠物商店
- 自动行走
- 随机行为
- 上次位置记忆

---

## 二、目标

- 构建一个仅支持 macOS 的原生桌宠应用。
- 正常运行时不展示标准应用窗口感知，仅保留菜单栏图标和桌面宠物。
- 每次启动时，宠物固定出现在当前主屏幕右侧中间，并处于右侧爬墙状态。
- 点击宠物后展开内嵌 Trello 面板，并支持首次在面板内直接登录 Trello。
- 点击面板外部区域后自动收起面板，宠物回到默认右侧中间爬墙状态。
- 正常运行时隐藏 Dock 图标；设置窗口打开时显示 Dock 图标。
- 保留旧项目中的部分设置能力：切换内置宠物、姿势预览、大小控制。

---

## 三、非目标

- 不支持 Windows。
- 不支持 Linux。
- 不继续使用 Tauri、React、Phaser 作为运行时框架。
- 不支持多宠物同时显示。
- 不支持自定义导入宠物。
- 不支持拖拽桌宠。
- 不支持自动行走、随机移动、重力掉落等复杂行为。
- 不保留旧项目中的 `My Pets / Pet Shop / Add Custom Pet` 信息结构。

---

## 四、产品形态

应用存在两种主要运行形态。

### 1. 常驻代理形态

特点：

- Dock 图标隐藏
- 菜单栏图标始终可见
- 桌面上显示一只透明悬浮宠物
- Trello 面板按需展开

这是用户的默认使用形态。

### 2. 设置窗口形态

特点：

- 打开设置窗口时，应用临时切换为正常前台应用
- Dock 图标显示
- 设置窗口拥有正常 macOS 窗口行为

关闭设置窗口后，应用恢复为常驻代理形态。

---

## 五、窗口设计

## 5.1 宠物窗口 `PetWindow`

用途：

- 显示桌面上的唯一宠物。

要求：

- 背景透明
- 无边框
- 无标题栏
- 不显示左上角红黄绿按钮
- 始终置顶
- 尽量不出现在 Mission Control、App Switcher、常规窗口循环中
- 非宠物区域完全鼠标穿透
- 仅宠物可见像素区域可点击

初始位置：

- 当前主屏幕右侧中间

初始状态：

- `climbRight`

---

## 5.2 Trello 面板窗口 `PanelWindow`

用途：

- 在应用内部展示 Trello 面板。

要求：

- 原生浮动窗口
- 可获得焦点
- 内部承载 `WKWebView`
- 加载写死的 Trello URL
- 支持首次在应用内登录 Trello
- 点击外部区域自动收起

收起后行为：

- 关闭 Trello 面板
- 宠物回到右侧中间
- 宠物状态恢复为 `climbRight`

---

## 5.3 设置窗口 `SettingsWindow`

用途：

- 提供轻量但完整的设置入口。

要求：

- 作为普通 macOS 窗口存在
- 打开时显示 Dock 图标
- 关闭后 Dock 图标重新隐藏

内容范围：

- 内置宠物切换
- 姿势/动画预览
- 大小控制
- 基础动作入口

---

## 六、菜单栏设计

应用需要始终在屏幕顶部菜单栏驻留一个图标。

菜单项至少包括：

- `打开设置`
- `打开 Trello`
- `重置宠物位置`
- `退出`

行为要求：

- `打开设置`：打开或聚焦设置窗口，并显示 Dock 图标
- `打开 Trello`：展开 Trello 面板，并让宠物进入悬停状态
- `重置宠物位置`：将宠物恢复到右侧中间，并切回 `climbRight`
- `退出`：完全退出应用

---

## 七、运行态规则

### 7.1 基本约束

- 桌面上始终只有 1 只宠物
- 不保存上次关闭前的位置
- 不支持自动行走
- 不支持随机行为

### 7.2 宠物状态

运行态仅保留一个精简状态机：

- `climbRight`
- `climbLeft`
- `hoverRight`
- `hoverLeft`
- `preview(状态名)`，仅用于设置窗口预览

### 7.3 状态规则

- 启动时默认进入 `climbRight`
- 鼠标按下并命中宠物可见像素区域时，进入拖拽
- 拖拽过程中，宠物跟随鼠标移动
- 松手后按如下优先级判定吸附或下落：
  1. 命中底边吸附区时，优先吸附到底边，进入站立状态
  2. 否则，命中左边吸附区时，吸附到左边，进入 `climbLeft`
  3. 否则，命中右边吸附区时，吸附到右边，进入 `climbRight`
  4. 否则，命中顶部区域时，不吸附，进入下落状态，落到底边后切为站立状态
  5. 其他中间区域松手时，也执行自然下落，到底边后切为站立状态
- 点击宠物时：
  - 宠物停留在当前高度
  - 切到悬停/站立状态
  - 展开 Trello 面板
- 点击宠物与 Trello 面板以外区域时：
  - 收起 Trello 面板
  - 宠物回到默认右侧中间位置
  - 状态恢复为 `climbRight`

### 7.4 左侧爬墙

素材目前只提供右侧爬墙姿势，因此左侧爬墙通过镜像右侧爬墙实现。

左爬墙主要用于：

- 设置窗口预览
- 后续可能的扩展逻辑

本次版本不实现宠物自动从右墙移动到左墙的行为。

### 7.5 底边与顶部规则

- 底边吸附优先级高于左右吸附
- 左下角和右下角附近松手时，按底边站立处理
- 顶部不支持吸附
- 从顶部松手时，一定进入下落状态
- 下落结束后统一以底边站立状态结束

---

## 八、透明窗口与像素级点击

透明宠物窗必须做到“只有角色可点击，其他区域完全无感”。

实现要求：

- 窗口尺寸尽量贴合宠物包围区域
- 点击命中基于角色图像 alpha 数据判断
- 仅非透明像素区域响应点击
- 透明区域必须返回不可点击，从而将鼠标事件穿透到底层桌面或其他应用

结论：

- 不能使用矩形命中框
- 必须做像素级命中检测

---

## 九、Trello 集成

Trello 面板直接通过 `WKWebView` 加载真实 Trello 页面。

要求：

- Trello URL 先写死在常量中
- 首次登录直接在应用内 WebView 完成
- 登录状态由 `WKWebView` 的 Cookie / Session 持久化
- 不重做 Trello 的任何 UI
- 尽可能完整保留 Trello 原始响应式和交互行为

---

## 十、设置窗口范围

设置窗口仅保留旧项目中与当前需求高度相关的能力。

## 10.1 当前宠物切换

- 显示当前选中的内置宠物名称
- 提供内置宠物列表切换
- 切换后同步更新：
  - 桌面宠物
  - 设置窗口预览

## 10.2 姿势/动画预览

- 在设置窗口中独立展示当前宠物的姿势预览
- 可切换该宠物支持的状态
- 可播放动态姿势
- 必须支持合成 `climbLeft` 预览

注意：

- 设置窗口内的预览独立于桌面真实宠物运行态
- 切换预览姿势不会直接影响桌面窗口，除非用户显式切换宠物或调节大小

## 10.3 大小控制

- 使用统一缩放滑杆
- 缩放调整后即时影响：
  - 桌面宠物
  - 设置窗口中的预览

## 10.4 基础动作

- 打开 Trello
- 重置宠物位置
- 退出应用

---

## 十一、素材与配置复用

新应用将复用旧 `WindowPet` 项目的内置宠物配置和媒体素材作为数据源。

主要来源：

- `/Users/jiing/Work/AIVibeConding/my/WindowPet/src/config/*.json`
- `/Users/jiing/Work/AIVibeConding/my/WindowPet/public/media/*`

实现原则：

- Swift 侧增加一层配置适配器
- 不直接复制旧项目运行态逻辑
- 旧 JSON 仅作为素材描述与状态定义来源

---

## 十二、数据模型

## 12.1 内置宠物目录 `PetCatalog`

职责：

- 从旧项目的 JSON 中加载所有内置宠物定义

包含内容：

- 宠物名称
- 图片路径
- 状态集合
- 帧尺寸信息
- 其他必要元数据

## 12.2 当前选中状态 `SelectedPetState`

职责：

- 保存当前选中的内置宠物
- 保存当前缩放比例

## 12.3 运行态模式 `RuntimePetMode`

职责：

- 描述当前桌面宠物处于哪种运行状态

包含：

- `climbRight`
- `climbLeft`
- `hoverRight`
- `hoverLeft`

---

## 十三、快捷键行为

- `Command+W`
  - 如果 Trello 面板已打开：关闭 Trello 面板，并恢复宠物默认右侧中间爬墙
  - 如果当前焦点在设置窗口：按普通 macOS 方式关闭设置窗口

- `Command+Q`
  - 完全退出应用

---

## 十四、可见性与系统行为

- 正常运行时隐藏 Dock 图标
- 仅设置窗口打开时显示 Dock 图标
- 菜单栏图标始终存在

这要求应用在运行中动态切换 activation policy，以便在“代理应用模式”和“普通前台应用模式”之间切换。

---

## 十五、推荐架构

## 15.1 AppKit 负责的内容

- 应用生命周期
- activation policy 切换
- 菜单栏图标
- 透明宠物窗口
- Trello 面板窗口
- 设置窗口控制器
- 外部点击监听
- Mission Control / App Switcher 行为控制
- 像素级命中检测桥接

## 15.2 SwiftUI 负责的内容

- 设置窗口界面
- Trello 面板内容容器
- 宠物切换界面
- 姿势预览界面
- 大小控制界面

## 15.3 桥接组件

- `WKWebView` 通过 `NSViewRepresentable` 嵌入
- 宠物渲染视图通过自定义 AppKit 视图或可桥接渲染层实现

---

## 十六、建议文件结构

- `DesktopPetApp.swift`
- `App/AppDelegate.swift`
- `App/AppCoordinator.swift`
- `Config/AppConstants.swift`
- `MenuBar/MenuBarController.swift`
- `Window/PetWindow.swift`
- `Window/PanelWindow.swift`
- `Window/SettingsWindowController.swift`
- `Pet/PetDefinition.swift`
- `Pet/PetCatalogLoader.swift`
- `Pet/PetRuntimeMode.swift`
- `Pet/PetRuntimeController.swift`
- `Pet/SpriteSheetAnimator.swift`
- `Pet/PetRenderView.swift`
- `Pet/AlphaHitTestView.swift`
- `Panel/TrelloWebView.swift`
- `Panel/TrelloPanelView.swift`
- `Input/OutsideClickMonitor.swift`
- `Settings/SettingsRootView.swift`
- `Settings/PetPickerView.swift`
- `Settings/PosePreviewView.swift`
- `Settings/SizeControlView.swift`
- `Settings/SettingsActionsView.swift`

---

## 十七、风险

### 1. Mission Control 隐藏能力是“尽量”而不是绝对

AppKit 可以降低宠物窗在常规窗口管理中的可见性，但不同 macOS 版本或系统行为下仍可能存在边界情况。

### 2. 像素级点击命中实现复杂

这是产品体验的关键，但相对矩形命中要复杂得多，需要谨慎处理性能和坐标映射。

### 3. Trello 登录和会话可能存在网页侧变更风险

Trello 登录流程、Cookie 策略、重定向行为后续可能变化，因此实现时要保证 WebView 容错性。

### 4. 旧 JSON 复用时需要做功能裁剪

旧项目中的状态很多，但新项目并不需要复刻全部行为，因此必须通过 Swift 适配层做规范化处理，而不是直接把旧引擎逻辑搬过来。

---

## 十八、验收标准

- 启动后仅显示一只宠物，位置位于当前主屏幕右侧中间，状态为右侧爬墙。
- 正常运行时不显示 Dock 图标。
- 菜单栏图标始终可见。
- 宠物窗口无标题栏、无红黄绿按钮、背景透明。
- 非角色像素区域点击完全穿透。
- 点击角色像素后打开 Trello 面板，并切换宠物到悬停/站立状态。
- 点击宠物与面板外部区域后，Trello 面板自动收起，宠物恢复右侧中间 `climbRight`。
- Trello 可在面板内部完成首次登录。
- 菜单栏可打开设置窗口。
- 设置窗口打开时 Dock 图标可见，关闭后 Dock 图标隐藏。
- 设置窗口支持切换内置宠物。
- 设置窗口支持姿势/动画预览。
- 设置窗口支持大小控制，并即时影响桌面宠物。
- `Command+W` 在 Trello 面板打开时关闭面板。
- `Command+Q` 完全退出应用。
