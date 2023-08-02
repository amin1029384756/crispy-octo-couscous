import UIKit
import YPImagePicker
import GoogleSignIn
import Amplify
import AmplifyPlugins
import FirebaseAuth
import FirebaseFirestore

class ProfileScreen: Screen<ProfileLayout> {
    private var newAvatar: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        layout.startObservingKeyboard()

        if let profile = User.active?.profile {
            fillInProfile(profile)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        layout.endEditing(true)
        layout.stopObserving()

        super.viewWillDisappear(animated)
    }

    private func fillInProfile(_ profile: UserViewResponseResult) {
        layout.selectedSubcategories = Set(profile.interests?.map { $0.id } ?? [])
        layout.firstNameTextField.text = profile.firstName
        layout.lastNameTextField.text = profile.lastName
        layout.nicknameTextField.text = profile.nickname
        if let birthday = profile.birthday,
           birthday.contains("-") {
            let components = birthday.split(separator: "-")
            if components.count == 3,
                let monthId = Int(components[1]),
               monthId >= 1, monthId <= 12 {
                layout.birthdayYear.selection = String(components[0])
                layout.birthdayMonth.selection = ProfileLayout.months[monthId - 1]
                layout.birthdayDay.selection = String(components[2])
            }
        }
        layout.phoneTextField.text = profile.phone ?? ""
        layout.payPalIdTextField.text = profile.bankAccountId ?? ""
        layout.genderSelector.selection = profile.gender ?? "PREFER NOT TO SAY"
        if let hostInfo = profile.hostInfo {
            layout.hostInfo.set(hostInfo: hostInfo)
        }
        layout.showCategories()
    }

    func createKtorUpdateParams() -> KtorUpdateProfileArguments {
        var payPalId: String?
        if let text = layout.payPalIdTextField.text,
           !text.isEmpty {
            payPalId = text
        }
        var birthday: String?
        if let monthIdx = ProfileLayout.months.firstIndex(of: layout.birthdayMonth.selection),
           let day = Int(layout.birthdayDay.selection) {
            let monthId = String(format: "%02d", monthIdx + 1)
            let dayId = String(format: "%02d", day)
            birthday = "\(layout.birthdayYear.selection)-\(monthId)-\(dayId)"
        }

        let firstName = layout.firstNameTextField.text ?? ""
        let lastName = layout.lastNameTextField.text ?? ""
        let nickname = layout.nicknameTextField.text ?? ""
        let phone = layout.phoneTextField.text ?? ""
        let categoryIds = Array(layout.selectedSubcategories)
        let gender = layout.genderSelector.selection

        return KtorUpdateProfileArguments(
            firstName: firstName,
            lastName: lastName,
            nickname: nickname,
            profilePicture: User.active?.profile.profilePicture,
            email: User.active?.profile.email,
            birthday: birthday,
            gender: gender,
            phone: phone,
            payPalId: payPalId
        )
    }

    func createUpdateParams() -> UserUpdateRequestParams {
        var payPalId: String?
        if let text = layout.payPalIdTextField.text,
           !text.isEmpty {
            payPalId = text
        }
        var birthday: String?
        if let monthIdx = ProfileLayout.months.firstIndex(of: layout.birthdayMonth.selection),
           let day = Int(layout.birthdayDay.selection) {
            let monthId = String(format: "%02d", monthIdx + 1)
            let dayId = String(format: "%02d", day)
            birthday = "\(dayId)/\(monthId)/\(layout.birthdayYear.selection)"
        }

        let firstName = layout.firstNameTextField.text ?? ""
        let lastName = layout.lastNameTextField.text ?? ""
        let nickname = layout.nicknameTextField.text ?? ""
        let phone = layout.phoneTextField.text ?? ""
        let categoryIds = Array(layout.selectedSubcategories)
        let gender = layout.genderSelector.selection

        return UserUpdateRequestParams(
            first_name: firstName,
            last_name: lastName,
            nickname: nickname,
            email: User.active?.profile.email,
            birthday: birthday,
            phone: phone,
            bank_account: (payPalId == nil) ? nil : "paypal",
            bank_account_id: payPalId,
            interest_ids: categoryIds,
            quiz: User.active?.profile.quiz,
            gender: gender,
            profile_picture: newAvatar ?? User.active?.profile.profilePicture,
            host_info: layout.hostInfo.get()
        )
    }

