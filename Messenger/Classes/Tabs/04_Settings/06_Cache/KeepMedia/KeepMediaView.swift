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
class KeepMediaView: UIViewController {

	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var cellWeek: UITableViewCell!
	@IBOutlet private var cellMonth: UITableViewCell!
	@IBOutlet private var cellForever: UITableViewCell!

	private var keepMedia = 0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Keep Media"

		keepMedia = DBUsers.keepMedia()

		updateDetails()
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails() {

		cellWeek.accessoryType = (keepMedia == KeepMedia.Week) ? .checkmark : .none
		cellMonth.accessoryType = (keepMedia == KeepMedia.Month) ? .checkmark : .none
		cellForever.accessoryType = (keepMedia == KeepMedia.Forever) ? .checkmark : .none

		tableView.reloadData()
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension KeepMediaView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 3
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellWeek		}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellMonth		}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellForever	}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension KeepMediaView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 0) { keepMedia = KeepMedia.Week	}
		if (indexPath.section == 0) && (indexPath.row == 1) { keepMedia = KeepMedia.Month	}
		if (indexPath.section == 0) && (indexPath.row == 2) { keepMedia = KeepMedia.Forever	}

		DBUsers.update(keepMedia: keepMedia)

		updateDetails()
	}
}
