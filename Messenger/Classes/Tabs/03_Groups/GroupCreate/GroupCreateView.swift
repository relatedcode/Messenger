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
class GroupCreateView: UIViewController {

	@IBOutlet private var fieldName: UITextField!
	@IBOutlet private var searchBar: UISearchBar!
	@IBOutlet private var tableView: UITableView!

	private var selection: [String] = []
	private var sections: [[DBUser]] = []
	private let collation = UILocalizedIndexedCollation.current()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Create Group"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionDismiss))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))

		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tableView.addGestureRecognizer(gestureRecognizer)
		gestureRecognizer.cancelsTouchesInView = false

		tableView.tableFooterView = UIView()

		loadUsers()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		fieldName.becomeFirstResponder()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		dismissKeyboard()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func dismissKeyboard() {

		view.endEditing(true)
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

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		let name = fieldName.text ?? ""

		if (name.isEmpty)		{ ProgressHUD.showFailed("Group name must be set.");	return	}
		if (selection.isEmpty)	{ ProgressHUD.showFailed("Please select some users.");	return	}

		var userIds = selection
		userIds.append(GQLAuth.userId())

		DBGroups.create(name, userIds)

		dismiss(animated: true)
	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupCreateView: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		dismissKeyboard()
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupCreateView: UITableViewDataSource {

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

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") }

		let dbuser = sections[indexPath.section][indexPath.row]
		cell.textLabel?.text = dbuser.fullname
		cell.accessoryType = selection.contains(dbuser.objectId) ? .checkmark : .none

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupCreateView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbuser = sections[indexPath.section][indexPath.row]

		if (selection.contains(dbuser.objectId)) {
			selection.remove(dbuser.objectId)
		} else {
			selection.append(dbuser.objectId)
		}

		if let cell = tableView.cellForRow(at: indexPath) {
			cell.accessoryType = selection.contains(dbuser.objectId) ? .checkmark : .none
		}
	}
}

// MARK: - UISearchBarDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GroupCreateView: UISearchBarDelegate {

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
