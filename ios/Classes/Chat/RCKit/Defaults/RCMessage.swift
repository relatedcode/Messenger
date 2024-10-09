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
import CoreLocation

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCMessage: NSObject {

	var chatId = ""
	var messageId = ""

	var counter = 0

	var userId = ""
	var userFullname = ""
	var userInitials = ""
	var userThumbnail = ""

	var text = ""
	var type = ""

	var fileURL = ""
	var fileType = ""
	var fileName = ""
	var fileSize = 0

	var mediaWidth = 0
	var mediaHeight = 0
	var mediaDuration = 0

	var thumbnailURL = ""

	var sticker = ""

	var createdAt: TimeInterval = 0

	var incoming = false
	var outgoing = false

	var videoPath: String?
	var audioPath: String?

	var animData: Data?
	var photoImage: UIImage?
	var stickerImage: UIImage?
	var videoThumbnail: UIImage?

	var audioStatus = AudioStatus.Stopped
	var mediaStatus = MediaStatus.Unknown

	var audioCurrent: TimeInterval = 0

	var sizeBubble = CGSize.zero

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ dbmessage: DBMessage) {

		super.init()

		chatId = dbmessage.chatId
		messageId = dbmessage.objectId

		counter = dbmessage.counter

		userId = dbmessage.senderId

		if let dbuser = DBUser.fetchOne(gqldb, key: userId) {
			userFullname = dbuser.fullName
			userInitials = dbuser.initials()
			userThumbnail = dbuser.thumbnailURL
		}

		text = dbmessage.text.removeHTML()
		type = dbmessage.type

		if (type == MessageType.Text) && (text.count < 4) {
			if (text.containsEmojiOnly()) {
				type = MessageType.Emoji
			}
		}

		if (type == MessageType.File) {
			type = MessageType.Text
			let name = dbmessage.fileName
			let size = dbmessage.fileSize
			text = "File: \(name) (\(size) bytes)"
		}

		fileURL = dbmessage.fileURL
		fileType = dbmessage.fileType
		fileName = dbmessage.fileName
		fileSize = dbmessage.fileSize

		mediaWidth = dbmessage.mediaWidth
		mediaHeight = dbmessage.mediaHeight
		mediaDuration = dbmessage.mediaDuration

		thumbnailURL = dbmessage.thumbnailURL

		sticker = dbmessage.sticker

		createdAt = dbmessage.createdAt.timestamp()

		incoming = dbmessage.incoming()
		outgoing = dbmessage.outgoing()
	}
}
