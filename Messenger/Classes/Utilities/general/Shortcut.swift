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
class Shortcut: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanup() {

		UIApplication.shared.shortcutItems?.removeAll()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func create() {

		if (UIApplication.shared.shortcutItems?.count != 0) { return }

		var items: [UIApplicationShortcutItem] = []

		if let item = createItem("newchat", "New Chat", .compose, nil)	{ items.append(item) }
		if let item = createItem("newgroup", "New Group", .add, nil)	{ items.append(item) }
		if let item = createItem("shareapp", "Share Chat", .share, nil)	{ items.append(item) }

		UIApplication.shared.shortcutItems = items
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(_ userId: String) {

		guard let dbuser = DBUser.fetchOne(gqldb, key: userId) else { return }

		var items: [UIApplicationShortcutItem] = []

		let objectId = dbuser.objectId
		let fullname = dbuser.fullname
		let userInfo = ["userId": objectId]

		if let item = createItem("newchat", "New Chat", .compose, nil)			{ items.append(item) }
		if let item = createItem("newgroup", "New Group", .add, nil)			{ items.append(item) }
		if let item = createItem("recentuser", fullname, .contact, userInfo)	{ items.append(item) }
		if let item = createItem("shareapp", "Share Chat", .share, nil)			{ items.append(item) }

		UIApplication.shared.shortcutItems = items
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func createItem(_ type: String, _ title: String, _ iconType: UIApplicationShortcutIcon.IconType, _ userInfo: [String: String]?) -> UIApplicationShortcutItem? {

		let icon = UIApplicationShortcutIcon(type: iconType)

		if let info = userInfo {
			return UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: icon, userInfo: info as [String: NSSecureCoding])
		} else {
			return UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: icon, userInfo: nil)
		}
	}
}
