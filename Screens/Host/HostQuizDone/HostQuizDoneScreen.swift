import UIKit

class HostQuizDoneScreen: Screen<HostQuizDoneLayout> {
    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self

        markQuizAsPassed()
    }

    private func markQuizAsPassed() {
        User.active?.profile.quiz = true

        guard let activeUser = User.active else {
            return
        }

        var birthday: String?
        let birthdayComponents = (activeUser.profile.birthday ?? "").split(separator: "-")
        if birthdayComponents.count == 3,
           let year = Int(birthdayComponents[0]),
            let month = Int(birthdayComponents[1]),
            let day = Int(birthdayComponents[2]) {
            birthday = String(format: "%02d/%02d/%04d", day, month, year)
        }

        let params = UserUpdateRequestParams(
            first_name: activeUser.profile.firstName,
            last_name: activeUser.profile.lastName,
            email: activeUser.profile.email,
            birthday: birthday,
            phone: activeUser.profile.phone,
            bank_account: activeUser.profile.bankAccount,
            bank_account_id: activeUser.profile.bankAccountId,
            interest_ids: activeUser.profile.interests?.map { $0.id } ?? [],
            quiz: true,
            profile_picture: activeUser.profile.profilePicture)
        UserUpdateRequest(params: params)
            .performRequestWithDelegate { [weak self] _, error in
            if let error = error {
                self?.show(error: error.localizedDescription)
            }
        }
    }
    
    func goNext() {
        URLs.interviewLink.openInExternalBrowser()
        goBack()
    }

    override func goBack() {
        if !navigator.pop(to: HostPanelScreen.self) {
            let hostPanelScreen = HostPanelScreen()
            navigator.replaceStack(newStack: [
                0,
                hostPanelScreen
            ])
        }
    }
}
