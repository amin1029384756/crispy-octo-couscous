import UIKit

extension BaseScreen {
    func openWallet() {
        view.endEditing(true)

        navigator.navigate(to: GuestBookedExperiencesScreen.self)
    }

    func openEarnings() {
        view.endEditing(true)

        navigator.navigate(to: HostEarningsScreen.self)
    }

    func openCoins() {
        view.endEditing(true)

        navigator.navigate(to: GuestCoinsScreen.self)
    }
    
    func openChatList() {
        view.endEditing(true)

        navigator.navigate(to: ChatListScreen.self)
    }
}
