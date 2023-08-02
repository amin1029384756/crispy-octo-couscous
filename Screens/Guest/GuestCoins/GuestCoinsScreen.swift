import UIKit

class GuestCoinsScreen: Screen<GuestCoinsLayout> {
    var selection: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
        switch User.active?.coinsUsage {
        case .merchandise:
            selection = 0

        case .discounts:
            selection = 1

        case .crypto:
            selection = 2

        default:
            selection = nil
        }

        layout.show(selection: selection, changeable: User.active?.coinsUsage == nil)

        if selection != nil {
            loader.show()
            Task {
                do {
                    let stats = try await KtorGetStatsCoinsUsages()
                        .performDataRequest()
                    await MainActor.run {
                        loader.dismiss()
                        show(stats: stats)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        layout.coinBalanceLabel.text = "\(User.active?.coins ?? 0) Coins"
    }

    func submit() {
        guard let selection = selection else { return }

        let coinsUsage: CoinsUsage
        switch selection {
        case 0:
            coinsUsage = CoinsUsage.merchandise

        case 1:
            coinsUsage = CoinsUsage.discounts

        case 2:
            coinsUsage = CoinsUsage.crypto

        default:
            return
        }

        layout.show(selection: selection, changeable: false)
        loader.show()

        Task {
            do {
                try await KtorSubmitCoinsUsage(coinsUsage: coinsUsage)
                    .performRequest()
                User.active?.coinsUsage = coinsUsage

                let stats = try await KtorGetStatsCoinsUsages()
                    .performDataRequest()
                await MainActor.run {
                    loader.dismiss()
                    show(stats: stats)
                }
            } catch {
                await MainActor.run {
                    loader.dismiss()
                    show(error: error.localizedDescription)
                }
            }
        }
    }

    private func show(stats: KtorGetStatsCoinsResponse) {
        layout.show(
            merchandiseCount: stats.merchandiseCount,
            discountsCount: stats.discountsCount,
            cryptoCount: stats.cryptoCount
        )
    }
}
