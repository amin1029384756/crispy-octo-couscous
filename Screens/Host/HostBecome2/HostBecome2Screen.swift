import UIKit

class HostBecome2Screen: ScreenWithInput<HostBecome2Layout, HostBecome2Arguments> {
    private var updatingExperience: ExperienceIndexResponseResult?

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self

        layout.show(categories: Cat.list)
    }

    override func input(_ argument: HostBecome2Arguments) {
        updatingExperience = argument.updatingExperience

        if let experience = updatingExperience {
            for cat in Cat.list {
                if cat.subcategories.contains(where: {
                    $0.id == experience.category_id
                }) {
                    layout.selectedCategory = cat
                    layout.selectedSubcategory = cat.subcategories.first {
                        $0.id == experience.category_id
                    }
                }
            }
            layout.show(categories: Cat.list)
        }
    }

    func goNext(selectedCategory: CategoryResponseResult?,
                selectedSubcategory: SubcategoryResponseResult?) {
        if let selectedCategory = selectedCategory,
           let selectedSubcategory = selectedSubcategory {
            navigator.navigate(
                to: HostBecome3Screen.self,
                argument: HostBecome3Arguments(
                    category: selectedCategory,
                    subcategory: selectedSubcategory,
                    updatingExperience: updatingExperience
                )
            )
        } else {
            show(warning: "Select a category")
        }
    }
}
