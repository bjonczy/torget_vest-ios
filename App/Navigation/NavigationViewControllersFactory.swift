import UIKit
import Parking
import Web
import iOSKit
import Articles
import Navigation
import OpeningHours
import Shops
import Identity
import Offers

public class NavigationViewControllersFactory: AbstractNavigationViewControllerFactory {
    
    public private(set) var plist: NavigationPlist
    
    public init(plist: NavigationPlist) {
        self.plist = plist
    }

    public func make(withScreenName screenName: String, arguments: PushParameters?) -> UIViewController? {
        
		var viewController: UIViewController?
        let items = plist.items.filter { $0.screenName == screenName || $0.registeredSlugs.contains(screenName) }
        if items.isEmpty {
            Logger.shared.error("Screen name: \(screenName) is not defined in any item in Navigation.plist")
            return nil
        }
        let navigationItem = items[0]
        
        switch navigationItem.component {
        case _ where navigationItem.component.contains("articles"):
            let component = ComponentFactory.shared.make(.articles, name: navigationItem.component) as! ArticlesComponent
            viewController = UIStoryboard.articlesRootViewController(with: component, arguments: arguments)
        case "offers":
            let component = ComponentFactory.shared.make(.offers) as! OffersComponent
            viewController = UIStoryboard.offersViewController(component: component, arguments: arguments)
        case "profile":
            let component = ComponentFactory.shared.make(.identity) as! IdentityComponent
            viewController = UIStoryboard.profileRootViewController(with: component, arguments: arguments)
        case "authentication":
            let component = ComponentFactory.shared.make(.identity) as! IdentityComponent
            viewController = UIStoryboard.identityRootViewController(with: component, arguments: arguments, screenName: screenName)
        case "memberCard":
            let component = ComponentFactory.shared.make(.identity) as! IdentityComponent
            viewController = UIStoryboard.memberCardRootViewController(with: component)
        case "openingHours":
            let component = ComponentFactory.shared.make(.openingHours) as! OpeningHoursComponent
            viewController = UIStoryboard.openingHoursRootViewController(with: component)
        case _ where navigationItem.component.contains("web"):
            let component = ComponentFactory.shared.make(.webpage, name: navigationItem.screenName) as! WebComponent
            viewController = UIStoryboard.webRootViewController(with: component)
        case "shops":
            let component = ComponentFactory.shared.make(.shops) as! ShopsComponent
            viewController = UIStoryboard.shopsRootViewController(with: component)
        case "events":
            let component = ComponentFactory.shared.make(.events) as! EventsComponent
            viewController = UIStoryboard.articlesRootViewController(with: component, arguments: arguments)
        case "parking":
            let component = ComponentFactory.shared.make(.parking) as! ParkingComponent
            viewController = UIStoryboard.parkingViewController(component: component)
        case "games":
            let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
            let webComponent = ComponentFactory.shared.make(.webpage) as! AbstractWebComponent
            let component = CustomWebComponent(with: webComponent,
                                               router: AppRouter.self,
                                               userSession: UserSession.sharedSession,
                                               type: .games)
            viewController = UIStoryboard.customWebViewController(with: component,
                                                              authManager: AuthManager(component: identityComponent))
        default:
            viewController = nil
        }
		return viewController
	}
    
    public func viewController(named name: String, with arguments: PushParameters?) -> UIViewController? {
        return make(withScreenName:name, arguments: arguments)
    }
}
