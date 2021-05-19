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
@objc protocol LoginEmailDelegate: AnyObject {

	func didLoginUserEmail()
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class LoginEmailView: UIViewController {

	@IBOutlet weak var delegate: LoginEmailDelegate?

	@IBOutlet private var fieldEmail: UITextField!
	@IBOutlet private var fieldPassword: UITextField!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(gestureRecognizer)
		gestureRecognizer.cancelsTouchesInView = false
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

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionDismiss(_ sender: Any) {

		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLogin(_ sender: Any) {

		let email = (fieldEmail.text ?? "").lowercased()
		let password = fieldPassword.text ?? ""


		if (email.isEmpty)		{ ProgressHUD.showFailed("Please enter your email.");		return }
		if (password.isEmpty)	{ ProgressHUD.showFailed("Please enter your password.");	return }

		actionLogin(email, password)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionLogin(_ email: String, _ password: String) {

		ProgressHUD.show(nil, interaction: false)

		GQLAuth.signIn(email: email, password: password) { error in
			if let error = error {
				ProgressHUD.showFailed(error.localizedDescription)
			} else {
				self.checkUser(email)
			}
		}
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func checkUser(_ email: String) {

		let query = GQLQuery["DBUserFetch"]
		let userId = GQLAuth.userId()
		let variables = ["objectId": userId]

		gqlserver.query(query, variables) { result, error in
			if let error = error {
				GQLAuth.signOut()
				ProgressHUD.showFailed(error.localizedDescription)
			} else {
				self.checkUser(email, result)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func checkUser(_ email: String, _ result: [String: Any]) {

		if let dictionary = result.values.first as? [String: Any] {
			if let array = dictionary["items"] as? [[String: Any]] {
				if let values = array.first {
					updateUser(values)
				} else {
					createUser(email)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateUser(_ values: [String: Any]) {

		gqldb.updateInsert("DBUser", values)

		DispatchQueue.main.async {
			self.loginSucceed()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createUser(_ email: String) {

		let userId = GQLAuth.userId()
		DBUsers.create(userId, email)

		DispatchQueue.main.async {
			self.loginSucceed()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loginSucceed() {

		dismiss(animated: true) {
			self.delegate?.didLoginUserEmail()
		}
	}
}

// MARK: - UITextFieldDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension LoginEmailView: UITextFieldDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		if (textField == fieldEmail) {
			fieldPassword.becomeFirstResponder()
		}
		if (textField == fieldPassword) {
			actionLogin(0)
		}
		return true
	}
}
