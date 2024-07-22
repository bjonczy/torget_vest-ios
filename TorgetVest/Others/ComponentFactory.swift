import Foundation
import Web
import Identity
import Articles
import OpeningHours
import vcs
import Navigation
import iOSKit
import Analytics
import Shops
import Pushr
import WelcomePages
import Offers
import Parking
import Games
import Cars
import NotificationCenter

public enum ComponentFactoryInputType {
    case identity
	case articles
    case parking
    case events
	case welcomePages
	case iOSKit
	case navigation
	case deepLinking
    case openingHours
    case shops
    case pushr
    case vcs
    case webpage
    case offers
    case games
    case cars
    case notificationCenter
}

public protocol ReusableComponent: AnyObject {
	func prepareForReuse()
}

class ComponentFactory {

    private var instances: [ComponentFactoryInputType: AnyObject] = [:]
    fileprivate(set) var allowForMultipuleInstanceOfSingleClass = false
    static let shared = ComponentFactory(allowForMultipuleInstanceOfSingleClass: false)
    
    public init(allowForMultipuleInstanceOfSingleClass: Bool) {
        self.allowForMultipuleInstanceOfSingleClass = allowForMultipuleInstanceOfSingleClass
    }

    public func make(_ type: ComponentFactoryInputType, name: String? = nil) -> AnyObject {
        if allowForMultipuleInstanceOfSingleClass {
            return create(with: type)
		} else if let cachedObject = cached(with: type) {
            return cachedObject
        } else {
            let object = create(with: type, name: name)
            if type != .webpage && type != .articles {
                instances[type] = object
            }
            return object
        }
    }

