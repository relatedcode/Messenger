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
import MobileCoreServices
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class PeopleView: UIViewController {

	@IBOutlet private var viewTitle: UIView!
	@IBOutlet private var labelTitle: UILabel!
	@IBOutlet private var searchBar: UISearchBar!
	@IBOutlet private var tableView: UITableView!

	private var observerId: String?

	private var sections: [[DBUser]] = []
	private let collation = UILocalizedIndexedCollation.current()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		tabBarItem.image = UIImage(systemName: "person.crop.circle")
		tabBarItem.title = "People"

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
		navigationItem.titleView = viewTitle

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAddFriends))

		tableView.register(UINib(nibName: "PeopleCell", bundle: nil), forCellReuseIdentifier: "PeopleCell")

		tableView.tableFooterView = UIView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		if (GQLAuth.userId() != "") {
			loadUsers()
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
	func loadUsers() {

		let userId = GQLAuth.userId()
		let text = searchBar.text ?? ""

		let arguments: [String: Any] = [":userId": userId, ":true": true, ":text": "%%\(text)%%"]

		var condition = "objectId IN (SELECT userId2 FROM DBRelation WHERE userId1 = :userId AND isFriend = :true) AND "
		condition += "objectId NOT IN (SELECT userId1 FROM DBRelation WHERE userId2 = :userId AND isBlocked = :true) AND fullname LIKE :text"

		let dbusers = DBUser.fetchAll(gqldb, condition, arguments, order: "fullname")

		setObjects(dbusers)
		tableView.reloadData()

		if (text.isEmpty) {
			DispatchQueue.global().async {
				self.updateSearchableItems(dbusers)
			}
		}

		labelTitle.text = "(\(dbusers.count) friends)"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func setObjects(_ dbusers: [DBUser]) {

		sections.removeAll()

		let selector = #selector(getter: DBUser.fullname)
		sections = Array(repeating: [], count: collation.sectionTitles.count)

		if let sorted = collation.sortedArray(from: dbusers, collationStringSelector: selector) as? [DBUser] {
			for dbuser in sorted {
				let section = collation.section(for: dbuser, collationStringSelector: selector)
				sections[section].append(dbuser)
			}
		}
	}

	// MARK: - Observer methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func createObserver() {

		if (GQLAuth.userId() == "") || (observerId != nil) { return }

		let types: [GQLObserverType] = [.insert, .update]
		let condition = String(format: "OBJ.objectId != '%@'", GQLAuth.userId())

		observerId = DBUser.createObserver(gqldb, types, condition) { method, objectId in
			DispatchQueue.main.async {
				self.loadUsers()
			}
		}
	}

	// MARK: - Core Spotlight methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateSearchableItems(_ dbusers: [DBUser]) {

		var items: [CSSearchableItem] = []

		for dbuser in dbusers {
			let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
			attributes.title = dbuser.fullname
			attributes.displayName = dbuser.fullname
			attributes.contentDescription = dbuser.country
			attributes.keywords = [dbuser.firstname, dbuser.lastname, dbuser.country]
			if let path = Media.path(userId: dbuser.objectId) {
				if let dataEncrypted = Data(path: path) {
					attributes.thumbnailData = Cryptor.decrypt(data: dataEncrypted)
				}
			}
			items.append(CSSearchableItem(uniqueIdentifier: dbuser.objectId, domainIdentifier: nil, attributeSet: attributes))
		}

		CSSearchableIndex.default().deleteAllSearchableItems { error in
			CSSearchableIndex.default().indexSearchableItems(items)
		}
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionAddFriends() {

		let addFriendsView = AddFriendsView()
		let navController = NavigationController(rootViewController: addFriendsView)
		navController.isModalInPresentation = true
		navController.modalPresentationStyle = .fullScreen
		present(navController, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionUser(userId: String) {

		if (tabBarController?.tabBar.isHidden ?? true) { return }

		tabBarController?.selectedIndex = 1

		actionProfile(userId: userId)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionProfile(userId: String) {

		let profileView = ProfileView(userId, chat: true)
		profileView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(profileView, animated: true)
	}

	// MARK: - Cleanup methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		DBUser.removeObserver(gqldb, observerId)
		observerId = nil

		sections.removeAll()
		tableView.reloadData()
	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		view.endEditing(true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return sections.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return sections[section].count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		return (sections[section].count != 0) ? collation.sectionTitles[section] : nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {

		return collation.sectionIndexTitles
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {

		return collation.section(forSectionIndexTitle: index)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleCell

		let dbuser = sections[indexPath.section][indexPath.row]
		cell.bindData(dbuser)
		cell.loadImage(dbuser)

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbuser = sections[indexPath.section][indexPath.row]
		actionProfile(userId: dbuser.objectId)
	}
}

// MARK: - UISearchBarDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView: UISearchBarDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		loadUsers()
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
		loadUsers()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}
