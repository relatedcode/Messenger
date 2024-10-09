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
class SettingsView: UITableViewController {

	@IBOutlet private var viewHeader: UIView!
	@IBOutlet private var imageUser: UIImageView!
	@IBOutlet private var labelInitials: UILabel!
	@IBOutlet private var labelName: UILabel!

	@IBOutlet private var cellProfile: UITableViewCell!
	@IBOutlet private var cellPassword: UITableViewCell!
	@IBOutlet private var cellPasscode: UITableViewCell!

	@IBOutlet private var cellCache: UITableViewCell!
	@IBOutlet private var cellMedia: UITableViewCell!

	@IBOutlet private var cellPrivacy: UITableViewCell!
	@IBOutlet private var cellTerms: UITableViewCell!

	@IBOutlet private var cellLogout: UITableViewCell!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName: String?, bundle: Bundle?) {

		super.init(nibName: nibName, bundle: bundle)

		tabBarItem.image = UIImage(systemName: "gearshape")
		tabBarItem.title = "Settings"

		NotificationCenter.addObserver(self, selector: #selector(actionCleanup), text: Notifications.UserWillLogout)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		fatalError()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Settings"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		tableView.tableHeaderView = viewHeader
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		if (GQLAuth.userId() != "") {
			loadUser()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		if (GQLAuth.userId() != "") {
			if (Workspace.id() != "") {

			} else { Workspace.select(self) }
		} else { Users.login(self) }
	}
}

// MARK: - Database methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SettingsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func loadUser() {

		guard let dbuser = DBUser.fetchOne(gqldb, key: GQLAuth.userId()) else { return }

		labelInitials.text = dbuser.initials()
		MediaDownload.user(dbuser.photoURL) { [weak self] image, later in
			guard let self = self else { return }
			if let image = image {
				imageUser.image = image.square(to: 70)
				labelInitials.text = nil
			}
		}

		labelName.text = dbuser.fullName

		cellPasscode.detailTextLabel?.text = PasscodeKit.enabled() ? "On" : "Off"

		tableView.reloadData()
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SettingsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionProfile() {

		let editProfileView = EditProfileView()
		let navController = NavigationController(rootViewController: editProfileView)
		navController.isModalInPresentation = true
		navController.modalPresentationStyle = .fullScreen
		present(navController, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionPassword() {

		let passwordView = PasswordView()
		let navController = NavigationController(rootViewController: passwordView)
		navController.isModalInPresentation = true
		navController.modalPresentationStyle = .fullScreen
		present(navController, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionPasscode() {

		let passcodeView = PasscodeView()
		passcodeView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(passcodeView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionCache() {

		let cacheView = CacheView()
		cacheView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(cacheView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionMedia() {

		let mediaView = MediaView()
		mediaView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(mediaView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionPrivacy() {

		let privacyView = PrivacyView()
		privacyView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(privacyView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionTerms() {

		let termsView = TermsView()
		termsView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(termsView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionLogout() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.action("Log out", .destructive) { _ in
			self.actionLogoutUser()
		}
		alert.actionCancel()

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionLogoutUser() {

		ProgressHUD.animate(interaction: false)
		DispatchQueue.main.async(after: 0.5) {
			Users.logout() {
				ProgressHUD.dismiss()
				self.tabBarController?.selectedIndex = Appx.DefaultTab
			}
		}
	}
}

// MARK: - Cleanup methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SettingsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		imageUser.image = nil
		labelName.text = nil
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SettingsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return 4
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 3 }
		if (section == 1) { return 2 }
		if (section == 2) { return 2 }
		if (section == 3) { return 1 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellProfile	}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellPassword	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellPasscode	}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellCache		}
		if (indexPath.section == 1) && (indexPath.row == 1) { return cellMedia		}
		if (indexPath.section == 2) && (indexPath.row == 0) { return cellPrivacy	}
		if (indexPath.section == 2) && (indexPath.row == 1) { return cellTerms		}
		if (indexPath.section == 3) && (indexPath.row == 0) { return cellLogout		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension SettingsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 0) { actionProfile()	}
		if (indexPath.section == 0) && (indexPath.row == 1) { actionPassword()	}
		if (indexPath.section == 0) && (indexPath.row == 2) { actionPasscode()	}
		if (indexPath.section == 1) && (indexPath.row == 0) { actionCache()		}
		if (indexPath.section == 1) && (indexPath.row == 1) { actionMedia()		}
		if (indexPath.section == 2) && (indexPath.row == 0) { actionPrivacy()	}
		if (indexPath.section == 2) && (indexPath.row == 1) { actionTerms()		}
		if (indexPath.section == 3) && (indexPath.row == 0) { actionLogout()	}
	}
}
