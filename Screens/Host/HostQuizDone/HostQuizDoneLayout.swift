import UIKit

class HostQuizDoneLayout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "QUIZ", customTopView: nil, delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)
    
    lazy var continueButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "SCHEDULE AN INTERVIEW",
        image: nil,
        delegate: self)
    
    lazy var topPadding = UIView()
    
    lazy var bottomPadding = UIView()
    
    lazy var donePicture = Image(asset: .quizDone)
    
    lazy var textLabel = Label(
        style: .large,
        text: "CONGRATULATIONS!\nYOU HAVE PASSED THE QUIZ!",
        color: Color.mainText,
        lines: 2)

    weak var screen: HostQuizDoneScreen?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
        
        addWithConstraints(view: continueButton) {
            $0.bottom.equalTo(bottomBackButton.snp.top).offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(220)
        }
        
        addWithConstraints(view: topPadding) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(topBar.snp.bottom)
        }
        
        addWithConstraints(view: bottomPadding) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(continueButton.snp.top)
            $0.height.equalTo(topPadding.snp.height)
        }
        
        donePicture.contentMode = .scaleAspectFit
        addWithConstraints(view: donePicture) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(195)
            $0.top.equalTo(topPadding.snp.bottom)
        }
        
        textLabel.textAlignment = .center
        addWithConstraints(view: textLabel) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(donePicture.snp.bottom).offset(12)
            $0.bottom.equalTo(bottomPadding.snp.top)
            $0.height.equalTo(40)
        }
    }
}

extension HostQuizDoneLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostQuizDoneLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension HostQuizDoneLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case continueButton:
            screen?.goNext()
            
        default:
            break
        }
    }
}
