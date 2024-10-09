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
class NavigationController: UINavigationController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		isModalInPresentation = true
		modalPresentationStyle = .fullScreen

		navigationBar.isTranslucent = true

		navigationBar.tintColor = AppColor.second
		navigationBar.barTintColor = AppColor.main
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColor.second]

		if #available(iOS 15, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.backgroundColor = AppColor.main
			appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppColor.second]
			UINavigationBar.appearance().standardAppearance = appearance
			UINavigationBar.appearance().scrollEdgeAppearance = appearance
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

		return .portrait
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {

		return .portrait
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override var shouldAutorotate: Bool {

		return false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override var preferredStatusBarStyle: UIStatusBarStyle {

		return .lightContent
	}
}
