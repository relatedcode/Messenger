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
class DBDetail: NSObject, GQLObject {

	@objc var objectId = ""

	@objc var chatId = ""
	@objc var userId = ""

	@objc var typing = false
	@objc var lastRead: TimeInterval = 0
	@objc var mutedUntil: TimeInterval = 0

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
extension DBDetail {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func insertLazy() {

		let values = self.values()
		gqldb.insert(table(), values)

		let variables: [String: Any] = ["object": values]
		gqlsync.lazy("CreateDBDetail", variables, objectId)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateLazy() {

		updatedAt = Date()

		let values = self.values()
		gqldb.update(table(), values)

		let variables: [String: Any] = ["object": values]
		gqlsync.lazy("UpdateDBDetail", variables, objectId)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBDetail {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(typing value: Bool) {

		if (typing != value) {
			typing = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(lastRead value: TimeInterval) {

		if (lastRead != value) {
			lastRead = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(mutedUntil value: TimeInterval) {

		if (mutedUntil != value) {
			mutedUntil = value
			updateLazy()
		}
	}

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
