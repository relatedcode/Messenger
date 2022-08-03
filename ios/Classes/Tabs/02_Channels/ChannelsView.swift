//
// Copyright (c) 2022 Related Code - https://relatedcode.com
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
class ChannelsView: UIViewController {

	@IBOutlet private var searchBar: UISearchBar!
	@IBOutlet private var tableView: UITableView!

	private var observerChannel: String?
	private var observerDetail: String?

	private var dbchannels: [DBChannel] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName: String?, bundle: Bundle?) {

		super.init(nibName: nibName, bundle: bundle)

		tabBarItem.image = UIImage(systemName: "rectangle.grid.1x2")
		tabBarItem.title = "Channels"

		NotificationCenter.addObserver(self, selector: #selector(actionCleanup), text: Notifications.UserWillLogout)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Channels"

		let image = UIImage(systemName: "square.grid.2x2")
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(actionWorkspaces))

		tableView.register(UINib(nibName: "ChannelsCell", bundle: nil), forCellReuseIdentifier: "ChannelsCell")

		tableView.tableFooterView = UIView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		if (GQLAuth.userId() != "") {
			loadChannels()
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

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadChannels() {

		dbchannels.removeAll()

		let userId = GQLAuth.userId()
		let text = searchBar.text ?? ""

		let arguments: [String: Any] = [":workspaceId": Workspace.id(), ":userId": "%\(userId)%", ":false": false, ":text": "%\(text)%"]

		let condition = "workspaceId = :workspaceId AND members LIKE :userId AND isDeleted = :false AND isArchived = :false AND name LIKE :text"

		dbchannels = DBChannel.fetchAll(gqldb, condition, arguments, order: "updatedAt DESC")

		tableView.reloadData()
	}

	// MARK: - Observer methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver() {

		let types: [GQLObserverType] = [.insert, .update]

		if (observerChannel == nil) {
			observerChannel = DBChannel.createObserver(gqldb, types) { method, objectId in
				DispatchQueue.main.async {
					self.loadChannels()
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
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionWorkspaces() {

		let workspacesView = WorkspacesView()
		let sideMenu = SideMenuNavigationController(rootViewController: workspacesView)
		sideMenu.sideMenuDelegate = self
		sideMenu.leftSide = true
		sideMenu.statusBarEndAlpha = 0
		sideMenu.presentationStyle = .viewSlideOut
		sideMenu.presentationStyle.onTopShadowOpacity = 2.0
		sideMenu.menuWidth = UIScreen.main.bounds.size.width * 0.9
		present(sideMenu, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatChannel(_ dbchannel: DBChannel) {

		view.endEditing(true)

		let chatChannelView = ChatChannelView(dbchannel.objectId)
		chatChannelView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(chatChannelView, animated: true)
	}

	// MARK: - Cleanup methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		DBChannel.removeObserver(gqldb, observerChannel)
		DBDetail.removeObserver(gqldb, observerDetail)

		observerChannel = nil
		observerDetail = nil

		dbchannels.removeAll()
		tableView.reloadData()
	}
}

// MARK: - SideMenuNavigationControllerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChannelsView: SideMenuNavigationControllerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {

		loadChannels()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {

	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChannelsView: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		view.endEditing(true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChannelsView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return dbchannels.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelsCell", for: indexPath) as! ChannelsCell

		let dbchannel = dbchannels[indexPath.row]
		cell.bindData(dbchannel)

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChannelsView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbchannel = dbchannels[indexPath.row]
		actionChatChannel(dbchannel)
	}
}

// MARK: - UISearchBarDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChannelsView: UISearchBarDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		loadChannels()
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
		loadChannels()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}
