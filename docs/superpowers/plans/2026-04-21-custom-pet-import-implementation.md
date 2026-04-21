# 自定义导入宠物实现计划

> **给执行型代理：** 必须使用 `superpowers:subagent-driven-development`（如可用）或 `superpowers:executing-plans` 来执行本计划。所有步骤使用 checkbox 语法追踪。

**目标：** 支持从 zip 导入自定义宠物包、删除导入宠物，并在删除当前使用的导入宠物时回退到默认内置宠物。

**架构：** 采用“应用托管导入目录”的方式。文件系统层负责解压、校验和删除；目录加载层统一聚合内置与导入宠物；协调器负责导入成功后的刷新与删除当前导入宠物时的回退；设置页负责入口、状态显示与删除按钮。

**技术栈：** Swift、SwiftUI、AppKit、Foundation、Process、Testing

---

## Chunk 1：文件系统与模型扩展

### 任务 1：扩展宠物模型支持来源与资源根目录

**文件：**
- 修改：`Sources/DesktopPetApp/Pet/PetDefinition.swift`
- 测试：`Tests/DesktopPetAppTests/PetDefinitionDecodingTests.swift`

- [ ] 写失败测试，覆盖运行时扩展字段不会破坏现有 JSON 解码。
- [ ] 跑 `swift test --filter PetDefinitionDecodingTests`，确认失败。
- [ ] 实现最小改动：为 `PetDefinition` 增加来源、可删除性和资源目录信息，保持 `Codable` 兼容。
- [ ] 重新运行定向测试，确认通过。

### 任务 2：实现导入宠物存储层

**文件：**
- 新建：`Sources/DesktopPetApp/Pet/ImportedPetStore.swift`
- 修改：`Sources/DesktopPetApp/Config/AppConstants.swift`
- 测试：`Tests/DesktopPetAppTests/ImportedPetStoreTests.swift`

- [ ] 写失败测试，覆盖：
  - 合法 zip 可导入
  - 缺少 png 时导入失败
  - 导入后能列出导入宠物
  - 删除后目录被移除
- [ ] 跑 `swift test --filter ImportedPetStoreTests`，确认失败。
- [ ] 实现导入目录常量、临时解压、zip 校验、正式写入和删除逻辑。
- [ ] 重新运行定向测试，确认通过。

## Chunk 2：目录加载与协调器接入

### 任务 3：扩展宠物目录加载器聚合内置与导入宠物

**文件：**
- 修改：`Sources/DesktopPetApp/Pet/PetCatalogLoader.swift`
- 测试：`Tests/DesktopPetAppTests/PetCatalogLoaderTests.swift`

- [ ] 写失败测试，覆盖内置宠物与导入宠物可同时被加载。
- [ ] 跑 `swift test --filter PetCatalogLoaderTests`，确认失败。
- [ ] 实现 loader 聚合两类来源，并正确设置资源根目录与来源标识。
- [ ] 重新运行定向测试，确认通过。

### 任务 4：在协调器中接入导入、删除和回退默认宠物

**文件：**
- 修改：`Sources/DesktopPetApp/App/AppCoordinator.swift`
- 修改：`Sources/DesktopPetApp/App/AppPreferencesStore.swift`
- 测试：`Tests/DesktopPetAppTests/AppCoordinatorPetImportTests.swift`

- [ ] 写失败测试，覆盖：
  - 删除当前导入宠物时回退默认内置宠物
  - 删除非当前导入宠物时只刷新列表
  - 导入成功后宠物列表刷新
- [ ] 跑 `swift test --filter AppCoordinatorPetImportTests`，确认失败。
- [ ] 实现协调器刷新宠物目录、导入 zip、删除当前导入宠物和回退默认内置宠物逻辑。
- [ ] 重新运行定向测试，确认通过。

## Chunk 3：设置页入口与提示

### 任务 5：扩展“桌宠”设置页支持导入与删除

**文件：**
- 修改：`Sources/DesktopPetApp/Settings/SettingsRootView.swift`
- 修改：`Sources/DesktopPetApp/Settings/PetPickerView.swift`
- 新建：`Sources/DesktopPetApp/Settings/PetImportStatus.swift`（如需要）
- 测试：`Tests/DesktopPetAppTests/SettingsPetManagementTests.swift`

- [ ] 写失败测试，覆盖导入宠物按钮与删除导入宠物按钮的展示规则。
- [ ] 跑 `swift test --filter SettingsPetManagementTests`，确认失败。
- [ ] 在桌宠页摘要区接入“导入宠物”和条件展示的“删除该宠物”按钮。
- [ ] 在宠物选择区展示来源标签。
- [ ] 接入成功/失败提示。
- [ ] 重新运行定向测试，确认通过。

## Chunk 4：全量回归

### 任务 6：执行回归并整理提交

**文件：**
- 修改：相关实现与测试文件

- [ ] 运行 `swift test`
- [ ] 手动检查设置页导入、删除、切换当前导入宠物的完整路径
- [ ] 使用中文 commit message 原子提交

