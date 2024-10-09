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
class DBChannel: NSObject, GQLObject {

	@objc var objectId = ""
	@objc var workspaceId = ""

	@objc var name = ""
	@objc var topic = ""
	@objc var details = ""

	@objc var lastMessageText = ""
	@objc var lastMessageCounter = 0

	@objc var createdBy = ""
	@objc var members: [String] = []
	@objc var typing: [String] = []

	@objc var isDeleted = false
	@objc var isArchived = false

	@objc var createdAt = Date()
	@objc var updatedAt = Date()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "objectId"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBChannel {

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

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBChannel {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(isDeleted value: Bool) {

		if (isDeleted != value) {
			isDeleted = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(isArchived value: Bool) {

		if (isArchived != value) {
			isArchived = value
			updateLazy()
		}
	}
}
