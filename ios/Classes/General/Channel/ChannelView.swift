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
import GraphQLite
import ProgressHUD

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ChannelView: UIViewController {

	@IBOutlet private var tableView: UITableView!

	@IBOutlet private var cellMedia: UITableViewCell!
	@IBOutlet private var viewFooter: UIView!
	@IBOutlet private var labelFooter1: UILabel!
	@IBOutlet private var labelFooter2: UILabel!

	private var objectId = ""
	private var dbchannel: DBChannel!

	private var observerId: String?
	private var dbusers: [DBUser] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ objectId: String) {

		super.init(nibName: nil, bundle: nil)

		self.objectId = objectId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		tableView.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")

		tableView.tableFooterView = viewFooter

		loadChannel()
		loadMembers()
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadChannel() {

		dbchannel = DBChannel.fetchOne(gqldb, key: objectId)

		title = dbchannel.name

		if let dbuser = DBUser.fetchOne(gqldb, key: dbchannel.createdBy) {
			labelFooter1.text = "Created by \(dbuser.fullName)"
			labelFooter2.text = Convert.dateToMediumTime(dbchannel.createdAt)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadMembers() {

		dbusers.removeAll()

		let arguments: [String: Any] = [":members": dbchannel.members]

		let condition = "objectId IN :members"

		dbusers = DBUser.fetchAll(gqldb, condition, arguments, order: "fullName")

		tableView.reloadData()
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionProfile(_ userId: String) {

		let profileView = ProfileView(userId)
		navigationController?.pushViewController(profileView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionAllMedia() {

		let allMediaView = AllMediaView(objectId)
		navigationController?.pushViewController(allMediaView, animated: true)
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func titleForHeaderMembers() -> String? {

		let text = (dbusers.count > 1) ? "MEMBERS" : "MEMBER"
		return "\(dbusers.count) \(text)"
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChannelView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 2
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return dbusers.count }
		if (section == 1) { return 1 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if (section == 0) { return titleForHeaderMembers() }
		if (section == 1) { return nil }

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) {
			let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell

			let dbuser = dbusers[indexPath.row]
			cell.bindData(dbuser)
			cell.loadImage(dbuser)

			return cell
		}

		if (indexPath.section == 1) {
			return cellMedia
		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChannelView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) {
			let dbuser = dbusers[indexPath.row]
			if (dbuser.objectId == GQLAuth.userId()) {
				ProgressHUD.showSucceed("This is you.")
			} else {
				actionProfile(dbuser.objectId)
			}
		}

		if (indexPath.section == 1) {
			actionAllMedia()
		}
	}
}
