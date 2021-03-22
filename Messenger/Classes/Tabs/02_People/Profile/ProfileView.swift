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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ProfileView: UIViewController {

	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var viewHeader: UIView!
	@IBOutlet private var imageUser: UIImageView!
	@IBOutlet private var labelInitials: UILabel!
	@IBOutlet private var labelName: UILabel!
	@IBOutlet private var labelDetails: UILabel!
	@IBOutlet private var cellStatus: UITableViewCell!
	@IBOutlet private var cellCountry: UITableViewCell!
	@IBOutlet private var cellLocation: UITableViewCell!
	@IBOutlet private var cellPhone: UITableViewCell!
	@IBOutlet private var cellMedia: UITableViewCell!
	@IBOutlet private var cellChat: UITableViewCell!
	@IBOutlet private var cellFriend: UITableViewCell!
	@IBOutlet private var cellBlock: UITableViewCell!

	private var userId = ""
	private var isChatEnabled = false

	private var number = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(userId: String, chat: Bool) {

		super.init(nibName: nil, bundle: nil)

		self.userId = userId
		isChatEnabled = chat
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
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

		guard let dbuser = DBUser.fetchOne(gqldb, key: userId) else { return }

		labelInitials.text = dbuser.initials()
		MediaDownload.user(dbuser.objectId, pictureAt: dbuser.pictureAt) { image, error in
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

		number = dbuser.phone
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
	func actionPhone() {

		let number1 = "tel://\(number)"
		let number2 = number1.replacingOccurrences(of: " ", with: "")

		if let url = URL(string: number2) {
			UIApplication.shared.open(url)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionMedia() {

		let chatId = DBSingles.chatId(userId)
		let allMediaView = AllMediaView(chatId: chatId)
		navigationController?.pushViewController(allMediaView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionChat() {

		let chatId = DBSingles.create(userId)
		let chatPrivateView = ChatPrivateView(chatId: chatId, recipientId: userId)
		navigationController?.pushViewController(chatPrivateView, animated: true)
	}

	// MARK: - User actions (Friend/Unfriend)
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

	// MARK: - User actions (Block/Unblock)
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

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ProfileView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 3
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let isBlocker = DBRelations.isBlocker(userId)

		if (section == 0) { return isBlocker ? 3 : 4		}
		if (section == 1) { return isChatEnabled ? 2 : 1	}
		if (section == 2) { return 2						}

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellStatus		}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellCountry	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellLocation	}
		if (indexPath.section == 0) && (indexPath.row == 3) { return cellPhone		}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellMedia		}
		if (indexPath.section == 1) && (indexPath.row == 1) { return cellChat		}
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

		if (indexPath.section == 0) && (indexPath.row == 3) { actionPhone()				}
		if (indexPath.section == 1) && (indexPath.row == 0) { actionMedia()				}
		if (indexPath.section == 1) && (indexPath.row == 1) { actionChat()				}
		if (indexPath.section == 2) && (indexPath.row == 0) { actionFriendOrUnfriend()	}
		if (indexPath.section == 2) && (indexPath.row == 1) { actionBlockOrUnblock()	}
	}
}
