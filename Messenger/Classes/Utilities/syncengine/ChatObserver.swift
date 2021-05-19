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
class ChatObserver: NSObject {

	private var observerIdGroup: String?
	private var observerIdSingle: String?
	private var observerIdDetail: String?
	private var observerIdMessage: String?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: ChatObserver = {
		let instance = ChatObserver()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenter.addObserver(self, selector: #selector(initObservers), text: Notifications.UserLoggedIn)
		NotificationCenter.addObserver(self, selector: #selector(stopObservers), text: Notifications.UserLoggedOut)

		initObservers()
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func initObservers() {

		if (GQLAuth.userId() != "") {
			if (observerIdGroup == nil)		{ observerGroups()	}
			if (observerIdSingle == nil)	{ observerSingles() }
			if (observerIdDetail == nil)	{ observerDetails()	}
			if (observerIdMessage == nil)	{ observerMessages() }
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func stopObservers() {

		DBGroup.removeObserver(gqldb, observerIdGroup)
		DBSingle.removeObserver(gqldb, observerIdSingle)
		DBDetail.removeObserver(gqldb, observerIdDetail)
		DBMessage.removeObserver(gqldb, observerIdMessage)

		observerIdGroup = nil
		observerIdSingle = nil
		observerIdDetail = nil
		observerIdMessage = nil
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func observerGroups() {

		let types: [GQLObserverType] = [.insert, .update]

		observerIdGroup = DBGroup.createObserver(gqldb, types) { method, objectId in
			DispatchQueue.main.async {
				if let dbgroup = DBGroup.fetchOne(gqldb, key: objectId) {
					self.update(with: dbgroup)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func observerSingles() {

		let types: [GQLObserverType] = [.insert, .update]

		observerIdSingle = DBSingle.createObserver(gqldb, types) { method, objectId in
			DispatchQueue.main.async {
				if let dbsingle = DBSingle.fetchOne(gqldb, key: objectId) {
					self.update(with: dbsingle)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func observerDetails() {

		let types: [GQLObserverType] = [.insert, .update]

		observerIdDetail = DBDetail.createObserver(gqldb, types) { method, objectId in
			DispatchQueue.main.async(after: 0.2) {
				if let dbdetail = DBDetail.fetchOne(gqldb, key: objectId) {
					self.update(with: dbdetail)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func observerMessages() {

		let types: [GQLObserverType] = [.insert, .update]

		observerIdMessage = DBMessage.createObserver(gqldb, types) { method, objectId in
			DispatchQueue.main.async(after: 0.4) {
				if let dbmessage = DBMessage.fetchOne(gqldb, key: objectId) {
					self.update(with: dbmessage)
				}
			}
		}
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatObserver {

	// MARK: - Update with Group
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(with dbgroup: DBGroup) {

		let chatId = dbgroup.chatId
		let chatObject = ChatObject.fetchOne(gqldb, key: chatId) ?? ChatObject()

		chatObject.objectId		= chatId
		chatObject.isGroup		= true
		chatObject.isPrivate	= false

		chatObject.details		= dbgroup.name
		chatObject.initials		= dbgroup.name.initial()

		chatObject.isGroupDeleted = dbgroup.isDeleted

		chatObject.updateInsert(gqldb)
	}

	// MARK: - Update with Single
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(with dbsingle: DBSingle) {

		let userId = GQLAuth.userId()

		let chatId = dbsingle.chatId
		let chatObject = ChatObject.fetchOne(gqldb, key: chatId) ?? ChatObject()

		chatObject.objectId		= chatId
		chatObject.isGroup		= false
		chatObject.isPrivate	= true

		if (dbsingle.userId1 == userId) {
			chatObject.details		= dbsingle.fullname2
			chatObject.initials		= dbsingle.initials2
			chatObject.userId		= dbsingle.userId2
			chatObject.pictureAt	= dbsingle.pictureAt2
		}

		if (dbsingle.userId1 != userId) {
			chatObject.details		= dbsingle.fullname1
			chatObject.initials		= dbsingle.initials1
			chatObject.userId		= dbsingle.userId1
			chatObject.pictureAt	= dbsingle.pictureAt1
		}

		chatObject.updateInsert(gqldb)
	}

	// MARK: - Update with Detail
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(with dbdetail: DBDetail) {

		if (dbdetail.userId == GQLAuth.userId()) {
			update(owned: dbdetail)
		} else {
			update(other: dbdetail)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(owned dbdetail: DBDetail) {

		let chatId = dbdetail.chatId
		let chatObject = ChatObject.fetchOne(gqldb, key: chatId) ?? ChatObject()

		chatObject.objectId = chatId

		if (dbdetail.lastRead > chatObject.lastRead) {
			chatObject.unreadCount = 0
		}

		chatObject.lastRead		= dbdetail.lastRead
		chatObject.mutedUntil	= dbdetail.mutedUntil
		chatObject.isDeleted	= dbdetail.isDeleted
		chatObject.isArchived	= dbdetail.isArchived

		chatObject.updateInsert(gqldb)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(other dbdetail: DBDetail) {

		let chatId = dbdetail.chatId
		let chatObject = ChatObject.fetchOne(gqldb, key: chatId) ?? ChatObject()

		chatObject.objectId = chatId

		var typingUsers = chatObject.typingUsers.components(separatedBy: ",")
		typingUsers.remove("")
		let typingCount = typingUsers.count

		if (dbdetail.typing) {
			typingUsers.appendUnique(dbdetail.userId)
		} else {
			typingUsers.remove(dbdetail.userId)
		}

		if (typingUsers.count != typingCount) {
			chatObject.typing = (typingUsers.count != 0)
			chatObject.typingUsers = typingUsers.joined(separator: ",")
			chatObject.updateInsert(gqldb)
		}
	}

	// MARK: - Update with Message
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(with dbmessage: DBMessage) {

		if (dbmessage.isDeleted) {
			update(deleted: dbmessage)
		} else {
			update(active: dbmessage)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(active dbmessage: DBMessage) {

		guard let chatObject = ChatObject.fetchOne(gqldb, key: dbmessage.chatId) else { return }

		let unread = unreadCount(chatObject, dbmessage)
		if (dbmessage.createdAt.timestamp() > chatObject.lastMessageAt) {
			update(chatObject, dbmessage, unread)
		} else {
			update(chatObject, nil, unread)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(deleted dbmessage: DBMessage) {

		guard let chatObject = ChatObject.fetchOne(gqldb, key: dbmessage.chatId) else { return }

		let unread = unreadCount(chatObject, dbmessage)
		if (dbmessage.objectId == chatObject.lastMessageId) {
			if let dbmessage = lastMessage(dbmessage.chatId) {
				update(chatObject, dbmessage, unread)
			} else {
				update(chatObject)
			}
		} else {
			update(chatObject, nil, unread)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(_ chatObject: ChatObject, _ dbmessage: DBMessage?, _ unread: Int?) {

		if let dbmessage = dbmessage {
			chatObject.lastMessageId	= dbmessage.objectId
			chatObject.lastMessageText	= dbmessage.text
			chatObject.lastMessageAt	= dbmessage.createdAt.timestamp()
		}

		if let unread = unread {
			chatObject.unreadCount = unread
		}

		if (dbmessage != nil) || (unread != nil) {
			chatObject.update(gqldb)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func update(_ chatObject: ChatObject) {

		chatObject.lastMessageId	= ""
		chatObject.lastMessageText	= ""
		chatObject.lastMessageAt	= 0
		chatObject.unreadCount		= 0

		chatObject.update(gqldb)
	}
}

// MARK: - Helper methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatObserver {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func lastMessage(_ chatId: String) -> DBMessage? {

		return DBMessage.fetchOne(gqldb, "chatId = ? AND isDeleted = ?", [chatId, false], order: "createdAt DESC")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unreadCount(_ chatObject: ChatObject, _ dbmessage: DBMessage) -> Int? {

		let lastRead = Date(timestamp: chatObject.lastRead)

		if (dbmessage.userId == GQLAuth.userId()) { return nil }
		if (dbmessage.createdAt <= lastRead) { return nil }

		let condition = "chatId = ? AND userId != ? AND createdAt > ? AND isDeleted = ?"
		let arguments: [Any] = [chatObject.objectId, GQLAuth.userId(), lastRead, false]

		return DBMessage.count(gqldb, condition, arguments)
	}
}
