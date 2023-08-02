import UIKit

class HostPanelExperiencesAdapter: NSObject,
    SwipeViewDataSource, SwipeViewDelegate, PageIndicatorViewDelegate {
    weak var swipeView: SwipeView?
    weak var pageIndicatorView: PageIndicatorView?
    weak var delegate: HostPanelExperienceViewDelegate?

    var experiences = [ExperienceIndexResponseResult]()

    func setData(experiences: [ExperienceIndexResponseResult]) {
        self.experiences = experiences

        swipeView?.delegate = self
        swipeView?.dataSource = self

        pageIndicatorView?.delegate = self
        pageIndicatorView?.set(page: 0, pages: experiences.count)

        swipeView?.reloadData()
    }

    func numberOfItems(in swipeView: SwipeView!) -> Int {
        experiences.count
    }

    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        let experienceView = (view as? HostPanelExperienceView) ??
            HostPanelExperienceView(experience: nil, delegate: nil, isReady: true)

        let experience = experiences[index]
        experienceView.set(experience: experience, thumb: nil, delegate: delegate)

        return experienceView
    }

    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        let index = swipeView.currentItemIndex
        pageIndicatorView?.set(page: index, pages: experiences.count)
    }

    func swipeViewItemSize(_ swipeView: SwipeView!) -> CGSize {
        swipeView.bounds.size
    }

    func pageSelected(idx: Int) {
        swipeView?.scroll(toPage: idx, duration: 0.3)
    }
}
