# 插件化网页面板 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将当前写死的 Trello 面板改造成可持久化配置、可排序、可切换的插件化网页面板，并在空列表或全禁用时展示空状态。

**Architecture:** 新增 `PluginConfiguration + PluginStore` 作为插件数据层，`AppCoordinator` 改为持有插件列表与当前选中插件，并驱动设置页和面板页的统一状态。面板视图从固定 Trello 页面重构为通用插件容器，默认收起左侧插件列表，右侧用统一 `WKWebView` 加载当前插件网址。

**Tech Stack:** SwiftUI、AppKit、WebKit、UserDefaults、Testing

---

## Chunk 1: 插件数据层与持久化

### Task 1: 为插件模型和首次启动默认数据补失败测试

**Files:**
- Create: `Tests/DesktopPetAppTests/PluginStoreTests.swift`
- Modify: `Tests/DesktopPetAppTests/AppConstantsTests.swift`

- [ ] **Step 1: 写失败测试**
  断言首次启动会注入默认 Trello 插件；删除到空列表后不会自动补回；全禁用时读取结果仍为空可展示集合。
- [ ] **Step 2: 运行定向测试验证失败**
  Run: `swift test --filter 'PluginStoreTests|AppConstantsTests'`
  Expected: FAIL，缺少 `PluginConfiguration/PluginStore` 与插件默认常量。

### Task 2: 最小实现插件模型与持久化

**Files:**
- Create: `Sources/DesktopPetApp/Plugin/PluginConfiguration.swift`
- Create: `Sources/DesktopPetApp/Plugin/PluginStore.swift`
- Modify: `Sources/DesktopPetApp/Config/AppConstants.swift`
- Modify: `Sources/DesktopPetApp/App/AppPreferencesStore.swift`

- [ ] **Step 1: 创建插件模型**
  定义 `id/name/url/iconName/isEnabled/sortOrder`，支持 `Codable/Equatable/Sendable`。
- [ ] **Step 2: 实现 `PluginStore`**
  用 `UserDefaults` 持久化 JSON 数组，首次启动自动注入默认 Trello 插件。
- [ ] **Step 3: 加入空列表与全禁用辅助接口**
  提供“可展示插件列表”“默认插件注入”“按排序读取”等方法。
- [ ] **Step 4: 回跑定向测试**
  Run: `swift test --filter 'PluginStoreTests|AppConstantsTests'`
  Expected: PASS

## Chunk 2: 设置页从 Trello 改为插件

### Task 3: 为设置导航和插件页状态补失败测试

**Files:**
- Modify: `Tests/DesktopPetAppTests/SettingsNavigationTests.swift`
- Create: `Tests/DesktopPetAppTests/PluginSettingsViewModelTests.swift`

- [ ] **Step 1: 写失败测试**
  断言侧边栏标题从 `Trello` 改成 `插件`；插件列表支持新增、删除、选中、拖拽重排。
- [ ] **Step 2: 运行定向测试验证失败**
  Run: `swift test --filter 'SettingsNavigationTests|PluginSettingsViewModelTests'`
  Expected: FAIL，缺少插件设置状态与新导航项。

### Task 4: 最小实现设置页插件管理

**Files:**
- Modify: `Sources/DesktopPetApp/Settings/SettingsPane.swift`
- Modify: `Sources/DesktopPetApp/Settings/SettingsRootView.swift`
- Create: `Sources/DesktopPetApp/Settings/PluginSettingsDetailView.swift`
- Create: `Sources/DesktopPetApp/Settings/PluginListView.swift`
- Create: `Sources/DesktopPetApp/Settings/PluginEditorView.swift`
- Modify: `Sources/DesktopPetApp/App/AppCoordinator.swift`

- [ ] **Step 1: 将 `Trello` 导航替换为 `插件`**
- [ ] **Step 2: 在 `AppCoordinator` 中接入插件列表状态和 CRUD 接口**
- [ ] **Step 3: 实现设置页左侧插件列表**
  每行展示三横杠拖拽把手、名称和启用状态；支持拖拽排序。
- [ ] **Step 4: 实现右侧插件编辑表单**
  支持名称、地址、图标、启用开关、保存和删除。
- [ ] **Step 5: 回跑定向测试**
  Run: `swift test --filter 'SettingsNavigationTests|PluginSettingsViewModelTests'`
  Expected: PASS

## Chunk 3: 通用插件面板替换 Trello 面板

### Task 5: 为默认插件选择与空状态补失败测试

**Files:**
- Create: `Tests/DesktopPetAppTests/PluginPanelSelectionTests.swift`
- Modify: `Tests/DesktopPetAppTests/MenuBarControllerTests.swift`
- Modify: `Tests/DesktopPetAppTests/PanelWindowCloseTests.swift`
- Modify: `Tests/DesktopPetAppTests/AppCoordinatorAnimationTests.swift`

- [ ] **Step 1: 写失败测试**
  断言面板默认展示排序第一且启用的插件；空列表和全禁用时展示空状态；菜单栏文案改为“打开插件面板”。
- [ ] **Step 2: 运行定向测试验证失败**
  Run: `swift test --filter 'PluginPanelSelectionTests|MenuBarControllerTests|PanelWindowCloseTests|AppCoordinatorAnimationTests'`
  Expected: FAIL，现有实现仍写死 Trello。

### Task 6: 最小实现通用插件面板和通用 WebView

**Files:**
- Create: `Sources/DesktopPetApp/Panel/PluginPanelView.swift`
- Create: `Sources/DesktopPetApp/Panel/PluginWebView.swift`
- Create: `Sources/DesktopPetApp/Panel/PluginEmptyStateView.swift`
- Modify: `Sources/DesktopPetApp/Panel/TrelloPanelView.swift`
- Modify: `Sources/DesktopPetApp/Panel/TrelloWebView.swift`
- Modify: `Sources/DesktopPetApp/Window/PanelWindow.swift`
- Modify: `Sources/DesktopPetApp/MenuBar/MenuBarController.swift`
- Modify: `Sources/DesktopPetApp/App/AppCoordinator.swift`

- [ ] **Step 1: 抽出通用 `WKWebView` 容器**
  通过插件 URL 加载内容，继续使用默认数据存储复用登录态。
- [ ] **Step 2: 实现插件面板布局**
  默认收起左侧列表，仅显示展开按钮；展开后左侧显示插件列表，右侧显示对应网页。
- [ ] **Step 3: 实现空状态**
  右侧展示空图标和文案 `空空如也`。
- [ ] **Step 4: 改造 `PanelWindow` 和菜单栏入口**
  不再写死 Trello 标题与文案，统一改为插件面板语义。
- [ ] **Step 5: 在 `AppCoordinator` 中接通面板默认选中、列表切换与关闭恢复**
- [ ] **Step 6: 回跑定向测试**
  Run: `swift test --filter 'PluginPanelSelectionTests|MenuBarControllerTests|PanelWindowCloseTests|AppCoordinatorAnimationTests'`
  Expected: PASS

## Chunk 4: 全量验证

### Task 7: 全量回归

**Files:**
- Test: `Tests/DesktopPetAppTests/*`

- [ ] **Step 1: 运行全量测试**
  Run: `swift test`
- [ ] **Step 2: 检查输出**
  Expected: 0 failures
- [ ] **Step 3: 手动验证要点**
  1. 设置页能新增、编辑、删除、拖拽排序插件
  2. 点击宠物后默认显示排序第一且启用的插件
  3. 左侧列表默认收起，能手动展开/收起并切换插件
  4. 空列表与全禁用时显示 `空空如也`
