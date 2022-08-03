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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class WelcomeView: UIViewController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLogin(_ sender: Any) {

		let loginView = LoginView()
		loginView.delegate = self
		loginView.isModalInPresentation = true
		loginView.modalPresentationStyle = .fullScreen
		present(loginView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionRegister(_ sender: Any) {

		let registerView = RegisterView()
		registerView.isModalInPresentation = true
		registerView.modalPresentationStyle = .fullScreen
		present(registerView, animated: true)
	}
}

// MARK: - LoginEmailDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension WelcomeView: LoginDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didLoginUser() {

		dismiss(animated: true) {
			Users.loggedIn()
		}
	}
}
