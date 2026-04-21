# Pet Animation Toggle Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在顶部状态栏菜单中新增“暂停宠物动作/开启宠物动作”切换，并持久化该状态，重启后继续生效。

**Architecture:** 由 `AppCoordinator` 持有并恢复“动画暂停”状态，`MenuBarController` 负责显示动态菜单标题并回调切换动作，`PetRenderView` 负责真正暂停或恢复逐帧动画计时器。持久化继续复用 `AppPreferencesStore + UserDefaults`。

**Tech Stack:** SwiftUI、AppKit、Testing、UserDefaults

---

## Chunk 1: 状态与菜单接线

### Task 1: 为动画暂停状态补持久化入口

**Files:**
- Modify: `Sources/DesktopPetApp/Config/AppConstants.swift`
- Modify: `Sources/DesktopPetApp/App/AppPreferencesStore.swift`
- Test: `Tests/DesktopPetAppTests/AppPreferencesStoreTests.swift`

- [ ] **Step 1: 写失败测试**
- [ ] **Step 2: 运行 `swift test --filter AppPreferencesStoreTests` 验证失败**
- [ ] **Step 3: 最小实现默认键值与读写方法**
- [ ] **Step 4: 再次运行 `swift test --filter AppPreferencesStoreTests` 验证通过**

### Task 2: 为菜单项文案切换补可测试逻辑

**Files:**
- Modify: `Sources/DesktopPetApp/MenuBar/MenuBarController.swift`
- Test: `Tests/DesktopPetAppTests/MenuBarControllerTests.swift`

- [ ] **Step 1: 写失败测试**
- [ ] **Step 2: 运行 `swift test --filter MenuBarControllerTests` 验证失败**
- [ ] **Step 3: 最小实现动态标题与菜单项顺序**
- [ ] **Step 4: 再次运行 `swift test --filter MenuBarControllerTests` 验证通过**

## Chunk 2: 动画暂停行为

### Task 3: 为渲染视图补暂停/恢复能力

**Files:**
- Modify: `Sources/DesktopPetApp/Pet/PetRenderView.swift`
- Test: `Tests/DesktopPetAppTests/PetRenderViewAnimationTests.swift`

- [ ] **Step 1: 写失败测试**
- [ ] **Step 2: 运行 `swift test --filter PetRenderViewAnimationTests` 验证失败**
- [ ] **Step 3: 最小实现暂停时停表、恢复时续播、单帧状态不启表**
- [ ] **Step 4: 再次运行 `swift test --filter PetRenderViewAnimationTests` 验证通过**

### Task 4: 将暂停状态接入应用启动与菜单栏动作

**Files:**
- Modify: `Sources/DesktopPetApp/App/AppCoordinator.swift`
- Modify: `Sources/DesktopPetApp/MenuBar/MenuBarController.swift`
- Test: `Tests/DesktopPetAppTests/AppCoordinatorAnimationTests.swift`

- [ ] **Step 1: 写失败测试**
- [ ] **Step 2: 运行 `swift test --filter AppCoordinatorAnimationTests` 验证失败**
- [ ] **Step 3: 最小实现启动恢复、菜单切换、渲染同步**
- [ ] **Step 4: 再次运行 `swift test --filter AppCoordinatorAnimationTests` 验证通过**

## Chunk 3: 总体验证与提交

### Task 5: 全量回归

**Files:**
- Test: `Tests/DesktopPetAppTests/*`

- [ ] **Step 1: 运行 `swift test`**
- [ ] **Step 2: 检查输出为 0 失败**
- [ ] **Step 3: 提交，使用中文原子化 commit message**
