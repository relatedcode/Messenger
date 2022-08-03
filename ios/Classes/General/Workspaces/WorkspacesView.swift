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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class WorkspacesView: UIViewController {

	@IBOutlet private var tableView: UITableView!

	private var dbworkspaces: [DBWorkspace] = []

	private var observerId: String?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Workspaces"

		tableView.register(UINib(nibName: "WorkspacesCell", bundle: nil), forCellReuseIdentifier: "WorkspacesCell")

		tableView.tableFooterView = UIView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		loadWorkspaces()
		createObserver()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		removeObserver()
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadWorkspaces() {

		dbworkspaces.removeAll()

		let userId = GQLAuth.userId()

		let arguments: [String: Any] = [":false": false, ":userId": "%\(userId)%"]

		let condition = "isDeleted = :false AND members LIKE :userId"

		dbworkspaces = DBWorkspace.fetchAll(gqldb, condition, arguments, order: "createdAt DESC")

		tableView.reloadData()
	}

	// MARK: - Observer methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver() {

		if (observerId != nil) { return }

		let types: [GQLObserverType] = [.insert, .update]

		observerId = DBWorkspace.createObserver(gqldb, types) { method, objectId in
			DispatchQueue.main.async {
				self.loadWorkspaces()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func removeObserver() {

		DBWorkspace.removeObserver(gqldb, observerId)
		observerId = nil
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension WorkspacesView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return dbworkspaces.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "WorkspacesCell", for: indexPath) as! WorkspacesCell

		let dbworkspace = dbworkspaces[indexPath.row]
		cell.bindData(dbworkspace)

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension WorkspacesView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbworkspace = dbworkspaces[indexPath.row]
		Workspace.save(dbworkspace.objectId)

		DispatchQueue.main.async(after: 0.2) {
			self.dismiss(animated: true)
		}
	}
}
