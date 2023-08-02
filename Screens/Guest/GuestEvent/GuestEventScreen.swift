import UIKit
import Alamofire
import FirebaseAuth
import FirebaseFirestore

class GuestEventScreen: ScreenWithInput<GuestEventLayout, ExperienceIndexResponseResult> {
    let db = Firestore.firestore()

    var event: ExperienceIndexResponseResult!
    var calendarMonth: Int!
    var calendarYear: Int!
    var selectedDate = Date()
    var selectedSession: SessionResponseResult? {
        didSet {
            layout.bookNowButton.isEnabled = selectedSession != nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        calendarYear = dateComponents.year!
        calendarMonth = dateComponents.month!

        layout.screen = self
    }

    override func input(_ argument: ExperienceIndexResponseResult) {
        event = argument
        event.sessions = event.sessions?.filter {
            !$0.isFull
        }
        selectedSession = nil

        loadViewIfNeeded()

        layout.show(event: event, calendarMonth: calendarMonth, calendarYear: calendarYear, selectedDate: selectedDate)
    }

    func submit(stars: Int, review: String) {
        view.endEditing(true)

        let experienceId = event.id
        loader.show()
        ReviewCreateRequest(experienceId: experienceId, star: stars, comment: review)
            .performRequestWithDelegate { [weak self] response, error in
            self?.loader.dismiss()

            if let error = error {
                self?.show(error: error.localizedDescription)
            } else {
                let alert = UIAlertController(title: "Review submitted (\(stars) stars)", message: review, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    func makeBooking() {
        view.endEditing(true)

        guard let selectedSession = selectedSession else {
            return
        }

        ReservationCreateRequest(
            experienceId: event.id,
            reservationSession: selectedSession.id)
            .performRequestWithDelegate { [weak self, event] response, error in
            if let error = error {
                self?.show(error: error.localizedDescription)
                return
            }

            if let reservationId = response?.result.data?.reservation?.id {
                self?.navigator.navigate(
                    to: GuestWalletPayScreen.self,
                    argument: GuestWalletPayArguments(
                        experience: event!,
                        selectedSession: selectedSession,
                        reservationId: reservationId
                    ))
            } else {
                let message = response?.result.message ?? "Reservation was not created"
                self?.show(error: message)
            }
        }
    }

    fileprivate func openMedia(_ media: ExperienceIndexResponseResultMedia) {
        Task {
            var mediaWithResolvedUrl = media
            _ = try? await mediaWithResolvedUrl.resolveUrl()
            if let url = URL(string: mediaWithResolvedUrl.url) {
                await MainActor.run {
                    if media.mimeType.starts(with: "image") {
                        let imagePreviewScreen = ImagePreviewScreen()
                        imagePreviewScreen.input(url)
                        imagePreviewScreen.modalPresentationStyle = .formSheet
                        present(imagePreviewScreen, animated: true)
                    } else {
                        let videoPreviewScreen = VideoPreviewScreen()
                        videoPreviewScreen.input(url)
                        videoPreviewScreen.modalPresentationStyle = .formSheet
                        present(videoPreviewScreen, animated: true)
                    }
                }
            }
        }
    }

    func preview(medias: [ExperienceIndexResponseResultMedia]) {
        if let media = medias.first(where: { $0.mimeType.starts(with: "video") }) ??
            medias.first(where: { $0.mimeType.starts(with: "image") }) {
            openMedia(media)
        }
    }

    func startChat(createIfNot: Bool = true) {
        guard let guestUID = Auth.auth().currentUser?.uid,
              let hostUID = event.host_uid
        else {
            return
        }

        loader.showIfNot()
        db.collection("chats")
            .whereField("guestId", isEqualTo: guestUID)
            .whereField("hostId", isEqualTo: hostUID)
            .getDocuments { [weak self] (querySnapshot: QuerySnapshot?, error: Error?) in
                if let error = error {
                    self?.loader.dismiss()
                    self?.show(error: error.localizedDescription)
                } else if let querySnapshot = querySnapshot,
                    let document = querySnapshot.documents.first {
                    self?.loader.dismiss()
                    if let chatInfo = document.toChatInfo() {
                        self?.startChat(chatInfo: chatInfo)
                    }
                } else if createIfNot {
                    self?.createChat(guestUID: guestUID, hostUID: hostUID)
                } else {
                    self?.loader.dismiss()
                    self?.show(error: "Chat doesn't exist and couldn't be created")
                }
            }
    }

    private func createChat(guestUID: String, hostUID: String) {
        loader.showIfNot()
        db.collection("chats")
            .document()
            .setData([
                "guestId": guestUID,
                "hostId": hostUID,
                "guestName": guestDisplayName,
                "hostName": event.host ?? "",
                "messagesAvailable": StaticConfig.messagesAvailableInChat,
                "messagesUsed": 0,
                "messagesOnDemandAvailable": 0,
                "messagesOnDemandUsed": 0
            ], completion: { [weak self] error in
                if let error = error {
                    self?.loader.dismiss()
                    self?.show(error: error.localizedDescription)
                } else {
                    self?.startChat(createIfNot: false)
                }
            })
    }

    private func startChat(chatInfo: ChatInfo) {
        let chatScreen = ChatScreen()
        chatScreen.chatInfo = chatInfo
        navigator.navigationController.pushViewController(chatScreen, animated: true)
    }

    private var guestDisplayName: String {
        if let nickname = User.active?.profile.nickname?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !nickname.isEmpty {
            return nickname
        } else if let firstName = User.active?.profile.firstName
            .trimmingCharacters(in: .whitespacesAndNewlines),
                  !firstName.isEmpty {
            return firstName
        } else {
            return Auth.auth().currentUser?.displayName ?? ""
        }
    }
}
