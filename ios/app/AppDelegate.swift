//
// Copyright (c) 2024 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import GraphQLite
import ProgressHUD
import PasscodeKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var tabBarController: UITabBarController!

	var directsView: DirectsView!
	var channelsView: ChannelsView!
	var settingsView: SettingsView!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

		//---------------------------------------------------------------------------------------------------------------------------------------
		// Backend initialization
		//---------------------------------------------------------------------------------------------------------------------------------------
		Backend.setup()

		//---------------------------------------------------------------------------------------------------------------------------------------
		// Push notification initialization
		//---------------------------------------------------------------------------------------------------------------------------------------
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, error in
			if (error == nil) {
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
				}
			}
		})

		//---------------------------------------------------------------------------------------------------------------------------------------
		// UI initialization
		//---------------------------------------------------------------------------------------------------------------------------------------
		window = UIWindow(frame: UIScreen.main.bounds)

		directsView = DirectsView(nibName: "DirectsView", bundle: nil)
		channelsView = ChannelsView(nibName: "ChannelsView", bundle: nil)
		settingsView = SettingsView(nibName: "SettingsView", bundle: nil)

		let navController1 = NavigationController(rootViewController: directsView)
		let navController2 = NavigationController(rootViewController: channelsView)
		let navController3 = NavigationController(rootViewController: settingsView)

		tabBarController = UITabBarController()
		tabBarController.tabBar.isTranslucent = false
		tabBarController.tabBar.tintColor = AppColor.main
		tabBarController.delegate = self
		tabBarController.viewControllers = [navController1, navController2, navController3]
		tabBarController.selectedIndex = Appx.DefaultTab

		if #available(iOS 15.0, *) {
			let appearance = UITabBarAppearance()
			appearance.configureWithOpaqueBackground()
			tabBarController.tabBar.standardAppearance = appearance
			tabBarController.tabBar.scrollEdgeAppearance = appearance
		}

		window?.rootViewController = tabBarController
		window?.makeKeyAndVisible()

		_ = directsView.view
		_ = channelsView.view
		_ = settingsView.view

		//---------------------------------------------------------------------------------------------------------------------------------------
		// UITableView padding
		//---------------------------------------------------------------------------------------------------------------------------------------
		if #available(iOS 15.0, *) {
			UITableView.appearance().sectionHeaderTopPadding = 0
		}

		//---------------------------------------------------------------------------------------------------------------------------------------
		// PasscodeKit initialization
		//---------------------------------------------------------------------------------------------------------------------------------------
		PasscodeKit.delegate = self
		PasscodeKit.start()

		//---------------------------------------------------------------------------------------------------------------------------------------
		// ProgressHUD initialization
		//---------------------------------------------------------------------------------------------------------------------------------------
		ProgressHUD.colorProgress = AppColor.main
		ProgressHUD.colorAnimation = AppColor.main

		return true
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillResignActive(_ application: UIApplication) {

		NotificationCenter.post(Notifications.AppWillResign)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationDidEnterBackground(_ application: UIApplication) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillEnterForeground(_ application: UIApplication) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationDidBecomeActive(_ application: UIApplication) {

		Media.cleanupExpired()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillTerminate(_ application: UIApplication) {

	}

}

// MARK: - PasscodeKitDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: PasscodeKitDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func passcodeCheckedButDisabled() {

		NotificationCenter.post(Notifications.AppStarted)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func passcodeEnteredSuccessfully() {

		NotificationCenter.post(Notifications.AppStarted)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func passcodeMaximumFailedAttempts() {

		ProgressHUD.animate(interaction: false)
		Users.logout() {
			DispatchQueue.main.async(after: 1.0) {
				exit(0)
			}
		}
	}
}

// MARK: - UITabBarControllerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: UITabBarControllerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {

		return .portrait
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation {

		return .portrait
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

		return (viewController != tabBarController.selectedViewController)
	}
}
