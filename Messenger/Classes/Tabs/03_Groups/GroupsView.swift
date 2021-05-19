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
class GroupsView: UIViewController {

	@IBOutlet private var searchBar: UISearchBar!
	@IBOutlet private var tableView: UITableView!

	private var observerId: String?
	private var dbgroups: [DBGroup] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		tabBarItem.image = UIImage(systemName: "person.2")
		tabBarItem.title = "Groups"

		NotificationCenter.addObserver(self, selector: #selector(createObserver), text: Notifications.AppStarted)
		NotificationCenter.addObserver(self, selector: #selector(createObserver), text: Notifications.UserLoggedIn)
		NotificationCenter.addObserver(self, selector: #selector(actionCleanup), text: Notifications.UserLoggedOut)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Groups"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionNew))

		tableView.register(UINib(nibName: "GroupsCell", bundle: nil), forCellReuseIdentifier: "GroupsCell")

		tableView.tableFooterView = UIView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		if (GQLAuth.userId() != "") {
			loadGroups()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		if (GQLAuth.userId() != "") {
			if (DBUsers.fullname() != "") {

			} else { Users.onboard(self) }
		} else { Users.login(self) }
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadGroups() {

		dbgroups.removeAll()

		let userId = GQLAuth.userId()
		let text = searchBar.text ?? ""

		let arguments: [String: Any] = [":userId": userId, ":true": true, ":false": false, ":text": "%%\(text)%%"]

		var condition = "objectId IN (SELECT chatId FROM DBMember WHERE userId = :userId AND isActive = :true)"
		condition += " AND isDeleted = :false AND name LIKE :text"

		dbgroups = DBGroup.fetchAll(gqldb, condition, arguments, order: "name")

		tableView.reloadData()
	}

	// MARK: - Observer methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func createObserver() {

		if (GQLAuth.userId() == "") || (observerId != nil) { return }

		let types: [GQLObserverType] = [.insert, .update]

		observerId = DBGroup.createObserver(gqldb, types) { method, objectId in
			DispatchQueue.main.async {
				self.loadGroups()
			}
		}
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionNew() {

		let groupCreateView = GroupCreateView()
		let navController = NavigationController(rootViewController: groupCreateView)
		present(navController, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionNewGroup() {

		if (tabBarController?.tabBar.isHidden ?? true) { return }

		tabBarController?.selectedIndex = 2

		actionNew()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatGroup(chatId: String) {


		view.endEditing(true)

		let chatGroupView = ChatGroupView(chatId)
		chatGroupView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(chatGroupView, animated: true)
	}

	// MARK: - Cleanup methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		DBGroup.removeObserver(gqldb, observerId)
		observerId = nil

		dbgroups.removeAll()
		tableView.reloadData()
	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupsView: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		view.endEditing(true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupsView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return dbgroups.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath) as! GroupsCell

		let dbgroup = dbgroups[indexPath.row]
		cell.bindData(dbgroup)

		return cell
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

		let dbgroup = dbgroups[indexPath.row]
		return (dbgroup.ownerId == GQLAuth.userId())
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in
			let dbgroup = self.dbgroups[indexPath.row]
			dbgroup.update(isDeleted: true)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupsView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbgroup = dbgroups[indexPath.row]
		actionChatGroup(chatId: dbgroup.chatId)
	}
}

// MARK: - UISearchBarDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupsView: UISearchBarDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		loadGroups()
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
		loadGroups()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}
