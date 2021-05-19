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
import MessageUI
import ProgressHUD

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ProfileView: UIViewController {

	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var viewHeader: UIView!
	@IBOutlet private var imageUser: UIImageView!
	@IBOutlet private var labelInitials: UILabel!
	@IBOutlet private var labelName: UILabel!
	@IBOutlet private var labelDetails: UILabel!

	@IBOutlet private var imageHeader1: UIImageView!
	@IBOutlet private var imageHeader2: UIImageView!
	@IBOutlet private var imageHeader3: UIImageView!
	@IBOutlet private var imageHeader4: UIImageView!
	@IBOutlet private var buttonHeader1: UIButton!
	@IBOutlet private var buttonHeader2: UIButton!
	@IBOutlet private var buttonHeader3: UIButton!
	@IBOutlet private var buttonHeader4: UIButton!

	@IBOutlet private var cellStatus: UITableViewCell!
	@IBOutlet private var cellCountry: UITableViewCell!
	@IBOutlet private var cellLocation: UITableViewCell!
	@IBOutlet private var cellPhone: UITableViewCell!
	@IBOutlet private var cellMedia: UITableViewCell!
	@IBOutlet private var cellFriend: UITableViewCell!
	@IBOutlet private var cellBlock: UITableViewCell!

	private var userId = ""
	private var dbuser: DBUser!

	private var isChatEnabled = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ userId: String, chat: Bool) {

		super.init(nibName: nil, bundle: nil)

		self.userId = userId
		isChatEnabled = chat
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Profile"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		tableView.tableHeaderView = viewHeader

		loadUser()
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func loadUser() {

		let isBlockerUser = DBRelations.isBlocker(userId)
		imageHeader1.tintColor = isChatEnabled ? .systemBlue : .darkGray
		imageHeader2.tintColor = isBlockerUser ? .darkGray : .systemBlue
		imageHeader4.tintColor = isBlockerUser ? .darkGray : .systemBlue
		buttonHeader1.isEnabled = isChatEnabled ? true : false
		buttonHeader2.isEnabled = isBlockerUser ? false : true
		buttonHeader4.isEnabled = isBlockerUser ? false : true

		dbuser = DBUser.fetchOne(gqldb, key: userId)

		labelInitials.text = dbuser.initials()
		MediaDownload.user(dbuser.objectId, dbuser.pictureAt) { image, error in
			if (error == nil) {
				self.imageUser.image = image?.square(to: 70)
				self.labelInitials.text = nil
			}
		}

		labelName.text = dbuser.fullname
		labelDetails.text = dbuser.lastActiveText()

		cellStatus.detailTextLabel?.text = dbuser.status
		cellCountry.detailTextLabel?.text = dbuser.country
		cellLocation.detailTextLabel?.text = dbuser.location
		cellPhone.detailTextLabel?.text = dbuser.phone

		cellFriend.textLabel?.text = DBRelations.isFriend(userId) ? "Remove Friend" : "Add Friend"
		cellBlock.textLabel?.text = DBRelations.isBlocked(userId) ? "Unblock User" : "Block User"

		tableView.reloadData()
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionPhoto(_ sender: Any) {

		if let path = Media.path(userId: userId) {
			if let image = UIImage.image(path, size: 320) {
				let pictureView = PictureView(image: image)
				present(pictureView, animated: true)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHeader1(_ sender: Any) {

		let chatId = DBSingles.create(userId)
		let chatPrivateView = ChatPrivateView(chatId, userId)
		navigationController?.pushViewController(chatPrivateView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHeader2(_ sender: Any) {

		let number1 = "tel://\(dbuser.phone)"
		let number2 = number1.replacingOccurrences(of: " ", with: "")

		if let url = URL(string: number2) {
			if (UIApplication.shared.canOpenURL(url)) {
				UIApplication.shared.open(url)
			} else {
				ProgressHUD.showFailed("Call cannot be initiated.")
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHeader3(_ sender: Any) {

		print(#function)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHeader4(_ sender: Any) {

		let subject = "Subject"
		let message = "Message body"

		if (MFMailComposeViewController.canSendMail()) {
			let mailCompose = MFMailComposeViewController()
			mailCompose.setToRecipients([dbuser.email])
			mailCompose.setSubject(subject)
			mailCompose.setMessageBody(message, isHTML: false)
			mailCompose.mailComposeDelegate = self
			present(mailCompose, animated: true)
		} else {
			let link = "mailto:\(dbuser.email)?subject=\(subject)&body=\(message)"
			if let encoded = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
				if let url = URL(string: encoded) {
					if (UIApplication.shared.canOpenURL(url)) {
						UIApplication.shared.open(url)
					} else {
						ProgressHUD.showFailed("Mail cannot be sent.")
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionMedia() {

		let chatId = DBSingles.chatId(userId)
		let allMediaView = AllMediaView(chatId)
		navigationController?.pushViewController(allMediaView, animated: true)
	}

	// MARK: - User actions (Friend - Unfriend)
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionFriendOrUnfriend() {

		DBRelations.isFriend(userId) ? actionUnfriend() : actionFriend()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionFriend() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Add Friend", style: .default) { action in
			self.actionFriendUser()
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionFriendUser() {

		DBRelations.update(userId, isFriend: true)
		cellFriend.textLabel?.text = "Remove Friend"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnfriend() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Remove Friend", style: .default) { action in
			self.actionUnfriendUser()
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnfriendUser() {

		DBRelations.update(userId, isFriend: false)
		cellFriend.textLabel?.text = "Add Friend"
	}

	// MARK: - User actions (Block - Unblock)
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionBlockOrUnblock() {

		DBRelations.isBlocked(userId) ? actionUnblock() : actionBlock()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionBlock() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Block User", style: .destructive) { action in
			self.actionBlockUser()
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionBlockUser() {

		DBRelations.update(userId, isBlocked: true)
		cellBlock.textLabel?.text = "Unblock User"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnblock() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Unblock User", style: .destructive) { action in
			self.actionUnblockUser()
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnblockUser() {

		DBRelations.update(userId, isBlocked: false)
		cellBlock.textLabel?.text = "Block User"
	}
}

// MARK: - MFMailComposeViewControllerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ProfileView: MFMailComposeViewControllerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

		if (result == MFMailComposeResult.sent) {
			ProgressHUD.showSucceed("Mail sent successfully.")
		}
		controller.dismiss(animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ProfileView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 3
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 4 }
		if (section == 1) { return 1 }
		if (section == 2) { return 2 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellStatus		}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellCountry	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellLocation	}
		if (indexPath.section == 0) && (indexPath.row == 3) { return cellPhone		}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellMedia		}
		if (indexPath.section == 2) && (indexPath.row == 0) { return cellFriend		}
		if (indexPath.section == 2) && (indexPath.row == 1) { return cellBlock		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ProfileView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 1) && (indexPath.row == 0) { actionMedia()				}
		if (indexPath.section == 2) && (indexPath.row == 0) { actionFriendOrUnfriend()	}
		if (indexPath.section == 2) && (indexPath.row == 1) { actionBlockOrUnblock()	}
	}
}
