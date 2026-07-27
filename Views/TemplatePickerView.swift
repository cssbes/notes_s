import SwiftUI

struct TemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (NoteTemplate) -> Void
    @AppStorage("language") private var language = "en"

    var body: some View {
        NavigationStack {
            List(NoteTemplate.all) { template in
                Button {
                    onSelect(template)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(template.emoji).font(.system(size: 28))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(language == "ar" ? template.nameAr : template.name)
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.nText)
                            Text("\(template.tags.count) tags").font(.system(size: 11)).foregroundStyle(Color.nSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(Color.nTertiary)
                    }
                }
                .buttonStyle(.plain)
            }
            .listStyle(.insetGrouped)
            .background(Color.nBackground)
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}
