import SwiftUI

struct PetPickerView: View {
    let pets: [PetDefinition]
    let selectedPetName: String
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent("当前宠物") {
                Picker("当前宠物", selection: Binding(
                    get: { selectedPetName },
                    set: { onSelect($0) }
                )) {
                    ForEach(pets, id: \.name) { pet in
                        Text(pet.name).tag(pet.name)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 220)
            }

            Text("切换后会立即同步到桌面上的当前宠物。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
