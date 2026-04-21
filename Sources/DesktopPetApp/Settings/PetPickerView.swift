import SwiftUI

struct PetPickerView: View {
    let pets: [PetDefinition]
    let selectedPetName: String
    let sourceTitle: String
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                SettingsInfoPill(label: "当前选择", value: selectedPetName)
                SettingsInfoPill(label: "来源", value: sourceTitle)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("宠物选择")
                    .font(.system(size: 13, weight: .semibold))
                Picker("当前宠物", selection: Binding(
                    get: { selectedPetName },
                    set: { onSelect($0) }
                )) {
                    ForEach(pets, id: \.name) { pet in
                        Text(pet.name).tag(pet.name)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text("切换后会立即同步到桌面上的当前宠物。")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}
