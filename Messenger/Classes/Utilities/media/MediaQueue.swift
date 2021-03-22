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
class MediaQueue: NSObject, GQLObject {

	@objc var objectId = ""

	@objc var isQueued = true
	@objc var isFailed = false

	@objc var updatedAt: Double = Date().timeIntervalSince1970

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "objectId"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaQueue {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func create(_ dbmessage: DBMessage) {

		let mediaQueue = MediaQueue()
		mediaQueue.objectId = dbmessage.objectId
		mediaQueue.insert(gqldb)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func restart(_ objectId: String) {

		if let mediaQueue = MediaQueue.fetchOne(gqldb, key: objectId) {
			mediaQueue.update(isFailed: false)
		}
		if let dbmessage = DBMessage.fetchOne(gqldb, key: objectId) {
			dbmessage.update(isMediaFailed: false)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaQueue {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(isQueued value: Bool) {

		if (isQueued != value) {
			isQueued = value
			update(gqldb)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func update(isFailed value: Bool) {

		if (isFailed != value) {
			isFailed = value
			update(gqldb)
		}
	}
}
