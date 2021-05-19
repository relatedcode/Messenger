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
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class DBDetails: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func create(_ chatId: String, _ userIds: [String]) {

		for userId in userIds {
			create(chatId, userId)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func create(_ chatId: String, _ userId: String) {

		let objectId = "\(chatId)-\(userId)".sha1()

		if (DBDetail.fetchOne(gqldb, key: objectId) == nil) {
			let dbdetail = DBDetail()
			dbdetail.objectId = objectId
			dbdetail.chatId = chatId
			dbdetail.userId = userId
			dbdetail.insertLazy()
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBDetails {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(chatId: String, mutedUntil: TimeInterval) {

		let userId = GQLAuth.userId()
		let objectId = "\(chatId)-\(userId)".sha1()

		if let dbdetail = DBDetail.fetchOne(gqldb, key: objectId) {
			dbdetail.update(mutedUntil: mutedUntil)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(chatId: String, isDeleted: Bool) {

		let userId = GQLAuth.userId()
		let objectId = "\(chatId)-\(userId)".sha1()

		if let dbdetail = DBDetail.fetchOne(gqldb, key: objectId) {
			dbdetail.update(isDeleted: isDeleted)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(chatId: String, isArchived: Bool) {

		let userId = GQLAuth.userId()
		let objectId = "\(chatId)-\(userId)".sha1()

		if let dbdetail = DBDetail.fetchOne(gqldb, key: objectId) {
			dbdetail.update(isArchived: isArchived)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBDetails {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func updateAll(chatId: String, isDeleted: Bool) {

		for dbdetail in DBDetail.fetchAll(gqldb, "chatId = ?", [chatId]) {
			dbdetail.update(isDeleted: isDeleted)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func updateAll(chatId: String, isArchived: Bool) {

		for dbdetail in DBDetail.fetchAll(gqldb, "chatId = ?", [chatId]) {
			dbdetail.update(isArchived: isArchived)
		}
	}
}
