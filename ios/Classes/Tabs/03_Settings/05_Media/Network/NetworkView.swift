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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class NetworkView: UIViewController {

	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var cellManual: UITableViewCell!
	@IBOutlet private var cellWiFi: UITableViewCell!
	@IBOutlet private var cellAll: UITableViewCell!

	private var mediaType = 0
	private var selectedNetwork = 0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ mediaType: Int) {

		super.init(nibName: nil, bundle: nil)

		self.mediaType = mediaType
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		fatalError()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		if (mediaType == MediaType.Photo) { title = "Photo" }
		if (mediaType == MediaType.Video) { title = "Video" }
		if (mediaType == MediaType.Audio) { title = "Audio" }

		if (mediaType == MediaType.Photo) { selectedNetwork = Network.photo() }
		if (mediaType == MediaType.Video) { selectedNetwork = Network.video() }
		if (mediaType == MediaType.Audio) { selectedNetwork = Network.audio() }

		updateDetails()
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails() {

		cellManual.accessoryType = (selectedNetwork == Network.Manual) ? .checkmark : .none
		cellWiFi.accessoryType	 = (selectedNetwork == Network.WiFi) ? .checkmark : .none
		cellAll.accessoryType	 = (selectedNetwork == Network.All) ? .checkmark : .none

		tableView.reloadData()
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension NetworkView: UITableViewDataSource {

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

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellManual	}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellWiFi	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellAll	}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension NetworkView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 0) { selectedNetwork = Network.Manual	}
		if (indexPath.section == 0) && (indexPath.row == 1) { selectedNetwork = Network.WiFi	}
		if (indexPath.section == 0) && (indexPath.row == 2) { selectedNetwork = Network.All		}

		if (mediaType == MediaType.Photo) { Network.photo(selectedNetwork) }
		if (mediaType == MediaType.Video) { Network.video(selectedNetwork) }
		if (mediaType == MediaType.Audio) { Network.audio(selectedNetwork) }

		updateDetails()
	}
}
