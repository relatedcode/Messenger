//
// Copyright (c) 2021 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import CoreSpotlight
import ProgressHUD
import PasscodeKit
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Users: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func login(_ viewController: UIViewController) {

		let welcomeView = WelcomeView()
		welcomeView.isModalInPresentation = true
		welcomeView.modalPresentationStyle = .fullScreen
		viewController.present(welcomeView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func onboard(_ viewController: UIViewController) {

		let editProfileView = EditProfileView(onboard: true)
		let navController = NavigationController(rootViewController: editProfileView)
		navController.isModalInPresentation = true
		navController.modalPresentationStyle = .fullScreen
		viewController.present(navController, animated: true)
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func loggedIn() {

		Shortcut.create()

		if (DBUsers.fullname() != "") {
			ProgressHUD.showSucceed("Welcome back!")
		} else {
			ProgressHUD.showSucceed("Welcome!")
		}

		NotificationCenter.post(Notifications.UserLoggedIn)

		DispatchQueue.main.async(after: 0.5) {
			DBUsers.updateActive()
		}

		GQLPush.register(GQLAuth.userId())
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func prepareLogout() {

		GQLPush.unregister()

		DBUsers.updateTerminate()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func performLogout() {

		NotificationCenter.post(Notifications.UserLoggedOut)

		Media.cleanupManual(logout: true)

		PasscodeKit.remove()

		gqldb.cleanupDatabase()
		gqlsync.cleanup()

		LastUpdated.cleanup()

		CSSearchableIndex.default().deleteAllSearchableItems()

		Shortcut.cleanup()

		GQLAuth.signOut()
	}
}
