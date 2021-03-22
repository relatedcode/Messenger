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
class WelcomeView: UIViewController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLoginEmail(_ sender: Any) {

		let loginEmailView = LoginEmailView()
		loginEmailView.delegate = self
		loginEmailView.isModalInPresentation = true
		loginEmailView.modalPresentationStyle = .fullScreen
		present(loginEmailView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionRegisterEmail(_ sender: Any) {

		let registerEmailView = RegisterEmailView()
		registerEmailView.delegate = self
		registerEmailView.isModalInPresentation = true
		registerEmailView.modalPresentationStyle = .fullScreen
		present(registerEmailView, animated: true)
	}
}

// MARK: - LoginEmailDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension WelcomeView: LoginEmailDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didLoginUserEmail() {

		dismiss(animated: true) {
			Users.loggedIn()
		}
	}
}

// MARK: - RegisterEmailDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension WelcomeView: RegisterEmailDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didRegisterUser() {

		dismiss(animated: true) {
			Users.loggedIn()
		}
	}
}
