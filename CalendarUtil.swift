import Foundation
import AppAuth
import GTMAppAuth
import GoogleAPIClientForREST

// https://www.linuxtut.com/en/a86dad766448414467a6/
class CalendarUtil {
    private var authorization: GTMAppAuthFetcherAuthorization?
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    private let clientID = "1097894451172-i3u7us3064vfm9q6vul8ma0cnjt98i14.apps.googleusercontent.com"
    private let reverseClientID = "com.googleusercontent.apps.1097894451172-i3u7us3064vfm9q6vul8ma0cnjt98i14"
    typealias showAuthorizationDialogCallBack = (Error?) -> Void

    private func showAuthorizationDialog(delegate: @escaping showAuthorizationDialogCallBack) {
        let scopes = [
            "https://www.googleapis.com/auth/calendar.events"
        ]

        let configuration = GTMAppAuthFetcherAuthorization.configurationForGoogle()
        let redirectURL = URL(string: reverseClientID + ":/oauthredirect")!

        let request = OIDAuthorizationRequest(configuration: configuration,
            clientId: clientID,
            scopes: scopes,
            redirectURL: redirectURL,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil)

        let topViewController = UIApplication.shared.getTopViewController()!

        currentAuthorizationFlow = OIDAuthState.authState(
            byPresenting: request,
            presenting: topViewController,
            callback: { (authState, error) in
                if let error = error {
                    NSLog("\(error)")
                } else {
                    if let authState = authState {
                        self.authorization = GTMAppAuthFetcherAuthorization.init(authState: authState)
                        GTMAppAuthFetcherAuthorization.save(self.authorization!, toKeychainForName: "authorization")
                    }
                }
                delegate(error)
            })
    }

    var calendarService: GTLRCalendarService = {
        let service = GTLRCalendarService()
        service.isRetryEnabled = true
        service.shouldFetchNextPages = true
        return service
    }()

    func createEvent(eventName: String, startDateTime: Date, endDateTime: Date,
                     delegate: @escaping (_ meetLink: String?, _ error: Error?) -> Void) {
        if GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization") != nil {
            authorization = GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization")!
        }

        guard let authorization = authorization else {
            showAuthorizationDialog { (error) -> Void in
                if error == nil {
                    self.createEvent(
                        eventName: eventName, startDateTime: startDateTime,
                        endDateTime: endDateTime, delegate: delegate)
                } else {
                    delegate(nil, error)
                }
            }
            return
        }

        calendarService.authorizer = authorization

        let event = GTLRCalendar_Event()
        event.summary = eventName

        let gtlrDateTimeStart: GTLRDateTime = GTLRDateTime(date: startDateTime)
        let startEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
        startEventDateTime.dateTime = gtlrDateTimeStart
        event.start = startEventDateTime

        let gtlrDateTimeEnd: GTLRDateTime = GTLRDateTime(date: endDateTime)
        let endEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
        endEventDateTime.dateTime = gtlrDateTimeEnd
        event.end = endEventDateTime

        let conferenceSolutionKey = GTLRCalendar_ConferenceSolutionKey()
        conferenceSolutionKey.type = "hangoutsMeet"

        let conferenceRequest = GTLRCalendar_CreateConferenceRequest()
        conferenceRequest.requestId = UUID().uuidString
        conferenceRequest.conferenceSolutionKey = conferenceSolutionKey

        let entryPoint = GTLRCalendar_EntryPoint()
        entryPoint.entryPointType = "video"

        let conferenceData = GTLRCalendar_ConferenceData()
        conferenceData.createRequest = conferenceRequest
        conferenceData.entryPoints = [entryPoint]

        event.conferenceData = conferenceData

        let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
        query.conferenceDataVersion = 1
        calendarService.executeQuery(query, completionHandler: { (ticket, event, error) -> Void in
            if let error = error {
                delegate(nil, error)
            } else {
                let eventObject = event as? GTLRObject
                let link = eventObject?.jsonValue(forKey: "hangoutLink") as? String
                delegate(link, nil)
            }
        })
    }

    static let shared = CalendarUtil()
}
