import Foundation
import YandexMobileMetrica


struct AnalyticsService {
    static func initMetrica() -> Bool {
        guard
            let configuration = YMMYandexMetricaConfiguration(apiKey: "d85dac36-8e25-4a69-95f5-9e31516b1af0")
        else {
            return false
        }
        
        YMMYandexMetrica.activate(with: configuration)
        return true
    }
    
    static func trackEvent(_ analyticsEvent: AnalyticsEvent) {
        var params: [String: Any] = ["screen": analyticsEvent.screen.rawValue]
        if let item = analyticsEvent.item {
            params["item"] = item.rawValue
        }
        
        YMMYandexMetrica.reportEvent(analyticsEvent.event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
