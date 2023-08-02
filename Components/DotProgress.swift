import SnapKit
import UIKit

class DotProgress: UIView {
    let totalDots: Int
    var currentDot = 0

    init(totalDots: Int) {
        self.totalDots = totalDots

        super.init(frame: .zero)

        var previousView: UIView?

        for _ in 0..<totalDots {
            let dotView = UIView()
            dotView.layer.cornerRadius = 3.5
            dotView.layer.masksToBounds = true
            dotView.backgroundColor = UIColor(hex: 0xE5E5E5)!
            addWithConstraints(view: dotView) {
                $0.width.equalTo(7)
                $0.height.equalTo(7)
                $0.centerY.equalToSuperview()
                if let previousView = previousView {
                    $0.leading.equalTo(previousView.snp.trailing).offset(10)
                } else {
                    $0.leading.equalToSuperview()
                }
            }
            previousView = dotView
        }

        previousView?.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(7)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(index: Int) {
        if index > 0 {
            for i in 0..<index {
                subviews[i].backgroundColor = UIColor(hex: 0x2A7672)!
            }
        }
        subviews[index].backgroundColor = UIColor(hex: 0x888888)!
        if index >= totalDots {
            for i in index+1..<totalDots {
                subviews[i].backgroundColor = UIColor(hex: 0xE5E5E5)!
            }
        }
    }
}
