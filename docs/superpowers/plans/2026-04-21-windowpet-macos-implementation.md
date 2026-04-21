# WindowPet macOS 重写实现计划

> **给执行型代理：** 必须使用 `superpowers:subagent-driven-development`（如可用）或 `superpowers:executing-plans` 来执行本计划。所有步骤使用 checkbox 语法追踪。

**目标：** 构建一个 macOS 原生单宠物桌宠应用，具备透明宠物窗、菜单栏入口、内嵌 Trello 面板、拖拽吸附与顶部下落，以及支持内置宠物切换、姿势预览和大小控制的设置窗口。

**架构：** 采用 `SwiftUI + AppKit bridge`。AppKit 负责应用生命周期、activation policy、菜单栏、透明窗口、拖拽吸附、顶部下落、外部点击监听和像素级命中；SwiftUI 负责设置窗口和 Trello 容器界面；桥接组件负责 `WKWebView` 和宠物渲染视图。

**技术栈：** Swift、SwiftUI、AppKit、WebKit、XCTest、复用原 WindowPet 的 JSON 配置和媒体素材

---

## Chunk 1：工程骨架与素材路径接入

### 任务 1：创建 macOS 应用包骨架

**文件：**
- 新建：`Package.swift`
- 新建：`Sources/DesktopPetApp/DesktopPetApp.swift`
- 新建：`Sources/DesktopPetApp/App/AppDelegate.swift`
- 新建：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 测试：`Tests/DesktopPetAppTests/DesktopPetAppTests.swift`

- [ ] **步骤 1：创建 Swift Package 清单**

要求：

- 可执行 target：`DesktopPetApp`
- 测试 target：`DesktopPetAppTests`
- 平台限定为 `.macOS(.v13)` 或更高
- 能正常引用 `SwiftUI`、`AppKit`、`WebKit`

- [ ] **步骤 2：创建应用入口**

要求：

- 使用 `@main`
- 通过 `NSApplicationDelegateAdaptor` 接入 `AppDelegate`

- [ ] **步骤 3：创建基础 AppDelegate 和协调器**

要求：

- `AppCoordinator` 暴露启动方法
- 当前阶段只需能证明应用可启动，不要求完整功能

- [ ] **步骤 4：补一个最小 smoke test**

要求：

- 测试 target 能正常编译
- 至少验证一个基础常量或辅助方法

- [ ] **步骤 5：运行测试**

执行：

```bash
swift test
```

预期：

- 所有测试通过
- 包结构编译成功


### 任务 2：补充常量与原始资源路径定义

**文件：**
- 新建：`Sources/DesktopPetApp/Config/AppConstants.swift`
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 测试：`Tests/DesktopPetAppTests/AppConstantsTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 原始 WindowPet 配置目录存在
- 原始媒体目录存在
- Trello URL 常量非空

- [ ] **步骤 2：运行定向测试，确认失败**

执行：

```bash
swift test --filter AppConstantsTests
```

预期：

- 测试失败，因为常量与辅助方法尚未定义

- [ ] **步骤 3：实现常量定义**

至少包括：

- 原始 `src/config` 路径
- 原始 `public/media` 路径
- 写死的 Trello URL
- 默认缩放值
- 默认宠物位置相关常量

- [ ] **步骤 4：重新运行定向测试**

执行：

```bash
swift test --filter AppConstantsTests
```

预期：

- 测试通过

---

## Chunk 2：宠物定义与素材解析

### 任务 3：建立宠物 JSON 模型

**文件：**
- 新建：`Sources/DesktopPetApp/Pet/PetDefinition.swift`
- 测试：`Tests/DesktopPetAppTests/PetDefinitionDecodingTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 选择一份旧项目中的 JSON 样本
- 验证名称可解码
- 验证图片路径可解码
- 验证状态映射可解码
- 验证帧尺寸元数据可解码

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter PetDefinitionDecodingTests
```

预期：

- 测试失败，因为模型不存在

- [ ] **步骤 3：实现 Codable 模型**

需要支持：

- 宠物定义
- 状态定义
- 帧尺寸与附加元数据

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter PetDefinitionDecodingTests
```

预期：

- 测试通过


### 任务 4：实现内置宠物目录加载器

**文件：**
- 新建：`Sources/DesktopPetApp/Pet/PetCatalogLoader.swift`
- 修改：`Sources/DesktopPetApp/Pet/PetDefinition.swift`
- 测试：`Tests/DesktopPetAppTests/PetCatalogLoaderTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 能扫描旧项目 `config` 目录下的 `.json`
- 能加载至少一只宠物
- 加载结果顺序可预测
- 能找到指定样例宠物

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter PetCatalogLoaderTests
```

