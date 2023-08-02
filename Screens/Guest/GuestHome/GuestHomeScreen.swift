import UIKit

class GuestHomeScreen: Screen<GuestHomeLayout> {
    lazy var adapter = GuestHomeAdapter(items: [], delegate: self)

    var eventGroups = [SubcategoryResponseResult]()
    var events = [ExperienceIndexResponseResult]()
    var expandedGroups = Set<Int>()
    var preferListen = false

    override func viewDidLoad() {
        super.viewDidLoad()

        preferListen = UserDefaults.standard.bool(forKey: "com.wythyou.option.preferListen")

        layout.screen = self

        eventGroups = []
        let cats = Cat.list
        for cat in cats {
            eventGroups.append(contentsOf: cat.subcategories)
        }

        eventGroups = eventGroups.filter { eventGroup in
            events.first(where: { event in
                event.category_id == eventGroup.id
            }) != nil
        }

        loader.show()
        Task {
            events = await loadExperiences()
            expandedGroups = Set(events
//                .filter { !($0.sessions ?? []).isEmpty }
                .map { $0.category_id }
            )

            await MainActor.run {
                loader.dismiss()
                update()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        layout.coinsBox.update(balance: User.active?.coins ?? 0)
    }

    private func showWelcomePopupIfNotYet() {
        if UserDefaults.standard.bool(forKey: "wythyou.welcome.shown") {
            return
        }

        let popup = WelcomePopup(delegate: self)
        layout.addWithConstraints(view: popup) {
            $0.edges.equalToSuperview()
        }
    }

    private func loadExperiences() async -> [ExperienceIndexResponseResult] {
        do {
            let response = try await ExperienceIndexRequest(type: .guest)
                .performRequest()
            return response.result.data ?? []
        } catch {
            return []
        }
    }

    func filterUpdated(preferListen: Bool) {
        self.preferListen = preferListen
        update()
    }

    func update() {
        let cats = Cat.list
        eventGroups.removeAll()
        for cat in cats {
            eventGroups.append(contentsOf: cat.subcategories.filter {
                $0.isListen && preferListen || !$0.isListen && !preferListen
            })
        }

        eventGroups = eventGroups.filter { eventGroup in
            events.first(where: { event in
                event.category_id == eventGroup.id
            }) != nil
        }

        var items = [Any]()

        for eventGroup in eventGroups {
            items.append(eventGroup)
            if expandedGroups.contains(eventGroup.id) {
                items.append(
                    contentsOf: events.filter {
                        $0.category_id == eventGroup.id
                    }
                )
            }
        }

        adapter.update(items: items, expanded: expandedGroups)
        layout.list.delegate = adapter
        layout.list.dataSource = adapter
        layout.list.reloadData()
        layout.refreshControl.endRefreshing()

        showWelcomePopupIfNotYet()
    }

    override func refresh() {
        super.refresh()

        layout.topBar.refresh()
        layout.chatButton.updateBadge()

        Task {
            events = await loadExperiences()
            expandedGroups = Set(events
//                .filter { !($0.sessions ?? []).isEmpty }
                .map { $0.category_id }
            )

            await MainActor.run {
                update()
            }
        }
    }
}

extension GuestHomeScreen: GuestHomeAdapterDelegate {
    func groupToggled(eventGroup: SubcategoryResponseResult) {
        if expandedGroups.contains(eventGroup.id) {
            expandedGroups.remove(eventGroup.id)
        } else {
            expandedGroups.insert(eventGroup.id)
        }
        update()
    }

    func eventSelected(event: ExperienceIndexResponseResult) {
        navigator.navigate(to: GuestEventScreen.self, argument: event)
    }
}

extension GuestHomeScreen: PWelcomePopupDelegate {
    func closeWelcomePopup(popup: WelcomePopup) {
        popup.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "wythyou.welcome.shown")
    }

    func openProfileScreen() {
        navigator.navigate(to: ProfileScreen.self)
    }
}
