import UIKit

class HostBecome2Layout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "Become a Host - Store Menu", customTopView: nil, delegate: self)

    lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.keyboardDismissMode = .onDrag
        scrollView.addWithConstraints(view: mainScrollableArea) {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        return scrollView
    }()

    lazy var mainScrollableArea: UIView = {
        let scrollableArea = UIView()
        scrollableArea.backgroundColor = .clear

        label1.textAlignment = .center
        scrollableArea.addWithConstraints(view: label1) {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
        }

        label2.textAlignment = .center
        scrollableArea.addWithConstraints(view: label2) {
            $0.top.equalTo(label1.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
        }

        micLogo.isHidden = true
        scrollableArea.addWithConstraints(view: micLogo) {
            $0.top.equalTo(label2.snp.top).offset(4)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(15)
            $0.height.equalTo(21)
        }

        scrollableArea.addWithConstraints(view: categoriesContainer) {
            $0.top.equalTo(label2.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        scrollableArea.addWithConstraints(view: continueButton) {
            $0.top.equalTo(categoriesContainer.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(146)
            $0.bottom.equalToSuperview().offset(-96)
        }

        return scrollableArea
    }()

    lazy var label1 = Label(
        style: .regular,
        text: "SELECT THE EXPERIENCE(S) YOU WOULD LIKE TO OFFER!",
        color: Color.mainText,
        lines: 0)

    let textSubtitleTalk = "\n\n\nHOSTS CAN ONLY OFFER EXPERIENCES IN ONE CATEGORY\ne.g. CONVERSATIONS OR EXERCISE"
    let colorSubtitleTalk = Color.mainText
    let textSubtitleListen = "\n\n\nIn this experience, the guest is dialing in to be a listener. You will be the story teller.".uppercased()
    let textSubtitleListenVideoOnly = "\n\n\nIn this experience, the guest is only watching your videos. You can communicate only via chat.".uppercased()
    let colorSubtitleListen = UIColor(red: 0.99, green: 0.24, blue: 0.30, alpha: 1.00)

    lazy var label2 = Label(
        style: .smallNormal,
        text: textSubtitleTalk,
        color: colorSubtitleTalk,
        lines: 0)

    lazy var micLogo = Image(asset: .iconTalkMore, tint: colorSubtitleListen)

    lazy var categoriesContainer: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        return containerView
    }()

    lazy var continueButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "CONTINUE",
        image: nil,
        delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    private var categories: [CategoryResponseResult] = []
    var selectedCategory: CategoryResponseResult?
    var selectedSubcategory: SubcategoryResponseResult?

    weak var screen: HostBecome2Screen?

    override func createLayout() {
        addWithConstraints(view: mainScrollView) {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(mainScrollView.snp.top)
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
    }

    func show(categories: [CategoryResponseResult]) {
        self.categories = categories
        let oldSubviews = categoriesContainer.subviews
        oldSubviews.forEach {
            $0.removeFromSuperview()
        }

        var previousView: UIView?
        for category in categories {
            let categoryView = createView(for: category)
            categoriesContainer.addWithConstraints(view: categoryView) {
                $0.leading.equalToSuperview().offset(16)
                $0.trailing.equalToSuperview().offset(-16)
                if let previousView = previousView {
                    $0.top.equalTo(previousView.snp.bottom).offset(24)
                } else {
                    $0.top.equalToSuperview()
                }
            }
            previousView = categoryView
        }
        previousView?.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-8)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func createView(for category: CategoryResponseResult) -> UIView {
        let categoryView = UIView()
        categoryView.backgroundColor = .clear

        let titleLabel = UILabel()
        categoryView.addWithConstraints(view: titleLabel) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
        }
        setTitleLabelText(category: category, titleLabel: titleLabel)

        var previousView: UIView = titleLabel

        for i in stride(from: 0, to: category.subcategories.count, by: 2) {
            var subcategoryViews: [UIView] = [
                createView(for: category.subcategories[i])
            ]
            if i + 1 < category.subcategories.count {
                subcategoryViews.append(
                    createView(for: category.subcategories[i + 1])
                )
            }

            let containerView = UIView()
            containerView.backgroundColor = .clear

            containerView.addWithConstraints(view: subcategoryViews[0]) {
                $0.centerY.equalToSuperview()

                if subcategoryViews.count == 1 {
                    $0.centerX.equalToSuperview()
                } else {
                    $0.centerX.equalToSuperview().offset(-52)
                }
            }

            if subcategoryViews.count > 1 {
                containerView.addWithConstraints(view: subcategoryViews[1]) {
                    $0.centerY.equalToSuperview()
                    $0.centerX.equalToSuperview().offset(52)
                }
            }

            categoryView.addWithConstraints(view: containerView) {
                $0.top.equalTo(previousView.snp.bottom).offset(6)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.height.equalTo(32)
            }

            previousView = containerView
        }

        previousView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
        }

        return categoryView
    }

    private func createView(for subcategory: SubcategoryResponseResult) -> UIView {
        let subcategoryView = UIView()
        subcategoryView.tag = subcategory.id
        subcategoryView.layer.cornerRadius = 16
        subcategoryView.layer.borderWidth = 1
        subcategoryView.isUserInteractionEnabled = true

        let tapDetector = UITapGestureRecognizer(target: self, action: #selector(subcategorySelected(_:)))
        subcategoryView.addGestureRecognizer(tapDetector)

        let icon = subcategory.icon.base64Image?.withRenderingMode(.alwaysTemplate)
        let title = subcategory.name

        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit

        let titleLabel = Label(
            style: .xsmall,
            text: title,
            color: Color.mainText,
            lines: 2)
        let separatorLine = UIView()

        if subcategory.id == selectedSubcategory?.id {
            subcategoryView.backgroundColor = Color.main
            subcategoryView.layer.borderColor = Color.main.cgColor
            titleLabel.textColor = .white
            iconView.tintColor = .white
            separatorLine.backgroundColor = .white
        } else {
            subcategoryView.backgroundColor = .white
            subcategoryView.layer.borderColor = Color.darkGray.cgColor
            titleLabel.textColor = Color.mainText
            iconView.tintColor = Color.main
            separatorLine.backgroundColor = Color.mainText
        }

        subcategoryView.addWithConstraints(view: iconView) {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.width.equalTo(24)
        }

        subcategoryView.addWithConstraints(view: separatorLine) {
            $0.width.equalTo(1)
            $0.height.equalTo(16)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconView.snp.trailing).offset(4)
        }

        subcategoryView.addWithConstraints(view: titleLabel) {
            $0.leading.equalTo(separatorLine.snp.trailing).offset(3)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-8)
        }

        subcategoryView.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(32)
        }

        return subcategoryView
    }

    private func setTitleLabelText(category: CategoryResponseResult, titleLabel: UILabel) {
        let titleText = NSMutableAttributedString(
            string: "\(category.name): ",
            attributes: [
                .font: Font.regular[10],
                .foregroundColor: Color.mainText
            ])
        titleText.append(NSAttributedString(
            string: "(\((category.duration * 60).secondsToString) - \(String(format: "$%.02f", category.price)))",
            attributes: [
                .font: Font.regular[8],
                .foregroundColor: Color.mainText
            ]))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        titleText.addAttributes([
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: titleText.length))

        titleLabel.attributedText = titleText
    }

    @objc func subcategorySelected(_ tapDetector: UITapGestureRecognizer) {
        guard let subcategoryId = tapDetector.view?.tag else {
            return
        }

        for category in categories {
            if let subcategory = category.subcategories.first(where: { $0.id == subcategoryId }) {
                selectedSubcategory = subcategory
                selectedCategory = category
                if selectedSubcategory?.isListen == true {
                    if selectedSubcategory?.isVideoOnly == true {
                        label2.text = textSubtitleListenVideoOnly
                    } else {
                        label2.text = textSubtitleListen
                    }
                    label2.textColor = colorSubtitleListen
                    micLogo.isHidden = false
                } else {
                    label2.text = textSubtitleTalk
                    label2.textColor = colorSubtitleTalk
                    micLogo.isHidden = true
                }
                break
            }
        }

        show(categories: categories)
    }
}

extension HostBecome2Layout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostBecome2Layout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case continueButton:
            screen?.goNext(
                selectedCategory: selectedCategory,
                selectedSubcategory: selectedSubcategory)

        default:
            break
        }
    }
}

extension HostBecome2Layout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}