预期：

- 测试失败，因为加载器尚未实现

- [ ] **步骤 3：实现加载器**

要求：

- 枚举 `.json` 文件
- 执行解码
- 对损坏文件有清晰错误或跳过策略

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter PetCatalogLoaderTests
```

预期：

- 测试通过


### 任务 5：实现 spritesheet 帧解析逻辑

**文件：**
- 新建：`Sources/DesktopPetApp/Pet/SpriteSheetAnimator.swift`
- 修改：`Sources/DesktopPetApp/Pet/PetDefinition.swift`
- 测试：`Tests/DesktopPetAppTests/SpriteSheetAnimatorTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- `frameSize` 模式下的帧宽高解析正确
- `width/height/highestFrameMax/totalSpriteLine` 推导模式正确
- 状态能正确转换为帧序列

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter SpriteSheetAnimatorTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现帧解析逻辑**

需要支持：

- 直接 `frameSize`
- 推导 `frameWidth/frameHeight`
- `spriteLine + frameMax`
- `start + end`

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter SpriteSheetAnimatorTests
```

预期：

- 测试通过

---

## Chunk 3：运行态宠物状态与渲染

### 任务 6：建立运行态模式与当前选中状态控制器

**文件：**
- 新建：`Sources/DesktopPetApp/Pet/PetRuntimeMode.swift`
- 新建：`Sources/DesktopPetApp/Pet/PetRuntimeController.swift`
- 测试：`Tests/DesktopPetAppTests/PetRuntimeControllerTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 默认模式为 `climbRight`
- 重置后恢复默认模式和默认位置
- 切换宠物后更新当前宠物
- 修改缩放后更新运行态缩放值
- 支持拖拽后的目标落点计算

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter PetRuntimeControllerTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现控制器**

控制器需维护：

- 当前宠物
- 当前缩放
- 当前运行态模式
- 默认位置元数据
- 吸附区与下落判定

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter PetRuntimeControllerTests
```

预期：

- 测试通过


### 任务 7：实现宠物渲染视图

**文件：**
- 新建：`Sources/DesktopPetApp/Pet/PetRenderView.swift`
- 修改：`Sources/DesktopPetApp/Pet/SpriteSheetAnimator.swift`
- 测试：`Tests/DesktopPetAppTests/PetRenderViewTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 渲染视图可解析指定状态对应的帧序列
- `climbLeft` 可由 `climbRight` 镜像生成
- 不存在的预览状态有合理回退

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter PetRenderViewTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现渲染视图或渲染抽象**

要求：

- 支持动画帧推进
- 支持镜像显示
- 支持运行态与预览态

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter PetRenderViewTests
```

预期：

- 测试通过


### 任务 8：实现像素级 alpha 命中检测

**文件：**
- 新建：`Sources/DesktopPetApp/Pet/AlphaHitTestView.swift`
- 修改：`Sources/DesktopPetApp/Pet/PetRenderView.swift`
- 测试：`Tests/DesktopPetAppTests/AlphaHitTestViewTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 透明像素不可点击
- 非透明像素可点击
- 镜像后的点击坐标映射仍然正确

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter AlphaHitTestViewTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现 alpha 命中检测**

要求：

- 基于当前渲染帧图像数据判断点击是否命中

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter AlphaHitTestViewTests
```

预期：

- 测试通过


### 任务 9：实现拖拽、三边吸附与顶部下落规则

**文件：**
- 修改：`Sources/DesktopPetApp/Pet/PetRuntimeController.swift`
- 修改：`Sources/DesktopPetApp/Pet/PetRuntimeMode.swift`
- 修改：`Sources/DesktopPetApp/Window/PetWindow.swift`
- 测试：`Tests/DesktopPetAppTests/PetSnapBehaviorTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 松手命中底边吸附区时，进入底边站立
- 左下角和右下角区域松手时，底边优先于左右边
- 命中左边吸附区时，进入 `climbLeft`
- 命中右边吸附区时，进入 `climbRight`
- 顶部松手时进入下落态，落地后变成底边站立
- 普通中间区域松手时也自然下落到底边站立

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter PetSnapBehaviorTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现拖拽吸附与下落逻辑**

要求：

