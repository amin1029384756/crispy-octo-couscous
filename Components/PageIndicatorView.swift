import UIKit

protocol PageIndicatorViewDelegate: AnyObject {
    func pageSelected(idx: Int)
}

class PageIndicatorView: UIView {
    weak var delegate: PageIndicatorViewDelegate?

    init(delegate: PageIndicatorViewDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)

        snp.makeConstraints {
            $0.height.equalTo(11)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func clearOldSubviews() {
        let oldSubviews = subviews
        oldSubviews.forEach {
            $0.removeFromSuperview()
        }
    }

    func set(page: Int, pages: Int) {
        clearOldSubviews()

        if pages <= 0 {
            return
        }

        var previousPageView: UIView? = nil
        for i in 0..<pages {
            let pageView = UIView(frame: .zero)
            pageView.backgroundColor = .clear
            pageView.tag = i
            pageView.isUserInteractionEnabled = true
            let tapDetector = UITapGestureRecognizer(target: self, action: #selector(pageSelected(_:)))
            pageView.addGestureRecognizer(tapDetector)
            addWithConstraints(view: pageView) {
                $0.centerY.equalToSuperview()
                if let previousPageView = previousPageView {
                    $0.leading.equalTo(previousPageView.snp.trailing).offset(1)
                } else {
                    $0.leading.equalToSuperview()
                }
                $0.width.equalTo(11)
                $0.height.equalTo(11)
            }

            let markView = UIView(frame: .zero)
            markView.layer.cornerRadius = 4.5
            markView.layer.masksToBounds = true
            markView.backgroundColor = (page == i) ?
                Color.main : Color.lightGray
            pageView.addWithConstraints(view: markView) {
                $0.center.equalToSuperview()
                $0.width.equalTo(9)
                $0.height.equalTo(9)
            }

            previousPageView = pageView
        }
        previousPageView?.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }
    }

    @objc func pageSelected(_ gestureRecognizer: UITapGestureRecognizer) {
        if let idx = gestureRecognizer.view?.tag {
            delegate?.pageSelected(idx: idx)
        }
    }
}
