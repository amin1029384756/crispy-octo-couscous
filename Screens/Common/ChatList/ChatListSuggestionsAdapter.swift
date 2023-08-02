import UIKit

protocol ChatListSuggestionsAdapterDelegate: AnyObject {
    func suggestionSelected(suggestion: KtorGetChatSuggestedGuestsResponse)
}

class ChatListSuggestionsAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    var suggestions: [KtorGetChatSuggestedGuestsResponse] = []
    weak var delegate: ChatListSuggestionsAdapterDelegate?

    init(delegate: ChatListSuggestionsAdapterDelegate?) {
        self.delegate = delegate
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let suggestion = suggestions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatSuggestionItemCell.cellId, for: indexPath)
        if let chatSuggestionItemCell = cell as? ChatSuggestionItemCell {
            chatSuggestionItemCell.show(suggestion: suggestion)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        66
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.suggestionSelected(suggestion: suggestions[indexPath.row])
    }
}
