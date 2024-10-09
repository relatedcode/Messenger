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
import SideMenu
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class DirectsView: UIViewController {

	@IBOutlet private var searchBar: UISearchBar!
	@IBOutlet private var tableView: UITableView!

	private var observerDirect: String?
	private var observerDetail: String?
	private var observerUser: String?

	private var dbdirects: [DBDirect] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName: String?, bundle: Bundle?) {

		super.init(nibName: nibName, bundle: bundle)

		tabBarItem.image = UIImage(systemName: "text.bubble")
		tabBarItem.title = "Directs"

		NotificationCenter.addObserver(self, selector: #selector(actionCleanup), text: Notifications.UserWillLogout)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		fatalError()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Directs"

		let image = UIImage(systemName: "square.grid.2x2")
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(actionWorkspaces))

		searchBar.setImage(UIImage(), for: .search, state: .normal)

		tableView.register(UINib(nibName: "DirectsCell", bundle: nil), forCellReuseIdentifier: "DirectsCell")

		tableView.tableFooterView = UIView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		if (GQLAuth.userId() != "") {
			loadDirects()
			createObserver()
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
extension DirectsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadDirects() {

		dbdirects.removeAll()

		let userId = GQLAuth.userId()
		let text = searchBar.text ?? ""

		let arguments: [String: Any] = [":workspaceId": Workspace.id(), ":userId": "%\(userId)%", ":text": "%\(text)%"]

		let condition = "workspaceId = :workspaceId AND active LIKE :userId AND lastMessageText LIKE :text"

		dbdirects = DBDirect.fetchAll(gqldb, condition, arguments, order: "updatedAt DESC")

		tableView.reloadData()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver() {

		let types: [GQLObserverType] = [.insert, .update]

		if (observerDirect == nil) {
			observerDirect = DBDirect.createObserver(gqldb, types) { method, objectId in
				DispatchQueue.main.async {
					self.loadDirects()
				}
			}
		}

		if (observerDetail == nil) {
			let condition = String(format: "OBJ.userId = '%@'", GQLAuth.userId())
			observerDetail = DBDetail.createObserver(gqldb, types, condition) { method, objectId in
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}

		if (observerUser == nil) {
			observerUser = DBUser.createObserver(gqldb, types) { method, objectId in
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DirectsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionWorkspaces() {

		let workspacesView = WorkspacesView()
		let sideMenu = SideMenuNavigationController(rootViewController: workspacesView)
		sideMenu.sideMenuDelegate = self
		sideMenu.leftSide = true
		sideMenu.statusBarEndAlpha = 0
		sideMenu.presentationStyle = .viewSlideOut
		sideMenu.presentationStyle.onTopShadowOpacity = 2.0
		sideMenu.menuWidth = Screen.width * 0.9
		present(sideMenu, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatDirect(_ dbdirect: DBDirect) {

		view.endEditing(true)

		let chatDirectView = ChatDirectView(dbdirect.objectId, dbdirect.userId())
		chatDirectView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(chatDirectView, animated: true)
	}
}

// MARK: - Cleanup methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DirectsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		DBDirect.removeObserver(gqldb, observerDirect)
		DBDetail.removeObserver(gqldb, observerDetail)
		DBUser.removeObserver(gqldb, observerUser)

		observerDirect = nil
		observerDetail = nil
		observerUser = nil

		dbdirects.removeAll()
		tableView.reloadData()
	}
}

// MARK: - SideMenuNavigationControllerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DirectsView: SideMenuNavigationControllerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {

		loadDirects()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {

	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DirectsView: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		view.endEditing(true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DirectsView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return dbdirects.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "DirectsCell", for: indexPath) as! DirectsCell

		let dbdirect = dbdirects[indexPath.row]
		cell.bindData(dbdirect)

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DirectsView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbdirect = dbdirects[indexPath.row]
		actionChatDirect(dbdirect)
	}
}

// MARK: - UISearchBarDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DirectsView: UISearchBarDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		loadDirects()
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
		loadDirects()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}
