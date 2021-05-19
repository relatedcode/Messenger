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
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ArchivedView: UIViewController {

	@IBOutlet private var searchBar: UISearchBar!
	@IBOutlet private var tableView: UITableView!

	private var observerId: String?
	private var chatObjects: [ChatObject] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Archived Chats"

		tableView.register(UINib(nibName: "ArchivedCell", bundle: nil), forCellReuseIdentifier: "ArchivedCell")

		tableView.tableFooterView = UIView()

		loadChats()
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
	func loadChats() {

		chatObjects.removeAll()

		let userId = GQLAuth.userId()
		let text = searchBar.text ?? ""

		let arguments: [String: Any] = [":userId": userId, ":true": true, ":false": false, ":zero": 0.0, ":text": "%%\(text)%%"]

		var condition = "objectId IN (SELECT chatId FROM DBMember WHERE userId = :userId AND isActive = :true) AND "
		condition += "isDeleted = :false AND isArchived = :true AND isGroupDeleted = :false AND lastMessageAt != :zero AND details LIKE :text"

		chatObjects = ChatObject.fetchAll(gqldb, condition, arguments, order: "lastMessageAt DESC")

		tableView.reloadData()
	}

	// MARK: - Observer methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func createObserver() {

		let types: [GQLObserverType] = [.insert, .update]

		observerId = ChatObject.createObserver(gqldb, types) { method, objectId in
			DispatchQueue.main.async {
				self.loadChats()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func removeObserver() {

		ChatObject.removeObserver(gqldb, observerId)
		observerId = nil
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatPrivate(_ chatId: String, _ recipientId: String) {

		view.endEditing(true)

		let chatPrivateView = ChatPrivateView(chatId, recipientId)
		navigationController?.pushViewController(chatPrivateView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatGroup(_ chatId: String) {

		view.endEditing(true)

		let chatGroupView = ChatGroupView(chatId)
		navigationController?.pushViewController(chatGroupView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionDelete(_ indexPath: IndexPath) {

		let chatObject = chatObjects[indexPath.row]

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in
			DBDetails.update(chatId: chatObject.objectId, isDeleted: true)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionMore(_ indexPath: IndexPath) {

		let chatObject = chatObjects[indexPath.row]

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Unarchive", style: .default) { action in
			DBDetails.update(chatId: chatObject.objectId, isArchived: false)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ArchivedView: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		view.endEditing(true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ArchivedView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return chatObjects.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "ArchivedCell", for: indexPath) as! ArchivedCell

		let chatObject = chatObjects[indexPath.row]
		cell.bindData(chatObject)
		cell.loadImage(chatObject)

		return cell
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

		return true
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

		let actionDelete = UIContextualAction(style: .destructive, title: "Delete") {  action, sourceView, completionHandler in
			self.actionDelete(indexPath)
			completionHandler(false)
		}

		let actionMore = UIContextualAction(style: .normal, title: "More") {  action, sourceView, completionHandler in
			self.actionMore(indexPath)
			completionHandler(false)
		}

		actionDelete.image = UIImage(systemName: "trash")
		actionMore.image = UIImage(systemName: "ellipsis")

		return UISwipeActionsConfiguration(actions: [actionDelete, actionMore])
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ArchivedView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let chatObject = chatObjects[indexPath.row]

		if (chatObject.isGroup) {
			actionChatGroup(chatObject.objectId)
		}
		if (chatObject.isPrivate) {
			actionChatPrivate(chatObject.objectId, chatObject.userId)
		}
	}
}

// MARK: - UISearchBarDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ArchivedView: UISearchBarDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		loadChats()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(true, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(false, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

		searchBar.text = ""
		searchBar.resignFirstResponder()
		loadChats()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}
