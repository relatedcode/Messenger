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
class DBRelation: NSObject, GQLObject {

	@objc var objectId = ""

	@objc var userId1 = ""
	@objc var userId2 = ""

	@objc var isFriend = false
	@objc var isBlocked = false

	@objc var createdAt = Date()
	@objc var updatedAt = Date()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "objectId"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBRelation {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func insertLazy() {

		let values = self.values()
		gqldb.insert(table(), values)

		let variables: [String: Any] = ["object": values]
		gqlsync.lazy("CreateDBRelation", variables, objectId)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateLazy() {

		updatedAt = Date()

		let values = self.values()
		gqldb.update(table(), values)

		let variables: [String: Any] = ["object": values]
		gqlsync.lazy("UpdateDBRelation", variables, objectId)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBRelation {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(isFriend value: Bool) {

		if (isFriend != value) {
			isFriend = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(isBlocked value: Bool) {

		if (isBlocked != value) {
			isBlocked = value
			updateLazy()
		}
	}
}
