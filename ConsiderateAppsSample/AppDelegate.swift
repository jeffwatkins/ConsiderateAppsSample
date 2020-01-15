//  
//  Copyright © 2020 Jeff Watkins. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        let controller = ViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        window.rootViewController = navigationController

        self.window = window
        window.makeKeyAndVisible()

        return true
    }

}

