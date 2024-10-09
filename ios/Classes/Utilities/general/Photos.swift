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

import UIKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Photos {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func collect(_ chatId: String) -> [PhotoObject]? {

		var objects: [PhotoObject] = []
		
		let condition = "chatId = :chatId AND type = :type AND isDeleted = :false"
		let arguments: [String: Any] = [":chatId": chatId, ":type": "photo", ":false": false]
		let dbmessages = DBMessage.fetchAll(gqldb, condition, arguments, order: "createdAt")

		for dbmessage in dbmessages {
			if let path = Media.path(photo: dbmessage.fileURL) {
				if let image = UIImage(path: path) {

					let dbuser = DBUser.fetchOne(gqldb, key: dbmessage.senderId)
					let title = dbuser?.fullName ?? "Unknown User"
					let details = Convert.dateToDayMonthTime(dbmessage.createdAt)

					let object = PhotoObject(dbmessage.objectId, image, title, details)
					objects.append(object)
				}
			}
		}

		return objects.isEmpty ? nil : objects
	}
}
