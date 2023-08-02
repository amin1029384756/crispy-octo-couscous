import UIKit

class HostPanelScreen: Screen<HostPanelLayout> {
    lazy var adapter = HostPanelExperiencesAdapter()

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self

        adapter.delegate = self
        adapter.swipeView = layout.svExperiences
        adapter.pageIndicatorView = layout.pageIndicatorView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadExperiences()
    }

    private func loadExperiences() {
        guard let activeUser = User.active else {
            Task {
                await User.logOut()
                await MainActor.run {
                    navigator.popToRoot()
                }
            }
            return
        }

        loader.showIfNot()
        Task {
            var events = [ExperienceIndexResponseResult]()
            var errorOccurred = false
            do {
                let response = try await ExperienceIndexRequest(type: .host)
                    .performRequest()

                events = response.result.data ?? []

                for idx in events.indices {
                    if let medias = events[idx].medias,
                       !medias.isEmpty {
                        var mediasResolved = medias
                        for mediaIdx in mediasResolved.indices {
                            do {
                                try await mediasResolved[mediaIdx].resolveUrl()
                            } catch {
                                // No action required
                            }
                        }
                        events[idx].medias = mediasResolved
                    }
                }
            } catch {
                // No action required
                errorOccurred = true
            }

            await MainActor.run {
                loader.dismiss()
                adapter.setData(experiences: events)

                if !activeUser.profile.isComplete {
                    navigator.navigate(to: ProfileScreen.self)
                } else if activeUser.profile.quiz != true {
                    navigator.navigate(to: HostToDoListScreen.self)
                } else if events.isEmpty, !errorOccurred {
                    navigator.navigate(to: HostBecome1Screen.self)
                }
            }
        }
    }

    func addANewExperience() {
        navigator.navigate(to: HostBecome2Screen.self)
    }
}

extension HostPanelScreen: HostPanelExperienceViewDelegate {
    func edit(experience: ExperienceIndexResponseResult) {
        navigator.navigate(
            to: HostBecome2Screen.self,
            argument: HostBecome2Arguments(updatingExperience: experience)
        )
    }

    func share(experience: ExperienceIndexResponseResult) {
        if let shareUrl = experience.shareUrl,
           let url = URL(string: shareUrl) {
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [url], applicationActivities: nil)

            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = layout.svExperiences

            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

            // Pre-configuring activity items
            activityViewController.activityItemsConfiguration = [
                UIActivity.ActivityType.message
            ] as? UIActivityItemsConfigurationReading

            activityViewController.isModalInPresentation = true
            present(activityViewController, animated: true, completion: nil)
        }
    }

    func delete(experience: ExperienceIndexResponseResult) {
        let alert = UIAlertController(title: "Are you sure?", message: "Experience will be permanently deleted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteConfirmed(experience: experience)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func deleteConfirmed(experience: ExperienceIndexResponseResult) {
        loader.show()
        ExperienceDeleteRequest(experienceId: experience.id)
            .performRequestWithDelegate { [weak self] response, error in
            guard let self = self else { return }
            if let error = error {
                self.loader.dismiss()
                self.show(error: error.localizedDescription)
                return
            }

            let success = response?.result.data?.status == true
            if !success {
                self.loader.dismiss()
                let message = response?.result.data?.message ?? "Unknown error"
                self.show(error: message)
                return
            }

            self.loadExperiences()
        }
    }
}
