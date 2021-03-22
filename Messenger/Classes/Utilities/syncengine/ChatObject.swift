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
class ChatObject: NSObject, GQLObject {

	@objc var objectId = ""

	@objc var isGroup = false
	@objc var isPrivate = false

	@objc var details = ""
	@objc var initials = ""

	@objc var userId = ""
	@objc var pictureAt: TimeInterval = 0

	@objc var lastMessageId = ""
	@objc var lastMessageText = ""
	@objc var lastMessageAt: TimeInterval = 0

	@objc var typing = false
	@objc var typingUsers = ""

	@objc var lastRead: TimeInterval = 0
	@objc var mutedUntil: TimeInterval = 0
	@objc var unreadCount = 0

	@objc var isDeleted = false
	@objc var isArchived = false

	@objc var isGroupDeleted = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "objectId"
	}
}
