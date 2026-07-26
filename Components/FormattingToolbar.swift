import SwiftUI

struct FormattingToolbar: View {
    var onBold: (() -> Void)?
    var onItalic: (() -> Void)?
    var onUnderline: (() -> Void)?
    var onHeading: ((Int) -> Void)?
    var onBulletList: (() -> Void)?
    var onNumberedList: (() -> Void)?
    var onChecklist: (() -> Void)?
    var onQuote: (() -> Void)?
    var onCode: (() -> Void)?
    var onUndo: (() -> Void)?
    var onRedo: (() -> Void)?
    var canUndo: Bool
    var canRedo: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                toolbarButton("bold", action: onBold)
                toolbarButton("italic", action: onItalic)
                toolbarButton("underline", action: onUnderline)

                Divider()
                    .frame(height: 20)

                toolbarButton("textformat.size.larger", action: { onHeading?(1) })
                toolbarButton("textformat.size", action: { onHeading?(2) })
                toolbarButton("textformat.size.smaller", action: { onHeading?(3) })

                Divider()
                    .frame(height: 20)

                toolbarButton("list.bullet", action: onBulletList)
                toolbarButton("list.number", action: onNumberedList)
                toolbarButton("checklist", action: onChecklist)

                Divider()
                    .frame(height: 20)

                toolbarButton("quote.bubble", action: onQuote)
                toolbarButton("chevron.left.forwardslash.chevron.right", action: onCode)

                Divider()
                    .frame(height: 20)

                toolbarButton("arrow.uturn.backward", action: onUndo)
                    .opacity(canUndo ? 1 : 0.3)
                    .disabled(!canUndo)
                toolbarButton("arrow.uturn.forward", action: onRedo)
                    .opacity(canRedo ? 1 : 0.3)
                    .disabled(!canRedo)
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 44)
        .background(.ultraThinMaterial)
    }

    private func toolbarButton(_ icon: String, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
