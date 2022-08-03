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
import MessageUI
import ProgressHUD

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ProfileView: UIViewController {

	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var viewHeader: UIView!
	@IBOutlet private var imageUser: UIImageView!
	@IBOutlet private var labelInitials: UILabel!
	@IBOutlet private var labelName: UILabel!
	@IBOutlet private var labelDetails: UILabel!

	@IBOutlet private var imageHeader1: UIImageView!
	@IBOutlet private var imageHeader2: UIImageView!
	@IBOutlet private var imageHeader3: UIImageView!
	@IBOutlet private var imageHeader4: UIImageView!
	@IBOutlet private var buttonHeader1: UIButton!
	@IBOutlet private var buttonHeader2: UIButton!
	@IBOutlet private var buttonHeader3: UIButton!
	@IBOutlet private var buttonHeader4: UIButton!

	@IBOutlet private var cellFullName: UITableViewCell!
	@IBOutlet private var cellDispName: UITableViewCell!
	@IBOutlet private var cellTitle: UITableViewCell!
	@IBOutlet private var cellPhone: UITableViewCell!
	@IBOutlet private var cellMedia: UITableViewCell!

	private var userId = ""
	private var chatId = ""

	private var dbuser: DBUser!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ userId: String, _ chatId: String = "") {

		super.init(nibName: nil, bundle: nil)

		self.userId = userId
		self.chatId = chatId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Profile"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		tableView.tableHeaderView = viewHeader

		loadUser()
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func loadUser() {

		dbuser = DBUser.fetchOne(gqldb, key: userId)

		labelInitials.text = dbuser.initials()
		MediaDownload.user(dbuser.photoURL) { image, later in
			if let image = image {
				self.labelInitials.text = nil
				self.imageUser.image = image.square(to: 70)
			}
		}

		labelName.text = dbuser.fullName
		labelDetails.text = dbuser.email

		cellFullName.detailTextLabel?.text = dbuser.fullName
		cellDispName.detailTextLabel?.text = dbuser.displayName
		cellTitle.detailTextLabel?.text = dbuser.title
		cellPhone.detailTextLabel?.text = dbuser.phoneNumber

		tableView.reloadData()
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionPhoto(_ sender: Any) {

		if let path = Media.path(user: dbuser.photoURL) {
			if let image = UIImage.image(path, size: 320) {
				let pictureView = PictureView(image: image)
				present(pictureView, animated: true)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHeader1(_ sender: Any) {

		print(#function)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHeader2(_ sender: Any) {

		let number1 = "tel://\(dbuser.phoneNumber)"
		let number2 = number1.replacingOccurrences(of: " ", with: "")

		if let url = URL(string: number2) {
			if (UIApplication.shared.canOpenURL(url)) {
				UIApplication.shared.open(url)
			} else {
				ProgressHUD.showFailed("Call cannot be initiated.")
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHeader3(_ sender: Any) {

		print(#function)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHeader4(_ sender: Any) {

		let subject = "Subject"
		let message = "Message body"

		if (MFMailComposeViewController.canSendMail()) {
			let mailCompose = MFMailComposeViewController()
			mailCompose.setToRecipients([dbuser.email])
			mailCompose.setSubject(subject)
			mailCompose.setMessageBody(message, isHTML: false)
			mailCompose.mailComposeDelegate = self
			present(mailCompose, animated: true)
		} else {
			let link = "mailto:\(dbuser.email)?subject=\(subject)&body=\(message)"
			if let encoded = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
				if let url = URL(string: encoded) {
					if (UIApplication.shared.canOpenURL(url)) {
						UIApplication.shared.open(url)
					} else {
						ProgressHUD.showFailed("Mail cannot be sent.")
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionMedia() {

		let allMediaView = AllMediaView(chatId)
		navigationController?.pushViewController(allMediaView, animated: true)
	}
}

// MARK: - MFMailComposeViewControllerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ProfileView: MFMailComposeViewControllerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

		if (result == MFMailComposeResult.sent) {
			ProgressHUD.showSucceed("Mail sent successfully.")
		}
		controller.dismiss(animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ProfileView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return (chatId == "") ? 1 : 2
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 4 }
		if (section == 1) { return 1 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellFullName	}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellDispName	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellTitle		}
		if (indexPath.section == 0) && (indexPath.row == 3) { return cellPhone		}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellMedia		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ProfileView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 1) && (indexPath.row == 0) { actionMedia()	}
	}
}
