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
import GraphQLite
import ProgressHUD

//-----------------------------------------------------------------------------------------------------------------------------------------------
class EditProfileView: UIViewController {

	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var viewHeader: UIView!
	@IBOutlet private var imageUser: UIImageView!
	@IBOutlet private var labelInitials: UILabel!

	@IBOutlet private var cellFullName: UITableViewCell!
	@IBOutlet private var cellDispName: UITableViewCell!
	@IBOutlet private var cellTitle: UITableViewCell!
	@IBOutlet private var cellPhone: UITableViewCell!

	@IBOutlet private var fieldFullName: UITextField!
	@IBOutlet private var fieldDispName: UITextField!
	@IBOutlet private var fieldTitle: UITextField!
	@IBOutlet private var fieldPhone: UITextField!

	private var dbuser: DBUser!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Edit Profile"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionDismiss))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))

		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tableView.addGestureRecognizer(gestureRecognizer)
		gestureRecognizer.cancelsTouchesInView = false

		tableView.tableHeaderView = viewHeader

		loadUser()
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
}

// MARK: - Database methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadUser() {

		dbuser = DBUser.fetchOne(gqldb, key: GQLAuth.userId())

		labelInitials.text = dbuser.initials()
		MediaDownload.user(dbuser.photoURL) { [weak self] image, later in
			guard let self = self else { return }
			if let image = image {
				imageUser.image = image.square(to: 70)
				labelInitials.text = nil
			}
		}

		fieldFullName.text = dbuser.fullName
		fieldDispName.text = dbuser.displayName
		fieldTitle.text = dbuser.title
		fieldPhone.text = dbuser.phoneNumber
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func saveUser(_ values: [String: Any]) {

		ProgressHUD.animate(interaction: false)

		scheduler.updateUser(values, { error in
			if let error = error {
				ProgressHUD.failed(error)
			} else {
				ProgressHUD.succeed()
				self.dismiss(animated: true)
			}
		})
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		let fullname = fieldFullName.text ?? ""
		let dispname = fieldDispName.text ?? ""
		let title = fieldTitle.text ?? ""
		let phone = fieldPhone.text ?? ""

		if (fullname.isEmpty)	{ ProgressHUD.failed("Full name must be set.");		return	}
		if (dispname.isEmpty)	{ ProgressHUD.failed("Display name must be set.");	return	}

		saveUser(["fullName": fullname, "displayName": dispname, "title": title, "phoneNumber": phone])
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionPhoto(_ sender: Any) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.action("Open Camera", .default) { _ in
			ImagePicker.cameraPhoto(self, edit: true)
		}
		alert.action("Photo Library", .default) { _ in
			ImagePicker.photoLibrary(self, edit: true)
		}
		alert.actionCancel()

		present(alert, animated: true)
	}

}

// MARK: - Upload methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func uploadPicture(image: UIImage) {

		print(#function)
	}
}

// MARK: - UIImagePickerControllerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

		if let image = info[.editedImage] as? UIImage {
			uploadPicture(image: image)
		}
		picker.dismiss(animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 4
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellFullName	}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellDispName	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellTitle		}
		if (indexPath.section == 0) && (indexPath.row == 3) { return cellPhone		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK: - UITextFieldDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UITextFieldDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		if (textField == fieldFullName)	{ fieldDispName.becomeFirstResponder()	}
		if (textField == fieldDispName)	{ fieldTitle.becomeFirstResponder()		}
		if (textField == fieldTitle)	{ fieldPhone.becomeFirstResponder()		}
		if (textField == fieldPhone)	{ actionDone()							}

		return true
	}
}
