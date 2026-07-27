import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding(16)
            .background(Color.nSurface)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }

    func glassBackground() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(16)
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct CornerRadiusShape: Shape {
    var radius: CGFloat
    var topLeft: Bool = true
    var topRight: Bool = true
    var bottomLeft: Bool = true
    var bottomRight: Bool = true

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tl = topLeft ? radius : 0
        let tr = topRight ? radius : 0
        let bl = bottomLeft ? radius : 0
        let br = bottomRight ? radius : 0
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        return path
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, topLeft: Bool = true, topRight: Bool = true, bottomLeft: Bool = true, bottomRight: Bool = true) -> some View {
        clipShape(CornerRadiusShape(radius: radius, topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight))
    }
}
