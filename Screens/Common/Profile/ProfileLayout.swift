import SnapKit
import UIKit
import Amplify
import DatePickerDialog

class ProfileLayout: Layout {
    var selectedSubcategories: Set<Int> = Set()

    static var userRole: UserRole {
        User.active?.role ?? .guest
    }

    lazy var titleLabel = Label(style: .screenTitle, text: "PROFILE")

    lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
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

        scrollableArea.addWithConstraints(view: profilePictureView) {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
        }

        scrollableArea.addWithConstraints(view: firstNameTextField) {
            $0.leading.equalToSuperview().offset(112)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(profilePictureView.snp.bottom).offset(32)
            $0.height.equalTo(24)
        }

        scrollableArea.addWithConstraints(view: firstNameLabel) {
            $0.leading.equalToSuperview().offset(42)
            $0.trailing.equalTo(firstNameTextField.snp.leading).offset(-4)
            $0.centerY.equalTo(firstNameTextField.snp.centerY)
        }

        scrollableArea.addWithConstraints(view: lastNameTextField) {
            $0.leading.equalToSuperview().offset(112)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(firstNameTextField.snp.bottom).offset(19)
            $0.height.equalTo(24)
        }

        scrollableArea.addWithConstraints(view: lastNameLabel) {
            $0.leading.equalToSuperview().offset(42)
            $0.trailing.equalTo(lastNameTextField.snp.leading).offset(-4)
            $0.centerY.equalTo(lastNameTextField.snp.centerY)
        }

        scrollableArea.addWithConstraints(view: nicknameTextField) {
            $0.leading.equalToSuperview().offset(112)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(lastNameTextField.snp.bottom).offset(19)
            $0.height.equalTo(24)
        }

        scrollableArea.addWithConstraints(view: nicknameLabel) {
            $0.leading.equalToSuperview().offset(42)
            $0.trailing.equalTo(nicknameTextField.snp.leading).offset(-4)
            $0.centerY.equalTo(nicknameTextField.snp.centerY)
        }

        scrollableArea.addWithConstraints(view: birthdayMonth) {
            $0.leading.equalToSuperview().offset(112)
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(19)
            $0.height.equalTo(24)
        }

        scrollableArea.addWithConstraints(view: birthdayDay) {
            $0.leading.equalTo(birthdayMonth.snp.trailing).offset(8)
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(19)
            $0.height.equalTo(24)
            $0.width.equalTo(birthdayMonth.snp.width).multipliedBy(0.5)
        }

