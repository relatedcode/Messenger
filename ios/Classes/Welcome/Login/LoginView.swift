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
protocol LoginDelegate: AnyObject {

	func didLoginUser()
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class LoginView: UIViewController {

	weak var delegate: LoginDelegate?

	@IBOutlet private var fieldEmail: UITextField!
	@IBOutlet private var fieldPassword: UITextField!

	@IBOutlet private var buttonLogin: UIButton!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		buttonLogin.backgroundColor = AppColor.main

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
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension LoginView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionDismiss(_ sender: Any) {

		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLogin(_ sender: Any) {

		let email = (fieldEmail.text ?? "").lowercased()
		let password = fieldPassword.text ?? ""

		if (email.isEmpty)		{ ProgressHUD.failed("Please enter your email.");		return }
		if (password.isEmpty)	{ ProgressHUD.failed("Please enter your password.");	return }

		actionLogin(email, password)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionLogin(_ email: String, _ password: String) {

		ProgressHUD.animate(interaction: false)

		GQLAuth.login(email, password) { error in
			if (error == nil) {
				self.checkUser(email)
			} else {
				self.showError(error)
			}
		}
	}
}

// MARK: -
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension LoginView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func checkUser(_ email: String) {

		let query = GQLQuery["GetUser"]
		let variables = ["objectId": GQLAuth.userId()]

		gqlserver.sendAuth(query, variables) { result, error in
			DispatchQueue.main.async {
				if (error == nil) {
					self.updateUser(result)
				} else {
					self.showError(error)
					self.logoutUser()
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateUser(_ result: [String: Any]) {

		if let values = result.values.first as? [String: Any] {
			gqldb.updateInsert("DBUser", values)
			loginSucceed()
		} else {
			logoutUser()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loginSucceed() {

		dismiss(animated: true) {
			self.delegate?.didLoginUser()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func logoutUser() {

		GQLAuth.logout { error in
			self.showError(error)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func showError(_ error: Error?) {

		if let error = error {
			ProgressHUD.failed(error)
		}
	}
}

// MARK: - UITextFieldDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension LoginView: UITextFieldDelegate {

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
