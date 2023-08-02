import UIKit

protocol ChatListAdapterDelegate: AnyObject {
    func chatSelected(chatInfo: ChatInfo)
}

class ChatListAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    var chats: [(ChatInfo, ChatMessage)] = []
    weak var delegate: ChatListAdapterDelegate?

    init(delegate: ChatListAdapterDelegate?) {
        self.delegate = delegate
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatItemCell.cellId, for: indexPath)
        if let chatItemCell = cell as? ChatItemCell {
            chatItemCell.show(chatInfo: chat.0, chatMessage: chat.1)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        66
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.chatSelected(chatInfo: chats[indexPath.row].0)
    }
}
