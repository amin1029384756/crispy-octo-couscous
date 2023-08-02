import Foundation
import PayPalCheckout

extension AppDelegate {
    func initializePayPal() {
        #if DEBUG
        let payPalKey = ApiKeys.payPalDebug
        let payPalEnvironment = Environment.sandbox
        #else
        let payPalKey = ApiKeys.payPalRelease
        let payPalEnvironment = Environment.live
        #endif

        let config = CheckoutConfig(
            clientID: payPalKey,
            returnUrl: "com.wythyou.ios://paypalpay",
            environment: payPalEnvironment
        )

        Checkout.set(config: config)
    }
}