- 支持拖拽中的位置更新
- 支持松手后的吸附区优先级判定
- 顶部不吸附，只能下落
- 下落结束统一落到底边站立

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter PetSnapBehaviorTests
```

预期：

- 测试通过

---

## Chunk 4：菜单栏、窗口与 Dock 行为

### 任务 10：实现菜单栏控制器

**文件：**
- 新建：`Sources/DesktopPetApp/MenuBar/MenuBarController.swift`
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 测试：`Tests/DesktopPetAppTests/MenuBarControllerTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 菜单动作能调用协调器方法：
  - 打开设置
  - 打开 Trello
  - 重置宠物
  - 退出

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter MenuBarControllerTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现菜单栏控制器**

要求：

- 使用 `NSStatusItem`
- 将菜单动作路由到协调器

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter MenuBarControllerTests
```

预期：

- 测试通过


### 任务 11：实现透明宠物窗口

**文件：**
- 新建：`Sources/DesktopPetApp/Window/PetWindow.swift`
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 测试：`Tests/DesktopPetAppTests/PetWindowTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 无边框样式
- 背景透明
- 标题不可见
- 标准窗口按钮不可见或不可用

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter PetWindowTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现宠物窗口**

要求：

- 无边框或 panel-like 样式
- 背景透明
- 浮动层级
- 挂载宠物渲染内容视图

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter PetWindowTests
```

预期：

- 测试通过


### 任务 12：实现 Dock 显示/隐藏的 activation policy 切换

**文件：**
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 新建：`Sources/DesktopPetApp/Window/SettingsWindowController.swift`
- 测试：`Tests/DesktopPetAppTests/ActivationPolicyTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 正常运行进入 agent/accessory 风格
- 打开设置进入 regular activation policy
- 关闭设置后恢复 agent/accessory 风格

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter ActivationPolicyTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现切换逻辑**

协调器至少提供：

- `enterAgentMode()`
- `enterSettingsMode()`

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter ActivationPolicyTests
```

预期：

- 测试通过

---

## Chunk 5：Trello 面板与外部点击监听

### 任务 13：实现 Trello WebView 桥接

**文件：**
- 新建：`Sources/DesktopPetApp/Panel/TrelloWebView.swift`
- 新建：`Sources/DesktopPetApp/Panel/TrelloPanelView.swift`
- 测试：`Tests/DesktopPetAppTests/TrelloWebViewTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- WebView 会加载设定的 Trello URL
- 使用持久化的数据存储，而不是临时会话

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter TrelloWebViewTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现 WebView 桥接**

要求：

- 用 `NSViewRepresentable`
- 用持久化 `WKWebsiteDataStore`

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter TrelloWebViewTests
```

预期：

- 测试通过


### 任务 14：实现 Trello 面板窗口

**文件：**
- 新建：`Sources/DesktopPetApp/Window/PanelWindow.swift`
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 测试：`Tests/DesktopPetAppTests/PanelWindowTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 面板窗口可挂载 Trello 内容
- 面板可显示/隐藏
- 面板位置可根据宠物窗口推导

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter PanelWindowTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现面板窗口**

要求：

- 浮于普通窗口之上
- 可获得焦点
- 显示在宠物附近
- 关闭时不销毁不必要的共享状态

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter PanelWindowTests
```

预期：

- 测试通过


### 任务 15：实现点击外部自动收起的监听器

**文件：**
- 新建：`Sources/DesktopPetApp/Input/OutsideClickMonitor.swift`
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 测试：`Tests/DesktopPetAppTests/OutsideClickMonitorTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 点击宠物窗口内部不触发收起
- 点击 Trello 面板内部不触发收起
- 点击二者外部会触发收起回调

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter OutsideClickMonitorTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现监听器**

要求：

- 通过 local/global event monitor 路由到协调器

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter OutsideClickMonitorTests
```

预期：

- 测试通过

---

## Chunk 6：设置窗口界面

### 任务 16：实现宠物切换界面

**文件：**
- 新建：`Sources/DesktopPetApp/Settings/PetPickerView.swift`
- 新建：`Sources/DesktopPetApp/Settings/SettingsRootView.swift`
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 测试：`Tests/DesktopPetAppTests/PetPickerViewTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 能显示可选宠物列表
- 选择某只宠物后更新运行态控制器

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter PetPickerViewTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现宠物切换界面**

要求：

- 用 SwiftUI 的 `Picker`、`List` 或同类组件实现

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter PetPickerViewTests
```

预期：

- 测试通过


### 任务 17：实现姿势预览界面

**文件：**
- 新建：`Sources/DesktopPetApp/Settings/PosePreviewView.swift`
- 修改：`Sources/DesktopPetApp/Pet/PetRenderView.swift`
- 测试：`Tests/DesktopPetAppTests/PosePreviewViewTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 可列出当前宠物可预览的状态
- 切换状态后预览会更新
- 必须包含合成的 `climbLeft`

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter PosePreviewViewTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现姿势预览**

