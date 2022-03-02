import UIKit
import Identity
import WelcomePages
import Analytics
import iOSKit
import Navigation
import Pushr
import OpeningHours
import vcs
import iOSKit
import Translations
import PluggableAppDelegate

@UIApplicationMain
open class AppDelegate: iOSKitPluggableApplicationDelegate, WindowProvider {
    
    open override func setupServices() -> [ApplicationService] {
        let ioskit = iOSKitApplicationServiceProvider().services
        
        let identityComponent = ComponentFactory.shared.make(.identity) as! IdentityComponent
        let navigationComponent = ComponentFactory.shared.make(.navigation) as! NavigationComponent
        let pushrComponent = ComponentFactory.shared.make(.pushr) as! PushrComponent
        let dlComponent = ComponentFactory.shared.make(.deepLinking) as! DLComponent
        
        let identity = IdentityApplicationServiceProvider(component: identityComponent).services
        let navigation = NavigationApplicationServiceProvider(component: navigationComponent, windowProvider: self).services
        
        let pushr = PushrApplicationServiceProvider(
            component: pushrComponent,
            session: UserSession.sharedSession,
            dlComponent: dlComponent,
            router: AppRouter.self
            ).services
        
        let analytics = AnalyticsApplicationServiceProvider(tracker: _DMPTracker.shared).services
        let vcs = VCSApplicationServiceProvider(vcs: ComponentFactory.shared.make(.vcs) as! VCS).services
        let forceUpdate = ForceUpdateApplicationServiceProvider(component: identityComponent).services
        return [ioskit, navigation, identity, pushr, analytics, vcs, forceUpdate].flatMap { $0 }
    }
}
