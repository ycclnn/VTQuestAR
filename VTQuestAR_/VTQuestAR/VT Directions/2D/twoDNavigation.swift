
import SwiftUI
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
struct twoDNavigation: UIViewControllerRepresentable {
    
    /// Mapbox direction route
    @Binding var directionsRoute: Route?
    
    /// Mapbox direction options
    @Binding var options: RouteOptions?
    
    /// show/hide the navigation view popover
    @Binding var showNavigation: Bool
    
    /// 0 means start from current locaion, 1 means from a building
    @Binding var startFromCurrentLoc: Int
    
    func makeCoordinator() -> twoDNavigation.Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<twoDNavigation>) -> NavigationViewController {
        
        /// set up navigation service and UI styles
        let navigationService = MapboxNavigationService(route: directionsRoute!, routeOptions: options!, simulating: .never)
        navigationService.router.reroutesProactively = false
        let navigationOptions = NavigationOptions(styles: [CustomDayStyle(), CustomNightStyle()], navigationService: navigationService)
        
        let navigationViewController = NavigationViewController(for: directionsRoute!, routeOptions: options!, navigationOptions: navigationOptions)
        navigationViewController.automaticallyAdjustsStyleForTimeOfDay = true
        
        navigationViewController.delegate = context.coordinator
        return navigationViewController
    }
    
    func updateUIViewController(_ uiViewController: NavigationViewController, context: UIViewControllerRepresentableContext<twoDNavigation>) {
        // do nothing
    }
    
    class Coordinator: NSObject, NavigationViewControllerDelegate {
        var control: twoDNavigation
        
        //connect the coordinator with the parent control representable
        init(_ control: twoDNavigation) {
            self.control = control
        }
        
        
        func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
            self.control.showNavigation = false
        }
       
        func navigationViewController(_ navigationViewController: NavigationViewController, shouldRerouteFrom location: CLLocation) -> Bool {
            // if navigation origin is current location, turn on the reroute option is needed.
            if self.control.startFromCurrentLoc == 0 {
                return true
            }
            //else, turn off the reroute option
            else {
                return false
            }
        }
    }
}
//UI style during the day
class CustomDayStyle: DayStyle {
    
    required init() {
        super.init()
//
//        // Use a custom map style.
//        mapStyleURL = MGLStyle.outdoorsStyleURL
//        previewMapStyleURL = MGLStyle.outdoorsStyleURL

        // Specify that the style should be used during the day.
        styleType = .day
    }
    
    override func apply() {
        super.apply()

        // Begin styling the UI
        BottomBannerView.appearance().backgroundColor = .lightGray
    }
}
//UI style at night
class CustomNightStyle: NightStyle {
    
    required init() {
        super.init()

        // Specify that the style should be used at night.
        styleType = .night
    }

    override func apply() {
        super.apply()

        // Begin styling the UI
        BottomBannerView.appearance().backgroundColor = .purple
    }
}
