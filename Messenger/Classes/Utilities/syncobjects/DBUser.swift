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
class DBUser: NSObject, GQLObject {

	@objc var objectId = ""

	@objc var email = ""
	@objc var phone = ""

	@objc var firstname = ""
	@objc var lastname = ""
	@objc var fullname = ""
	@objc var country = ""
	@objc var location = ""
	@objc var pictureAt: TimeInterval = 0

	@objc var status = "Available"

	@objc var keepMedia = KeepMedia.Forever
	@objc var networkPhoto = Network.All
	@objc var networkVideo = Network.All
	@objc var networkAudio = Network.All

	@objc var lastActive: TimeInterval = 0
	@objc var lastTerminate: TimeInterval = 0

	@objc var createdAt = Date()
	@objc var updatedAt = Date()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "objectId"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBUser {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func lastActiveText() -> String {

		if (DBRelations.isBlocker(objectId)) {
			return ""
		}

		if (lastActive < lastTerminate) {
			let elapsed = Convert.timestampToElapsed(lastTerminate)
			return "last active: \(elapsed)"
		}

		return "online now"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func initials() -> String {

		let initial1 = (firstname.count != 0) ? firstname.initial() : ""
		let initial2 = (lastname.count != 0) ? lastname.initial() : ""

		return "\(initial1)\(initial2)"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBUser {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func insertLazy() {

		let values = self.values()
		gqldb.insert(table(), values)

		let variables: [String: Any] = ["object": values]
		gqlsync.lazy("CreateDBUser", variables, objectId)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateLazy() {

		updatedAt = Date()

		let values = self.values()
		gqldb.update(table(), values)

		let variables: [String: Any] = ["object": values]
		gqlsync.lazy("UpdateDBUser", variables, objectId)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateForce() {

		updatedAt = Date()

		let values = self.values()
		gqldb.update(table(), values)

		let variables: [String: Any] = ["object": values]
		gqlsync.force("UpdateDBUser", variables)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBUser {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(pictureAt value: TimeInterval) {

		if (pictureAt != value) {
			pictureAt = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(status value: String) {

		if (status != value) {
			status = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(keepMedia value: Int) {

		if (keepMedia != value) {
			keepMedia = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(networkPhoto value: Int) {

		if (networkPhoto != value) {
			networkPhoto = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(networkVideo value: Int) {

		if (networkVideo != value) {
			networkVideo = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(networkAudio value: Int) {

		if (networkAudio != value) {
			networkAudio = value
			updateLazy()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(lastActive value: TimeInterval) {

		if (lastActive != value) {
			lastActive = value
			updateForce()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(lastTerminate value: TimeInterval) {

		if (lastTerminate != value) {
			lastTerminate = value
			updateForce()
		}
	}
}
