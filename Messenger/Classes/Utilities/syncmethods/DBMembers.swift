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

import Foundation

//-----------------------------------------------------------------------------------------------------------------------------------------------
class DBMembers: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func create(_ chatId: String, _ userIds: [String]) {

		for userId in userIds {
			update(chatId, userId, isActive: true)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBMembers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(_ chatId: String, _ userId: String, isActive: Bool) {

		let objectId = "\(chatId)-\(userId)".sha1()

		if let dbmember = DBMember.fetchOne(gqldb, key: objectId) {
			dbmember.update(isActive: isActive)
		} else {
			let dbmember = DBMember()
			dbmember.objectId = objectId
			dbmember.chatId = chatId
			dbmember.userId = userId
			dbmember.isActive = isActive
			dbmember.insertLazy()
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBMembers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func userIds(_ chatId: String) -> [String] {

		var userIds: [String] = []

		for dbmember in DBMember.fetchAll(gqldb, "chatId = ? AND isActive = ?", [chatId, true]) {
			userIds.append(dbmember.userId)
		}

		return userIds
	}
}