        scrollableArea.addWithConstraints(view: birthdayYear) {
            $0.leading.equalTo(birthdayDay.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(19)
            $0.height.equalTo(24)
            $0.width.equalTo(birthdayMonth.snp.width).multipliedBy(0.8)
        }

        scrollableArea.addWithConstraints(view: birthdaySelectButton) {
            $0.fillHorizontally()
            $0.height.equalTo(28)
            $0.centerY.equalTo(birthdayDay.snp.centerY)
        }

        scrollableArea.addWithConstraints(view: birthdayLabel) {
            $0.leading.equalToSuperview().offset(42)
            $0.trailing.equalTo(birthdayMonth.snp.leading).offset(-4)
            $0.centerY.equalTo(birthdayMonth.snp.centerY)
        }

        scrollableArea.addWithConstraints(view: phoneTextField) {
            $0.leading.equalToSuperview().offset(112)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(birthdayDay.snp.bottom).offset(19)
            $0.height.equalTo(24)
        }

        scrollableArea.addWithConstraints(view: phoneLabel) {
            $0.leading.equalToSuperview().offset(42)
            $0.trailing.equalTo(phoneTextField.snp.leading).offset(-4)
            $0.centerY.equalTo(phoneTextField.snp.centerY)
        }

        scrollableArea.addWithConstraints(view: genderSelector) {
            $0.leading.equalToSuperview().offset(112)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(phoneLabel.snp.bottom).offset(19)
            $0.height.equalTo(24)
        }

        scrollableArea.addWithConstraints(view: genderLabel) {
            $0.leading.equalToSuperview().offset(42)
            $0.trailing.equalTo(genderSelector.snp.leading).offset(-4)
            $0.centerY.equalTo(genderSelector.snp.centerY)
        }

        var previousView: UIView = genderLabel

        switch ProfileLayout.userRole {
        case .guest:
            scrollableArea.addWithConstraints(view: interestsLabel) {
                $0.leading.equalToSuperview().offset(42)
                $0.trailing.equalToSuperview().offset(-30)
                $0.top.equalTo(previousView.snp.bottom).offset(19)
                $0.height.equalTo(24)
            }

            scrollableArea.addWithConstraints(view: categoriesContainer) {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.top.equalTo(interestsLabel.snp.bottom)
            }

            previousView = categoriesContainer

        case .host:
            scrollableArea.addWithConstraints(view: hostInfo) {
                $0.leading.equalToSuperview().offset(42)
                $0.trailing.equalToSuperview().offset(-30)
                $0.top.equalTo(previousView.snp.bottom).offset(24)
            }
            scrollableArea.addWithConstraints(view: paymentInformationLabel) {
                $0.leading.equalToSuperview().offset(42)
                $0.trailing.equalToSuperview().offset(-30)
                $0.top.equalTo(hostInfo.snp.bottom).offset(19)
                $0.height.equalTo(24)
            }

            previousView = paymentInformationLabel
        }

        scrollableArea.addWithConstraints(view: payPalImage) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(previousView.snp.bottom).offset(21)
            $0.width.equalTo(127)
            $0.height.equalTo(86)
        }

        scrollableArea.addWithConstraints(view: payPalIdLabel) {
            $0.leading.equalToSuperview().offset(42)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(payPalImage.snp.bottom).offset(19)
            $0.height.equalTo(24)
        }

        scrollableArea.addWithConstraints(view: payPalIdTextField) {
            $0.leading.equalToSuperview().offset(42)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(payPalIdLabel.snp.bottom).offset(4)
            $0.height.equalTo(24)
        }

        scrollableArea.addWithConstraints(view: saveButton) {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(146)
            $0.top.equalTo(payPalIdTextField.snp.bottom).offset(46)
        }

        scrollableArea.addWithConstraints(view: mandatoryFieldsLabel) {
            $0.leading.equalToSuperview().offset(42)
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(saveButton.snp.bottom).offset(27)
            $0.height.equalTo(24)
        }

        let deleteTapDetector = UITapGestureRecognizer(target: self, action: #selector(deleteAccount))
        deleteButton.isUserInteractionEnabled = true
        deleteButton.textAlignment = .center
        deleteButton.addGestureRecognizer(deleteTapDetector)
        scrollableArea.addWithConstraints(view: deleteButton) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(mandatoryFieldsLabel.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().offset(-48)
            $0.height.equalTo(24)
        }

        return scrollableArea
    }()

