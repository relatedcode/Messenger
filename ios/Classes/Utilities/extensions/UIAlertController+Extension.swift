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
import DeviceKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIAlertController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func action(_ title: String?, _ style: UIAlertAction.Style, _ handler: ((UIAlertAction) -> Void)? = nil) {

		self.addAction(UIAlertAction(title: title, style: style, handler: handler))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionCancel(_ handler: ((UIAlertAction) -> Void)? = nil) {

		let style: UIAlertAction.Style = Device.current.isPhone ? .cancel : .destructive

		self.addAction(UIAlertAction(title: "Cancel", style: style, handler: handler))
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIAlertController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func topLeft(_ navigationController: UINavigationController?) {

		popover(navigationController, 40, 70)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func topRight(_ navigationController: UINavigationController?) {

		popover(navigationController, Screen.width - 40, 70)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func topCenter(_ navigationController: UINavigationController?) {

		popover(navigationController, Screen.width / 2, 70)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bottomCenter(_ navigationController: UINavigationController?) {

		popover(navigationController, Screen.width / 2, Screen.height - 70)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIAlertController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func popover(_ navigationController: UINavigationController?, _ x: CGFloat, _ y: CGFloat) {

		guard (Device.current.isPad) else { return }

		self.modalPresentationStyle = .popover
		let popover = self.popoverPresentationController
		popover?.sourceView = navigationController?.view
		popover?.sourceRect = CGRect(x: x, y: y, width: 0, height: 0)
	}
}
