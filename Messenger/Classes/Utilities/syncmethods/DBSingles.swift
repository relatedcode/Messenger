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
class DBSingles: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func create(_ userId2: String) -> String {

		let userId1 = GQLAuth.userId()
		let userIds = [userId1, userId2]

		let objectId = chatId(userId1, userId2)
		if (DBSingle.fetchOne(gqldb, key: objectId) != nil) {
			return objectId
		}

		guard let dbuser1 = DBUser.fetchOne(gqldb, key: userId1) else { fatalError("Sender user must exists in the local database.")	 }
		guard let dbuser2 = DBUser.fetchOne(gqldb, key: userId2) else { fatalError("Recipient user must exists in the local database.") }

		DBDetails.create(objectId, userIds)
		DBMembers.create(objectId, userIds)

		let dbsingle = DBSingle()

		dbsingle.objectId	= objectId
		dbsingle.chatId		= objectId

		dbsingle.userId1	= dbuser1.objectId
		dbsingle.fullname1	= dbuser1.fullname
		dbsingle.initials1	= dbuser1.initials()
		dbsingle.pictureAt1	= dbuser1.pictureAt

		dbsingle.userId2	= dbuser2.objectId
		dbsingle.fullname2	= dbuser2.fullname
		dbsingle.initials2	= dbuser2.initials()
		dbsingle.pictureAt2	= dbuser2.pictureAt

		dbsingle.insertLazy()

		return objectId
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBSingles {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func chatId(_ userId2: String) -> String {

		let userId1 = GQLAuth.userId()

		return chatId(userId1, userId2)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func chatId(_ userId1: String, _ userId2: String) -> String {

		let userIds = [userId1, userId2]

		let sorted = userIds.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
		let joined = sorted.joined(separator: "")

		return joined.sha1()
	}
}
