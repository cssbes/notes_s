import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var isActive: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .black, width: 2)
        canvas.delegate = context.coordinator
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
        uiView.isUserInteractionEnabled = isActive
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvasView
        init(_ parent: DrawingCanvasView) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}

struct DrawingCanvasViewWrapper: View {
    @State private var drawing = PKDrawing()
    @State private var showDrawing = false
    var onSave: ((Data) -> Void)?

    var body: some View {
        if showDrawing {
            VStack(spacing: 0) {
                HStack {
                    Button("Done") {
                        onSave?(drawing.dataRepresentation())
                        showDrawing = false
                    }
                    .fontWeight(.semibold).foregroundStyle(Color.nAccent)
                    Spacer()
                    Button("Clear") { drawing = PKDrawing() }
                        .foregroundStyle(.red)
                }
                .padding(.horizontal).padding(.vertical, 8)
                .background(Color.nSurface)

                DrawingCanvasView(drawing: $drawing, isActive: true)
                    .frame(minHeight: 300)
                    .background(Color.nBackground)
            }
            .cornerRadius(12)
        } else {
            Button {
                showDrawing = true
            } label: {
                HStack {
                    Image(systemName: "pencil.tip").foregroundStyle(Color.nAccent)
                    Text("Add Drawing").foregroundStyle(Color.nAccent)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.nSurface)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
    }
}
