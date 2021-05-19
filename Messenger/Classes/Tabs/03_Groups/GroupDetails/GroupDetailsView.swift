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
import ProgressHUD
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GroupDetailsView: UIViewController {

	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var cellDetails: UITableViewCell!
	@IBOutlet private var labelName: UILabel!
	@IBOutlet private var cellMedia: UITableViewCell!
	@IBOutlet private var cellLeave: UITableViewCell!
	@IBOutlet private var viewFooter: UIView!
	@IBOutlet private var labelFooter1: UILabel!
	@IBOutlet private var labelFooter2: UILabel!

	private var chatId = ""
	private var dbgroup: DBGroup!

	private var observerId: String?
	private var dbusers: [DBUser] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ chatId: String) {

		super.init(nibName: nil, bundle: nil)

		self.chatId = chatId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Group"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(actionMore))

		tableView.tableFooterView = viewFooter

		loadGroup()
		loadMembers()
		createObserver()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		if (isMovingFromParent) {
			removeObserver()
		}
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadGroup() {

		dbgroup = DBGroup.fetchOne(gqldb, key: chatId)

		labelName.text = dbgroup.name

		if let dbuser = DBUser.fetchOne(gqldb, key: dbgroup.ownerId) {
			labelFooter1.text = "Created by \(dbuser.fullname)"
			labelFooter2.text = Convert.dateToMediumTime(dbgroup.createdAt)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadMembers() {

		dbusers.removeAll()

		let arguments: [String: Any] = [":chatId": chatId, ":true": true]

		let condition = "objectId IN (SELECT userId FROM DBMember WHERE chatId = :chatId AND isActive = :true)"

		dbusers = DBUser.fetchAll(gqldb, condition, arguments, order: "fullname")

		tableView.reloadData()
	}

	// MARK: - Observer methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver() {

		let condition = String(format: "OBJ.objectId = '%@'", chatId)

		observerId = DBGroup.createObserver(gqldb, .update, condition) { method, objectId in
			DispatchQueue.main.async {
				self.loadMembers()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func removeObserver() {

		DBGroup.removeObserver(gqldb, observerId)
		observerId = nil
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMore() {

		if isGroupOwner() { actionMoreOwner() } else { actionMoreMember() }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionMoreOwner() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Add Members", style: .default) { action in
			self.actionAddMembers()
		})
		alert.addAction(UIAlertAction(title: "Rename Group", style: .default) { action in
			self.actionRenameGroup()
		})
		alert.addAction(UIAlertAction(title: "Delete Group", style: .destructive) { action in
			self.actionDeleteGroup()
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionAddMembers() {

		let selectUsersView = SelectUsersView()
		selectUsersView.delegate = self
		let navController = NavigationController(rootViewController: selectUsersView)
		present(navController, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionRenameGroup() {

		let alert = UIAlertController(title: "Rename Group", message: "Enter a new name for this Group", preferredStyle: .alert)

		alert.addTextField(configurationHandler: { textField in
			textField.text = self.dbgroup.name
			textField.placeholder = "Group name"
			textField.autocapitalizationType = .words
		})

		alert.addAction(UIAlertAction(title: "Save", style: .default) { action in
			if let textField = alert.textFields?[0] {
				self.actionRenameGroup(textField.text)
			}
		})

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionRenameGroup(_ text: String?) {

		guard let name = text else { return }
		guard (name.count != 0) else { return }

		dbgroup.update(name: name)

		labelName.text = name
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionDeleteGroup() {

		dbgroup.update(isDeleted: true)

		NotificationCenter.post(Notifications.CleanupChatView)

		navigationController?.popToRootViewController(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionMoreMember() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Leave Group", style: .destructive) { action in
			self.actionLeaveGroup()
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionLeaveGroup() {

		DBMembers.update(chatId, GQLAuth.userId(), isActive: false)

		dbgroup.update(members: dbgroup.members-1)

		NotificationCenter.post(Notifications.CleanupChatView)

		navigationController?.popToRootViewController(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionDeleteMember(_ indexPath: IndexPath) {

		let dbuser = dbusers[indexPath.row]

		DBMembers.update(chatId, dbuser.objectId, isActive: false)

		dbgroup.update(members: dbgroup.members-1)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionAllMedia() {

		let allMediaView = AllMediaView(chatId)
		navigationController?.pushViewController(allMediaView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionProfile(_ userId: String) {

		let profileView = ProfileView(userId, chat: true)
		navigationController?.pushViewController(profileView, animated: true)
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func titleForHeaderMembers() -> String? {

		let text = (dbusers.count > 1) ? "MEMBERS" : "MEMBER"
		return "\(dbusers.count) \(text)"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func isGroupOwner() -> Bool {

		return (dbgroup?.ownerId == GQLAuth.userId())
	}
}

// MARK: - SelectUsersDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupDetailsView: SelectUsersDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectUsers(userIds: [String]) {

		var memberIds = DBMembers.userIds(chatId)
		for userId in userIds {
			memberIds.appendUnique(userId)
		}

		DBDetails.create(chatId, userIds)
		DBMembers.create(chatId, userIds)

		dbgroup.update(members: memberIds.count)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupDetailsView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 4
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 1 						}
		if (section == 1) { return 1 						}
		if (section == 2) { return dbusers.count			}
		if (section == 3) {	return isGroupOwner() ? 0 : 1	}

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if (section == 0) { return nil						}
		if (section == 1) { return nil						}
		if (section == 2) { return titleForHeaderMembers()	}
		if (section == 3) { return nil 						}

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) {
			return cellDetails
		}

		if (indexPath.section == 1) && (indexPath.row == 0) {
			return cellMedia
		}

		if (indexPath.section == 2) {
			var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
			if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: "cell") }

			let dbuser = dbusers[indexPath.row]
			cell.textLabel?.text = dbuser.fullname

			return cell
		}

		if (indexPath.section == 3) && (indexPath.row == 0) {
			return cellLeave
		}

		return UITableViewCell()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

		if (indexPath.section == 2) {
			if (isGroupOwner()) {
				let dbuser = dbusers[indexPath.row]
				return (dbuser.objectId != GQLAuth.userId())
			}
		}

		return false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in
			self.actionDeleteMember(indexPath)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupDetailsView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 1) && (indexPath.row == 0) {
			actionAllMedia()
		}

		if (indexPath.section == 2) {
			let dbuser = dbusers[indexPath.row]
			if (dbuser.objectId == GQLAuth.userId()) {
				ProgressHUD.showSucceed("This is you.")
			} else {
				actionProfile(dbuser.objectId)
			}
		}

		if (indexPath.section == 3) && (indexPath.row == 0) {
			actionMoreMember()
		}
	}
}
