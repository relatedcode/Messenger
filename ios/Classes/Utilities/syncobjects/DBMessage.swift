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

import Foundation
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class DBMessage: NSObject, GQLObject {

	@objc var objectId = ""
	@objc var workspaceId = ""

	@objc var chatId = ""
	@objc var chatType = ""

	@objc var senderId = ""
	@objc var counter = 0

	@objc var text = ""
	@objc var type = ""

	@objc var fileURL = ""
	@objc var fileType = ""
	@objc var fileName = ""
	@objc var fileSize = 0

	@objc var mediaWidth = 0
	@objc var mediaHeight = 0
	@objc var mediaDuration = 0

	@objc var thumbnailURL = ""

	@objc var sticker = ""

	@objc var isEdited = false
	@objc var isDeleted = false

	@objc var createdAt = Date()
	@objc var updatedAt = Date()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "objectId"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBMessage {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func incoming() -> Bool {

		return (senderId != GQLAuth.userId())
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func outgoing() -> Bool {

		return (senderId == GQLAuth.userId())
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBMessage {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func insertLazy() {

		let values = self.values()
		gqldb.insert(table(), values)

		//fibsync.lazy(table(), values, objectId)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateLazy() {

		updatedAt = Date()

		let values = self.values()
		gqldb.update(table(), values)

		//fibsync.lazy(table(), values, objectId)
	}
}
