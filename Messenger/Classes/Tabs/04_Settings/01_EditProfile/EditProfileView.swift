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
class EditProfileView: UIViewController {

	@IBOutlet private var tableView: UITableView!
	@IBOutlet private var viewHeader: UIView!
	@IBOutlet private var imageUser: UIImageView!
	@IBOutlet private var labelInitials: UILabel!
	@IBOutlet private var cellFirstname: UITableViewCell!
	@IBOutlet private var cellLastname: UITableViewCell!
	@IBOutlet private var cellCountry: UITableViewCell!
	@IBOutlet private var cellLocation: UITableViewCell!
	@IBOutlet private var cellPhone: UITableViewCell!
	@IBOutlet private var fieldFirstname: UITextField!
	@IBOutlet private var fieldLastname: UITextField!
	@IBOutlet private var labelPlaceholder: UILabel!
	@IBOutlet private var labelCountry: UILabel!
	@IBOutlet private var fieldLocation: UITextField!
	@IBOutlet private var fieldPhone: UITextField!

	private var isOnboard = false

	private var dbuser: DBUser!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(onboard: Bool) {

		super.init(nibName: nil, bundle: nil)

		isOnboard = onboard
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

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

	// MARK: - Keyboard methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func dismissKeyboard() {

		view.endEditing(true)
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadUser() {

		dbuser = DBUser.fetchOne(gqldb, key: GQLAuth.userId())

		labelInitials.text = dbuser.initials()
		MediaDownload.user(dbuser.objectId, dbuser.pictureAt) { image, error in
			if (error == nil) {
				self.imageUser.image = image?.square(to: 70)
				self.labelInitials.text = nil
			}
		}

		fieldFirstname.text = dbuser.firstname
		fieldLastname.text = dbuser.lastname
		labelCountry.text = dbuser.country
		fieldLocation.text = dbuser.location
		fieldPhone.text = dbuser.phone

		updateDetails()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func saveUser(_ firstname: String, _ lastname: String, _ country: String, _ location: String, _ phone: String) {

		dbuser.firstname	= firstname
		dbuser.lastname		= lastname
		dbuser.fullname		= "\(firstname) \(lastname)"
		dbuser.country		= country
		dbuser.location		= location
		dbuser.phone		= phone

		dbuser.updateLazy()
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		if (isOnboard) {
			Users.performLogout()
		}
		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		let firstname = fieldFirstname.text ?? ""
		let lastname = fieldLastname.text ?? ""
		let country = labelCountry.text ?? ""
		let location = fieldLocation.text ?? ""
		let phone = fieldPhone.text ?? ""

		if (firstname.isEmpty)	{ ProgressHUD.showFailed("Firstname must be set.");		return	}
		if (lastname.isEmpty)	{ ProgressHUD.showFailed("Lastname must be set.");		return	}
		if (country.isEmpty)	{ ProgressHUD.showFailed("Country must be set.");		return	}
		if (location.isEmpty)	{ ProgressHUD.showFailed("Location must be set.");		return	}
		if (phone.isEmpty)		{ ProgressHUD.showFailed("Phone number must be set.");	return	}

		saveUser(firstname, lastname, country, location, phone)

		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionPhoto(_ sender: Any) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Open Camera", style: .default) { action in
			ImagePicker.cameraPhoto(self, edit: true)
		})
		alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { action in
			ImagePicker.photoLibrary(self, edit: true)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionCountries() {

		let countriesView = CountriesView()
		countriesView.delegate = self
		let navController = NavigationController(rootViewController: countriesView)
		present(navController, animated: true)
	}

	// MARK: - Upload methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func uploadPicture(image: UIImage) {

		ProgressHUD.show(nil, interaction: false)

		let squared = image.square(to: 300)
		if let data = squared.jpegData(compressionQuality: 0.6) {
			if let encrypted = Cryptor.encrypt(data: data) {
				MediaUpload.user(GQLAuth.userId(), encrypted) { error in
					if (error == nil) {
						self.pictureUploaded(image: squared, data: data)
					} else {
						ProgressHUD.showFailed("Picture upload error.")
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func pictureUploaded(image: UIImage, data: Data) {

		Media.save(userId: GQLAuth.userId(), data: data)

		dbuser.pictureAt = Date().timestamp()

		imageUser.image = image.square(to: 70)
		labelInitials.text = nil

		ProgressHUD.dismiss()
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails() {

		labelPlaceholder.isHidden = (labelCountry.text != "")
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

// MARK: - CountriesDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: CountriesDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectCountry(name: String, code: String) {

		labelCountry.text = name
		updateDetails()

		fieldLocation.becomeFirstResponder()
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 2
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 4 }
		if (section == 1) { return 1 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellFirstname	}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellLastname	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellCountry	}
		if (indexPath.section == 0) && (indexPath.row == 3) { return cellLocation	}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellPhone		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 2) { actionCountries()		}
	}
}

// MARK: - UITextFieldDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UITextFieldDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		if (textField == fieldFirstname)	{ fieldLastname.becomeFirstResponder()	}
		if (textField == fieldLastname)		{ actionCountries()						}
		if (textField == fieldLocation)		{ fieldPhone.becomeFirstResponder()		}
		if (textField == fieldPhone)		{ actionDone()							}

		return true
	}
}
