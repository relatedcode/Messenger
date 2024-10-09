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
class Users {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func login(_ viewController: UIViewController) {

		let welcomeView = WelcomeView()
		welcomeView.isModalInPresentation = true
		welcomeView.modalPresentationStyle = .fullScreen
		viewController.present(welcomeView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func loggedIn() {

		ProgressHUD.succeed("Welcome back!")

		NotificationCenter.post(Notifications.UserLoggedIn)
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func logout(_ completion: @escaping () -> Void) {

		NotificationCenter.post(Notifications.UserWillLogout)

		Media.cleanupManual(logout: true)

		PasscodeKit.remove()

		gqldb.cleanupDatabase()

		Workspace.cleanup()
		LastUpdated.cleanup()

		GQLAuth.logout { error in
			if let error = error {
				print(error.localizedDescription)
			}
			completion()
		}
	}
}
