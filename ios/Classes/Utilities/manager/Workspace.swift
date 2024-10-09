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
class Workspace {

	private static var initialized = false

	private static var workspaceId = ""

	static let shared = Workspace()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Workspace {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func id() -> String {

		loadCache()
		return workspaceId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func save(_ newId: String) {

		workspaceId = newId
		saveCache()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Workspace {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func loadCache() {

		if (initialized) { return }

		if let temp = UserDefaults.string(key: "WorkspaceId") {
			workspaceId = temp
		}

		initialized = true
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func saveCache() {

		UserDefaults.setObject(workspaceId, key: "WorkspaceId")
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Workspace {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanup() {

		workspaceId = ""
		saveCache()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Workspace {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func select(_ viewController: UIViewController) {

		DispatchQueue.main.async(after: 0.5) {
			let workspacesView = WorkspacesView()
			let navController = NavigationController(rootViewController: workspacesView)
			navController.isModalInPresentation = true
			navController.modalPresentationStyle = .fullScreen
			viewController.present(navController, animated: true)
		}
	}
}
