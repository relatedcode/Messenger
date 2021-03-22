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

		if let item = createItem(type: "newchat", title: "New Chat", iconType: .compose, userInfo: nil)		{ items.append(item) }
		if let item = createItem(type: "newgroup", title: "New Group", iconType: .add, userInfo: nil)		{ items.append(item) }
		if let item = createItem(type: "shareapp", title: "Share Chat", iconType: .share, userInfo: nil)	{ items.append(item) }

		UIApplication.shared.shortcutItems = items
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(userId: String) {

		guard let dbuser = DBUser.fetchOne(gqldb, key: userId) else { return }

		var items: [UIApplicationShortcutItem] = []

		let objectId = dbuser.objectId
		let fullname = dbuser.fullname
		let userInfo = ["userId": objectId]

		if let item = createItem(type: "newchat", title: "New Chat", iconType: .compose, userInfo: nil)			{ items.append(item) }
		if let item = createItem(type: "newgroup", title: "New Group", iconType: .add, userInfo: nil)			{ items.append(item) }
		if let item = createItem(type: "recentuser", title: fullname, iconType: .contact, userInfo: userInfo)	{ items.append(item) }
		if let item = createItem(type: "shareapp", title: "Share Chat", iconType: .share, userInfo: nil)		{ items.append(item) }

		UIApplication.shared.shortcutItems = items
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func createItem(type: String, title: String, iconType: UIApplicationShortcutIcon.IconType, userInfo: [String: String]?) -> UIApplicationShortcutItem? {

		let icon = UIApplicationShortcutIcon(type: iconType)

		if let info = userInfo {
			return UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: icon, userInfo: info as [String: NSSecureCoding])
		} else {
			return UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: icon, userInfo: nil)
		}
	}
}
