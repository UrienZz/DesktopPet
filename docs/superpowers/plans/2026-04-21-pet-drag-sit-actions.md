# Pet Drag And Sit Actions Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 接入“被拖拽”和“坐下”两个动作，并在缺少素材时回退到现有表现。

**Architecture:** 通过扩展 `PetRuntimeMode` 引入 `dragging` 和 `bottomIdle` 两个语义态，底边吸附与落地完成统一切到 `bottomIdle`，拖拽开始时由 `PetRenderView` 临时切到 `dragging`。状态名解析继续集中在 `PetDefinition`，其中 `bottomIdle` 映射到 `sit`，`dragging` 由拖拽链路在有素材时才启用，保证缺素材时维持当前行为。

**Tech Stack:** Swift、AppKit、Testing

---

### Task 1: 为底边与拖拽动作补失败测试

**Files:**
- Modify: `Tests/DesktopPetAppTests/PetSnapBehaviorTests.swift`
- Modify: `Tests/DesktopPetAppTests/PetDefinitionDecodingTests.swift`
- Create: `Tests/DesktopPetAppTests/PetRenderViewDragStateTests.swift`

- [ ] **Step 1: 写失败测试**
- [ ] **Step 2: 运行 `swift test --filter 'PetSnapBehaviorTests|PetDefinitionDecodingTests|PetRenderViewDragStateTests'` 验证失败**

### Task 2: 最小实现动作接线

**Files:**
- Modify: `Sources/DesktopPetApp/Pet/PetRuntimeMode.swift`
- Modify: `Sources/DesktopPetApp/Pet/PetDefinition.swift`
- Modify: `Sources/DesktopPetApp/Pet/PetRuntimeController.swift`
- Modify: `Sources/DesktopPetApp/Pet/PetRenderView.swift`

- [ ] **Step 1: 底边与落地切到 `bottomIdle`**
- [ ] **Step 2: 状态解析支持 `sit` 与 `drag`**
- [ ] **Step 3: 拖拽开始时在有 `drag` 素材时切到 `dragging`**
- [ ] **Step 4: 运行定向测试验证通过**

### Task 3: 全量回归

**Files:**
- Test: `Tests/DesktopPetAppTests/*`

- [ ] **Step 1: 运行 `swift test`**
- [ ] **Step 2: 检查输出为 0 失败**