    lazy var profilePictureTapDetector = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))

    lazy var profilePictureView: UIView = {
        let view = UIView()

        view.addWithConstraints(view: profilePicture) {
            $0.edges.equalToSuperview()
        }

        changeProfilePictureIcon.contentMode = .scaleAspectFill
        view.addWithConstraints(view: changeProfilePictureIcon) {
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            switch ProfileLayout.userRole {
            case .guest:
                $0.width.equalTo(20)
                $0.height.equalTo(20)

            case .host:
                $0.width.equalTo(32)
                $0.height.equalTo(32)
            }
        }

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(profilePictureTapDetector)

        view.snp.makeConstraints {
            switch ProfileLayout.userRole {
            case .guest:
                $0.width.equalTo(46)
                $0.height.equalTo(46)

            case .host:
                $0.width.equalTo(94)
                $0.height.equalTo(94)
            }
        }

        return view
    }()

    lazy var profilePicture: Image = {
        let imageView = Image(asset: .iconAccount)
        if let imageUrl = User.active?.profile.profilePicture,
           !imageUrl.isEmpty {
            imageView.show(url: imageUrl)
        } else if let image = User.active?.profile.avatar?.base64Image {
            imageView.image = image
        }
        switch ProfileLayout.userRole {
        case .guest:
            imageView.layer.cornerRadius = 23

        case .host:
            imageView.layer.cornerRadius = 23
        }
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var changeProfilePictureIcon = Image(asset: .buttonChangeProfilePhoto)

    lazy var firstNameLabel = Label(
        style: .small,
        text: "FIRST NAME:*",
        color: Color.mainText,
        lines: 1)

    lazy var firstNameTextField: TextField = {
        let textField = TextField()
        textField.delegate = self
        return textField
    }()

    lazy var lastNameLabel = Label(
        style: .small,
        text: "LAST NAME:*",
        color: Color.mainText,
        lines: 1)

    lazy var lastNameTextField: TextField = {
        let textField = TextField()
        textField.delegate = self
        return textField
    }()

    lazy var nicknameLabel = Label(
        style: .small,
        text: "NICKNAME:*",
        color: Color.mainText,
        lines: 1)

    lazy var nicknameTextField: TextField = {
        let textField = TextField()
        textField.delegate = self
        return textField
    }()

    lazy var birthdayLabel = Label(
        style: .small,
        text: "BIRTHDAY:",
        color: Color.mainText,
        lines: 1)

    lazy var birthdayMonth = ComboBox(optionList: ProfileLayout.months, selection: "JANUARY", delegate: self)

    lazy var birthdayDay = ComboBox(optionList: [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
        "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
        "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
        "31"
    ], selection: "1", delegate: self)

    lazy var birthdayYear = ComboBox(
        optionList: stride(from: 1922, to: 2023, by: 1).map { "\($0)" },
        selection: "2000",
        delegate: self)

    lazy var birthdaySelectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" ", for: .normal)
        button.addTarget(self, action: #selector(birthdaySelect), for: .touchUpInside)
        return button
    }()

    lazy var phoneLabel = Label(
        style: .small,
        text: "PHONE:",
        color: Color.mainText,
        lines: 1)

    lazy var phoneTextField: TextField = {
        let textField = TextField()
        textField.delegate = self
        return textField
    }()

    lazy var genderLabel = Label(
        style: .small,
        text: "GENDER:",
        color: Color.mainText,
        lines: 1)

    lazy var genderSelector = ComboBox(optionList: [
        "MALE", "FEMALE", "NON-BINARY", "PREFER NOT TO SAY"
    ], selection: "PREFER NOT TO SAY", delegate: self)

    lazy var hostInfo = HostInfoFormInputView()

    lazy var payPalImage: Image = {
        let image = Image(
            asset: .iconPaypal
        )
        image.backgroundColor = Color.lightGray
        image.contentMode = .center
        image.layer.cornerRadius = 12
        image.layer.masksToBounds = true
        return image
    }()

    lazy var paymentInformationLabel = Label(
        style: .small,
        text: "PAYMENT INFORMATION:*",
        color: Color.mainText,
        lines: 1)

    lazy var interestsLabel = Label(
        style: .small,
        text: "INTERESTS:",
        color: Color.mainText,
        lines: 1)

    lazy var saveButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "SAVE",
        image: nil,
        delegate: self)

    lazy var mandatoryFieldsLabel = Label(
        style: .small,
        text: "* signifies mandatory fields".uppercased(),
        color: Color.mainText,
        lines: 1)

    lazy var payPalIdLabel = Label(
        style: .small,
        text: "ENTER YOUR PayPal ID:",
        color: Color.mainText,
        lines: 1)

    lazy var payPalIdTextField: TextField = {
        let textField = TextField()
        textField.delegate = self
        return textField
    }()

    lazy var categoriesContainer: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        return containerView
    }()

    lazy var deleteButton = Label(style: .normal, text: "DELETE ACCOUNT", color: .red, lines: 1)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    weak var screen: ProfileScreen?

    var mainScrollViewBottomConstraint: ConstraintMakerEditable!

    override func createLayout() {
        super.createLayout()

        addWithConstraints(view: titleLabel) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin).offset(40)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: mainScrollView) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            mainScrollViewBottomConstraint = $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }

        if ProfileLayout.userRole == .guest {
            showCategories()
        }
    }

    @objc func subcategorySelected(_ tapDetector: UITapGestureRecognizer) {
        guard let subcategoryId = tapDetector.view?.tag else {
            return
        }

        for category in Cat.list {
            if let subCat = category.subcategories.first(where: { $0.id == subcategoryId }) {
                if selectedSubcategories.contains(subCat.id) {
                    selectedSubcategories.remove(subCat.id)
                } else {
                    selectedSubcategories.insert(subCat.id)
                }
                break
            }
        }

        showCategories()
    }

    func showCategories() {
        let oldSubviews = categoriesContainer.subviews
        oldSubviews.forEach {
            $0.removeFromSuperview()
        }

        var previousView: UIView?

        for category in Cat.list {
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

    func startObservingKeyboard() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleKeyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(self,
            selector: #selector(handleKeyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc private func handleKeyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        mainScrollViewBottomConstraint.constraint.update(offset: -keyboardFrame.size.height)
        layoutIfNeeded()
    }

    @objc private func handleKeyboardWillHide() {
        mainScrollViewBottomConstraint.constraint.update(offset: 0)
        layoutIfNeeded()
    }

    @objc func changeProfilePicture() {
        screen?.changeProfilePicture()
    }

    @objc func deleteAccount() {
        screen?.deleteAccount()
    }

    @objc func birthdaySelect() {
        endEditing(true)

        let calendar = Calendar(identifier: .gregorian)

        var initialDate = Date()
        if let monthIdx = ProfileLayout.months.firstIndex(of: birthdayMonth.selection),
           let day = Int(birthdayDay.selection),
           let year = Int(birthdayYear.selection) {
            let components = DateComponents(
                calendar: calendar, timeZone: .current, era: nil,
                year: year,
                month: monthIdx + 1,
                day: day,
                hour: 12)
            initialDate = calendar.date(from: components) ?? Date()
        }

        DatePickerDialog().show(
            "Date of Birth",
            doneButtonTitle: "Done",
            cancelButtonTitle: "Cancel",
            defaultDate: initialDate,
            maximumDate: Date(),
            datePickerMode: .date
        ) { [weak self] date in
            if let dt = date {
                let year = calendar.component(.year, from: dt)
                let monthIdx = calendar.component(.month, from: dt)
                let day = calendar.component(.day, from: dt)

                self?.birthdayYear.selection = "\(year)"
                self?.birthdayMonth.selection = ProfileLayout.months[monthIdx - 1]
                self?.birthdayDay.selection = "\(day)"
            }
        }
    }

    static let months = [
        "JANUARY", "FEBRUARY", "MARCH", "APRIL",
        "MAY", "JUNE", "JULY", "AUGUST",
        "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
    ]
}

extension ProfileLayout: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let coordinateInWindow = textField.convert(CGPoint(), to: self)
        if coordinateInWindow.y > UIScreen.main.bounds.height / 2 {
            mainScrollView.contentOffset = CGPoint(x: 0, y: coordinateInWindow.y - UIScreen.main.bounds.height / 2)
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension ProfileLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension ProfileLayout: ComboBoxDelegate {
    func comboBoxSelectionChanged(comboBox: ComboBox, selection: String) {

    }
}

extension ProfileLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case saveButton:
            screen?.save()

        default:
            break
        }
    }
}
