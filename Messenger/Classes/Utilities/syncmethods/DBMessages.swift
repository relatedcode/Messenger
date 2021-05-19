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

import UIKit
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class DBMessages: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func send(_ chatId: String, _ text: String?, _ photo: UIImage?, _ video: URL?, _ audio: String?) {

		guard let dbuser = DBUser.fetchOne(gqldb, key: GQLAuth.userId()) else {
			fatalError("Sender user must exists in the local database.") }

		let dbmessage = DBMessage()

		dbmessage.objectId		= UUID().uuidString
		dbmessage.chatId		= chatId

		dbmessage.userId		= dbuser.objectId
		dbmessage.userFullname	= dbuser.fullname
		dbmessage.userInitials	= dbuser.initials()
		dbmessage.userPictureAt	= dbuser.pictureAt

		if let text = text			{ sendMessageText(dbmessage, text)		}
		else if let photo = photo	{ sendMessagePhoto(dbmessage, photo)	}
		else if let video = video	{ sendMessageVideo(dbmessage, video)	}
		else if let audio = audio	{ sendMessageAudio(dbmessage, audio)	}
		else						{ sendMessageLoaction(dbmessage)		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func forward(_ chatId: String, _ dbsource: DBMessage) {

		guard let dbuser = DBUser.fetchOne(gqldb, key: GQLAuth.userId()) else {
			fatalError("Sender user must exists in the local database.") }

		let dbmessage = DBMessage()

		dbmessage.objectId		= UUID().uuidString
		dbmessage.chatId		= chatId

		dbmessage.userId		= dbuser.objectId
		dbmessage.userFullname	= dbuser.fullname
		dbmessage.userInitials	= dbuser.initials()
		dbmessage.userPictureAt	= dbuser.pictureAt

		dbmessage.type			= dbsource.type
		dbmessage.text			= dbsource.text

		dbmessage.photoWidth	= dbsource.photoWidth
		dbmessage.photoHeight	= dbsource.photoHeight
		dbmessage.videoDuration	= dbsource.videoDuration
		dbmessage.audioDuration	= dbsource.audioDuration

		dbmessage.latitude		= dbsource.latitude
		dbmessage.longitude		= dbsource.longitude

		if (dbmessage.type == MessageType.Text)		{ createMessage(dbmessage) }
		if (dbmessage.type == MessageType.Emoji)	{ createMessage(dbmessage) }
		if (dbmessage.type == MessageType.Location)	{ createMessage(dbmessage) }

		if (dbmessage.type == MessageType.Photo)	{ forwardMessagePhoto(dbmessage, dbsource) }
		if (dbmessage.type == MessageType.Video)	{ forwardMessageVideo(dbmessage, dbsource) }
		if (dbmessage.type == MessageType.Audio)	{ forwardMessageAudio(dbmessage, dbsource) }
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBMessages {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageText(_ dbmessage: DBMessage, _ text: String) {

		dbmessage.type = MessageType.Text
		dbmessage.text = text

		if (text.count <= 3) {
			if (text.containsEmojiOnly()) {
				dbmessage.type = MessageType.Emoji
			}
		}

		createMessage(dbmessage)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessagePhoto(_ dbmessage: DBMessage, _ photo: UIImage) {

		dbmessage.type = MessageType.Photo
		dbmessage.text = "Photo message"

		dbmessage.photoWidth = Int(photo.size.width)
		dbmessage.photoHeight = Int(photo.size.height)
		dbmessage.isMediaQueued = true

		if let data = photo.jpegData(compressionQuality: 0.6) {
			Media.save(photoId: dbmessage.objectId, data: data)
			createMessage(dbmessage)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageVideo(_ dbmessage: DBMessage, _ video: URL) {

		dbmessage.type = MessageType.Video
		dbmessage.text = "Video message"

		dbmessage.videoDuration = Video.duration(video.path)
		dbmessage.isMediaQueued = true

		if let data = Data(path: video.path) {
			Media.save(videoId: dbmessage.objectId, data: data)
			createMessage(dbmessage)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageAudio(_ dbmessage: DBMessage, _ audio: String) {

		dbmessage.type = MessageType.Audio
		dbmessage.text = "Audio message"

		dbmessage.audioDuration = Audio.duration(audio)
		dbmessage.isMediaQueued = true

		if let data = Data(path: audio) {
			Media.save(audioId: dbmessage.objectId, data: data)
			createMessage(dbmessage)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageLoaction(_ dbmessage: DBMessage) {

		dbmessage.type = MessageType.Location
		dbmessage.text = "Location message"

		dbmessage.latitude = Location.latitude()
		dbmessage.longitude = Location.longitude()

		createMessage(dbmessage)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBMessages {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func forwardMessagePhoto(_ dbmessage: DBMessage, _ dbsource: DBMessage) {

		dbmessage.isMediaQueued = true

		if let pathSource = Media.path(photoId: dbsource.objectId) {
			let pathMessage = Media.xpath(photoId: dbmessage.objectId)
			File.copy(pathSource, pathMessage, true)
			createMessage(dbmessage)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func forwardMessageVideo(_ dbmessage: DBMessage, _ dbsource: DBMessage) {

		dbmessage.isMediaQueued = true

		if let pathSource = Media.path(videoId: dbsource.objectId) {
			let pathMessage = Media.xpath(videoId: dbmessage.objectId)
			File.copy(pathSource, pathMessage, true)
			createMessage(dbmessage)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func forwardMessageAudio(_ dbmessage: DBMessage, _ dbsource: DBMessage) {

		dbmessage.isMediaQueued = true

		if let pathSource = Media.path(audioId: dbsource.objectId) {
			let pathMessage = Media.xpath(audioId: dbmessage.objectId)
			File.copy(pathSource, pathMessage, true)
			createMessage(dbmessage)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DBMessages {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func createMessage(_ dbmessage: DBMessage) {

		dbmessage.insertLazy()

		if (dbmessage.isMediaQueued) {
			MediaQueue.create(dbmessage)
		}

		Audio.playMessageOutgoing()

		DBDetails.updateAll(chatId: dbmessage.chatId, isDeleted: false)
		DBDetails.updateAll(chatId: dbmessage.chatId, isArchived: false)

		sendPush(dbmessage)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendPush(_ dbmessage: DBMessage) {

		let type = dbmessage.type
		var text = dbmessage.userFullname

		if (type == MessageType.Text)		{ text = text + (" sent you a text message.")	}
		if (type == MessageType.Emoji)		{ text = text + (" sent you an emoji.")			}
		if (type == MessageType.Photo)		{ text = text + (" sent you a photo.")			}
		if (type == MessageType.Video)		{ text = text + (" sent you a video.")			}
		if (type == MessageType.Audio) 		{ text = text + (" sent you an audio.")			}
		if (type == MessageType.Location)	{ text = text + (" sent you a location.")		}

		let chatId = dbmessage.chatId
		var userIds = DBMembers.userIds(chatId)

		for dbdetail in DBDetail.fetchAll(gqldb, "chatId = ?", [chatId]) {
			if (dbdetail.mutedUntil > Date().timestamp()) {
				userIds.remove(dbdetail.userId)
			}
		}
		userIds.remove(GQLAuth.userId())

		GQLPush.send(chatId, userIds, text)
	}
}