    func save() {
        guard let activeUser = User.active else {
            show(error: "No active user. Try to log in")
            return
        }
        loader.show()
        Task {
            do {
                let params = createUpdateParams()
                _ = try await UserUpdateRequest(params: params)
                    .performRequest()
                let ktorParams = createKtorUpdateParams()
                _ = try await KtorUpdateProfile(args: ktorParams)
                    .performRequest()
                var chatName = params.nickname ?? ""
                if chatName.isEmpty {
                    chatName = params.first_name
                }
                if !chatName.isEmpty {
                    await updateNameInChats(name: chatName)
                }
                try await activeUser.loadProfile()

                await MainActor.run {
                    loader.dismiss()

                    if User.active?.role == UserRole.host,
                       User.active?.profile.quiz != true {
                        navigator.navigate(to: HostToDoListScreen.self)
                    } else {
                        navigator.pop()
                    }
                }
            } catch {
                await MainActor.run {
                    loader.dismiss()
                    show(error: error.localizedDescription)
                }
            }
        }
    }

    private func updateNameInChats(name: String) async {
        guard let currentUserUid = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        let batch = db.batch()
        let chatsRef = db.collection("chats")
        var updateCount = 0

        do {
            let chats = try await chatsRef
                .whereField("guestId", isEqualTo: currentUserUid)
                .getDocuments()
                .documents
            for chat in chats {
                batch.updateData([
                    "guestName": name
                ], forDocument: chatsRef.document(chat.documentID))
                updateCount += 1
            }
        } catch {
            print(error.localizedDescription)
        }

        do {
            let chats = try await chatsRef
                .whereField("hostId", isEqualTo: currentUserUid)
                .getDocuments()
                .documents
            for chat in chats {
                batch.updateData([
                    "hostName": name
                ], forDocument: chatsRef.document(chat.documentID))
                updateCount += 1
            }
        } catch {
            print(error.localizedDescription)
        }

        if updateCount > 0 {
            do {
                try await batch.commit()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func changeProfilePicture() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        withCameraAccess { [weak self] in
            var config = YPImagePickerConfiguration()
            config.screens = [.library, .photo]
            config.library.mediaType = .photo

            let picker = YPImagePicker(configuration: config)
            picker.didFinishPicking { [unowned picker, weak self] items, _ in
                if let photo = items.singlePhoto,
                   let data = photo.image
                       .cropToSquare()?
                       .resizeImageTo(size: CGSize(width: 256, height: 256))?
                       .jpegData(compressionQuality: 0.9) {
                    let time = Int(Date().timeIntervalSince1970)
                    let key = "profile/\(uid)/\(time).jpg"
                    let options = StorageUploadDataRequest.Options(contentType: "image/jpeg")
                    self?.loader.show()
                    Amplify.Storage.uploadData(key: key, data: data, options: options) { [weak self] event in
                        self?.newAvatar = "S3://\(StaticConfig.s3Bucket)/public/\(key)"
                        DispatchQueue.main.async { [weak self] in
                            self?.loader.dismiss()
                            self?.layout.profilePicture.image = photo.image
                        }
                    }
                }
                picker.dismiss(animated: true, completion: nil)
            }
            self?.present(picker, animated: true, completion: nil)
        }
    }

    override func goBack() {
        guard let activeUser = User.active else {
            User.active = nil
            GIDSignIn.sharedInstance.signOut()
            navigator.navigate(to: UserTypeSelectorScreen.self)
            return
        }

        let updateParams = createUpdateParams()
        if activeUser.areChangesPresent(updateRequestParams: updateParams) {
            let alert = UIAlertController(title: "Are you sure?", message: "You have unsaved changes", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Stay", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
                self?.goBackConfirmed()
            })
            alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                self?.save()
            })
            present(alert, animated: true)
        } else {
            goBackConfirmed()
        }
    }

    private func goBackConfirmed() {
        guard let activeUser = User.active else {
            User.active = nil
            GIDSignIn.sharedInstance.signOut()
            navigator.navigate(to: UserTypeSelectorScreen.self)
            return
        }

        if activeUser.profile.isComplete {
            super.goBack()
        } else {
            User.active = nil
            GIDSignIn.sharedInstance.signOut()
            navigator.navigate(to: UserTypeSelectorScreen.self)
        }
    }

    func deleteAccount() {
        let alert = UIAlertController(title: "Delete account?", message: "Your account will be deleted with your personal data", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete account", style: .destructive) { [weak self] _ in
            self?.deleteAccountConfirmed()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func deleteAccountConfirmed() {
        loader.show()
        Task {
            do {
                _ = try await UserDeleteInfoRequest()
                    .performRequest()

                await MainActor.run {
                    loader.dismiss()
                    User.active = nil
                    GIDSignIn.sharedInstance.signOut()
                    navigator.popToRoot()
                }
            } catch {
                await MainActor.run {
                    loader.dismiss()
                    show(error: error.localizedDescription)
                }
            }
        }
    }
}
