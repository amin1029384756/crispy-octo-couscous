import UIKit

class DashedLine: UIView {
    let color: UIColor
    let distance: NSNumber
    let width: CGFloat

    init(width: CGFloat, distance: NSNumber, color: UIColor) {
        self.width = width
        self.color = color
        self.distance = distance

        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [distance, distance]
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: width, y: 0)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
}