    public func create(with type: ComponentFactoryInputType, name: String? = nil) -> AnyObject {
        switch type {
        case .identity:
            let behaviours = IdentityBehaviours(applicationService: UIApplication.shared.delegate as! AuthenticationApplicationService)
            behaviours.customSectionsActions = ["license_plate": {
                AppRouter.shared.navigate(to: "prk", with: nil)
            }]
            behaviours.hideRegistrationFormItemTypes = [FormItemType.licensePlate]
            
            let component = IdentityComponent(
                behaviours: behaviours,
                router: AppRouter.self,
                analytics: IdentityAnalytics(tracker: _DMPTracker.shared),
                iosKitComponent: ComponentFactory.shared.make(.iOSKit) as! iOSKitComponent,
                identifierType: .msisdn
            )
            
            return component
        case .offers:
            let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
            let iosKitComponent = ComponentFactory.shared.make(.iOSKit) as! iOSKitComponent
            let behaviours = OffersBehaviours(router: AppRouter.self)
            return OffersComponent(
                authManager: AuthManager(component: identityComponent),
                behaviours: behaviours,
                analytics: OffersAnalytics(tracker: _DMPTracker.shared),
                iosKitComponent: iosKitComponent,
                errorBehaviours: ErrorBehaviours(logoutOperation: LogoutOperation(component: identityComponent)),
                router: AppRouter.self,
                deepLinkHandler: DeepLinker(router: AppRouter.self, component: ComponentFactory.shared.make(.deepLinking) as! DLComponent)
            )
        case .articles:
            let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
            return ArticlesComponent(
                name: name,
                router: AppRouter.self,
                credentialsType: .scrapper,
                errorBehaviours: ErrorBehaviours(logoutOperation: LogoutOperation(component: identityComponent)),
                authManager: AuthManager(component: identityComponent)
            )
        case .events:
            let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
            return EventsComponent(
                name: "events",
                router: AppRouter.self,
                credentialsType: .scrapper,
                errorBehaviours: ErrorBehaviours(logoutOperation: LogoutOperation(component: identityComponent)),
                authManager: AuthManager(component: identityComponent)
            )
		case .welcomePages:
            return WelcomePagesComponent(analytics: WelcomePagesAnalytics(tracker: _DMPTracker.shared))
		case .iOSKit:
            return iOSKitComponent(
                session: UserSession.sharedSession,
                behaviours: iOSKitBehaviours(router: AppRouter.self)
            )
        case .navigation:
            let subcomponents = NavigationSubComponents(
                ioskitComponent:        self.create(with: .iOSKit) as! iOSKitComponent,
                identityComponent:      self.create(with: .identity) as! IdentityComponent,
                welcomePagesComponent:  self.create(with: .welcomePages) as! WelcomePagesComponent,
                notificationCenterComponent: self.create(with: .notificationCenter) as? NotificationCenterComponent
            )
            let behaviours = NavigationBehaviours(
                factory: NavigationViewControllersFactory(plist: NavigationPlist()),
                hasDynamicGames: true
            )
            let component = NavigationComponent(
                plist: NavigationPlist(),
                session: UserSession.sharedSession,
                subComponents: subcomponents,
                behaviours: behaviours
            )
            component.delegate = self

            return component
		case .deepLinking:
            return DLComponent(analytics: DLAnalytics(tracker: _DMPTracker.shared))
        case .openingHours:
            return OpeningHoursComponent(
                credentialsType: .scrapper,
                errorBehaviours: ErrorBehaviours(logoutOperation: LogoutOperation(component: ComponentFactory.shared.make(.identity) as! IdentityComponent))
            )
        case .shops:
            let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
            let authManager = AuthManager(component: identityComponent)
            return ShopsComponent(
                analytics: ShopsAnalytics(tracker: _DMPTracker.shared),
                router: AppRouter.self,
                errorBehaviours: ErrorBehaviours(logoutOperation: LogoutOperation(component: identityComponent)),
                authManager: authManager
            )
        case .pushr:
            let dlComponent = ComponentFactory.shared.make(.deepLinking) as! DLComponent
            return PushrComponent(
                analytics: PushrAnalytics(tracker: _DMPTracker.shared),
                userSession: UserSession.sharedSession,
                router: AppRouter.self,
                deepLinkHandler: DeepLinker(router: AppRouter.self, component: dlComponent)
                )

        case .vcs:
            return VCS(component: VCSComponent())
        case .webpage:
            return WebComponent(
                name: name,
                analytics: WebAnalytics(tracker: _DMPTracker.shared, slug: name ?? ""),
                errorBehaviours: ErrorBehaviours(logoutOperation: LogoutOperation(component: ComponentFactory.shared.make(.identity) as! IdentityComponent)),
                deepLinkHandler: DeepLinker(router: AppRouter.self, component: ComponentFactory.shared.make(.deepLinking) as! DLComponent),
                router: AppRouter.self
            )
        case .parking:
            let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
            let repository = IdentityParkingRepository(identityComponent: identityComponent)
            return ParkingComponent(repository: repository, router: AppRouter.self)
        case .games:
            let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
            return GamesComponent(
                router: AppRouter.self,
                identityComponent: identityComponent,
                deepLinkHandler: DeepLinker(router: AppRouter.self, component: ComponentFactory.shared.make(.deepLinking) as! DLComponent)
            )
        case .cars:
            let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
            return CarsComponent(
                identityComponent: identityComponent,
                router: AppRouter.self,
                analytics: CarsAnalytics(tracker: _DMPTracker.shared)
            )
        case .notificationCenter:
            let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
            return NotificationCenterComponent(
                identityComponent: identityComponent,
                analytics: NotificationCenterAnalytics(tracker: _DMPTracker.shared),
                deepLinkHandler: DeepLinker(router: AppRouter.self, component: ComponentFactory.shared.make(.deepLinking) as! DLComponent),
                router: AppRouter.self
            )
		}
    }

    private func cached(with type: ComponentFactoryInputType) -> AnyObject? {
        let component = instances[type]
		prepareForReuse(component)
		return component
    }
	
	private func prepareForReuse(_ component: Any?) {
		if let reusableComponent = component as? ReusableComponent {
			reusableComponent.prepareForReuse()
		}
	}
}

extension ComponentFactory: NavigationComponentDelegate {

    func didNavigate(to screenName: String, with arguments: PushParameters?) {
        (make(.notificationCenter) as? NotificationCenterComponent)?.checkNewNotifications()
        (make(.games) as? GamesComponent)?.checkGamesAvailability()
    }

}