要求：

- 预览视图与桌面真实宠物运行态相互独立

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter PosePreviewViewTests
```

预期：

- 测试通过


### 任务 18：实现大小控制与设置动作区

**文件：**
- 新建：`Sources/DesktopPetApp/Settings/SizeControlView.swift`
- 新建：`Sources/DesktopPetApp/Settings/SettingsActionsView.swift`
- 修改：`Sources/DesktopPetApp/Settings/SettingsRootView.swift`
- 测试：`Tests/DesktopPetAppTests/SettingsRootViewTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 设置窗口中存在大小控制
- 调整滑杆后运行态缩放更新
- 动作按钮已接入：
  - 打开 Trello
  - 重置位置
  - 退出

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter SettingsRootViewTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现设置根视图组合**

组合内容：

- 宠物切换
- 姿势预览
- 大小控制
- 动作按钮

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter SettingsRootViewTests
```

预期：

- 测试通过

---

## Chunk 7：协调器总装配与快捷键行为

### 任务 19：完成端到端窗口协调流程

**文件：**
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 修改：`Sources/DesktopPetApp/Window/PetWindow.swift`
- 修改：`Sources/DesktopPetApp/Window/PanelWindow.swift`
- 修改：`Sources/DesktopPetApp/Window/SettingsWindowController.swift`
- 测试：`Tests/DesktopPetAppTests/AppCoordinatorFlowTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- 启动时创建默认宠物窗口并进入默认状态
- 点击宠物后进入悬停状态并打开 Trello 面板
- 点击外部后收起面板并重置宠物
- 打开设置时显示 Dock 图标，同时不破坏当前宠物运行态
- 拖拽松手后按优先级吸附或下落

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter AppCoordinatorFlowTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现协调器总装配**

连接内容：

- 菜单栏动作
- 宠物点击回调
- Trello 面板显示/隐藏
- 重置逻辑
- 设置窗口显示/关闭
- Dock 图标显隐切换

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter AppCoordinatorFlowTests
```

预期：

- 测试通过


### 任务 20：实现快捷键行为

**文件：**
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 修改：`Sources/DesktopPetApp/Window/PanelWindow.swift`
- 修改：`Sources/DesktopPetApp/Window/SettingsWindowController.swift`
- 测试：`Tests/DesktopPetAppTests/KeyboardShortcutTests.swift`

- [ ] **步骤 1：先写失败测试**

测试内容：

- `Command+W` 在 Trello 面板打开时可关闭面板
- `Command+Q` 可触发应用退出流程

- [ ] **步骤 2：运行定向测试**

执行：

```bash
swift test --filter KeyboardShortcutTests
```

预期：

- 测试失败

- [ ] **步骤 3：实现快捷键路由**

要求：

- 尽量使用 responder chain 或菜单命令机制，而不是手写非常规监听

- [ ] **步骤 4：重新运行测试**

执行：

```bash
swift test --filter KeyboardShortcutTests
```

预期：

- 测试通过

---

## Chunk 8：最终验证

### 任务 21：执行完整验证

**文件：**
- 修改：无
- 测试：`Tests/DesktopPetAppTests/*`

- [ ] **步骤 1：运行全部自动化测试**

执行：

```bash
swift test
```

预期：

- 所有测试通过

- [ ] **步骤 2：执行人工冒烟检查**

检查项：

- 启动应用
- 确认只有菜单栏图标和宠物可见
- 点击宠物打开 Trello
- 如未登录，则在 WebView 内登录 Trello
- 点击外部区域，确认面板自动收起
- 拖到左边松手，确认左爬墙
- 拖到右边松手，确认右爬墙
- 拖到底边松手，确认站立
- 拖到顶部松手，确认自动下落到底边站立
- 拖到普通中间区域松手，确认自然下落到底边站立
- 从菜单栏打开设置
- 确认 Dock 图标显示
- 切换宠物
- 预览姿势
- 调整大小
- 关闭设置，确认 Dock 图标隐藏

- [ ] **步骤 3：记录剩余问题**

如果仍有未验证项或系统限制，写成简短备注，方便后续继续收敛。

---

计划已保存到 `docs/superpowers/plans/2026-04-21-windowpet-macos-implementation.md`。可以开始执行。
