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
class DBDirect: NSObject, GQLObject {

	@objc var objectId = ""
	@objc var workspaceId = ""

	@objc var lastMessageText = ""
	@objc var lastMessageCounter = 0

	@objc var members: [String] = []
	@objc var active: [String] = []
	@objc var typing: [String] = []

	@objc var createdAt = Date()
	@objc var updatedAt = Date()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "objectId"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBDirect {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func userId() -> String {

		let currentId = GQLAuth.userId()

		for userId in members {
			if (userId != currentId) {
				return userId
			}
		}
		return currentId
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBDirect {

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
