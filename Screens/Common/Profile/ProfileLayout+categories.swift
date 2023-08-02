import UIKit
import SnapKit

extension ProfileLayout {
    func createView(for category: CategoryResponseResult) -> UIView {
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

        if selectedSubcategories.contains(subcategory.id) {
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
            string: "(\((category.duration * 60).secondsToString) - $\(String(format: "%.02f", category.price)))",
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
}
