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
import ProgressHUD
import CoreLocation
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ChatGroupView: RCMessagesView, UIGestureRecognizerDelegate {

	private var chatId = ""

	private var dbdetail: DBDetail?

	private var observerIdDetail: String?
	private var observerIdMessage: String?

	private var dbmessages: [DBMessage] = []
	private var rcmessages: [String: RCMessage] = [:]
	private var avatarImages: [String: UIImage] = [:]

	private var messageToDisplay = 12

	private var typingUsers: [String] = []
	private var typingCounter = 0
	private var lastRead: TimeInterval = 0

	private var indexForward: IndexPath?

	private var audioController: RCAudioController?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ chatId: String) {

		super.init(nibName: "RCMessagesView", bundle: nil)

		self.chatId = chatId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()


		navigationController?.interactivePopGestureRecognizer?.delegate = self

		NotificationCenter.addObserver(self, selector: #selector(actionCleanup), text: Notifications.CleanupChatView)

		loadDetail()
		loadDetails()
		observerDetails()

		loadMessages()
		observerMessages()

		audioController = RCAudioController(self)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		updateTitleDetails()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidDisappear(_ animated: Bool) {

		super.viewDidDisappear(animated)

		if (isMovingFromParent) {
			actionCleanup()
		}
	}

	// MARK: - Title details methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateTitleDetails() {

		if let dbgroup = DBGroup.fetchOne(gqldb, key: chatId) {
			labelTitle1.text = dbgroup.name
			labelTitle2.text = "\(dbgroup.members) members"
		}
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadDetail() {

		dbdetail = DBDetail.fetchOne(gqldb, "chatId = ? AND userId = ?", [chatId, GQLAuth.userId()])
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadDetails() {

		for dbdetail in DBDetail.fetchAll(gqldb, "chatId = ? AND userId != ?", [chatId, GQLAuth.userId()]) {
			refreshDetail(dbdetail)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func observerDetails() {

		let types: [GQLObserverType] = [.insert, .update]
		let condition = String(format: "OBJ.chatId = '%@' AND OBJ.userId != '%@'", chatId, GQLAuth.userId())

		observerIdDetail = DBDetail.createObserver(gqldb, types, condition) { method, objectId in
			DispatchQueue.main.async {
				if let dbdetail = DBDetail.fetchOne(gqldb, key: objectId) {
					self.refreshDetail(dbdetail)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadMessages() {

		dbmessages = DBMessage.fetchAll(gqldb, "chatId = ? AND isDeleted = ?", [chatId, false], order: "createdAt")

		refreshLoadEarlier()
		refreshTableView()
		positionToBottom()
		updateLastRead()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func observerMessages() {

		let types: [GQLObserverType] = [.insert, .update]
		let condition = String(format: "OBJ.chatId = '%@'", chatId)

		observerIdMessage = DBMessage.createObserver(gqldb, types, condition) { method, objectId in
			DispatchQueue.main.async {
				if let dbmessage = DBMessage.fetchOne(gqldb, key: objectId) {
					if (method == "INSERT") { self.messageInsert(dbmessage) }
					if (method == "UPDATE") { self.messageUpdate(dbmessage) }
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func messageInsert(_ dbmessage: DBMessage) {

		dbmessages.append(dbmessage)
		messageToDisplay += 1

		refreshTableView()
		scrollToBottom()

		if (dbmessage.incoming()) {
			Audio.playMessageIncoming()
			updateLastRead()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func messageUpdate(_ dbmessage: DBMessage) {

		if let index = indexOf(dbmessage) {
			if (dbmessage.isDeleted == false) {
				dbmessages[index] = dbmessage
			}
			if (dbmessage.isDeleted == true) {
				dbmessages.remove(at: index)
				messageToDisplay -= 1
			}
			refreshTableView()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func indexOf(_ dbcheck: DBMessage) -> Int? {

		var index = 0
		for dbmessage in dbmessages {
			if (dbmessage.objectId == dbcheck.objectId) {
				return index
			}
			index += 1
		}
		return nil
	}

	// MARK: - Typing indicator methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func typingIndicatorUpdate() {

		typingCounter += 1
		dbdetail?.update(typing: true)

		DispatchQueue.main.async(after: 2.0) {
			self.typingIndicatorStop()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorStop() {

		typingCounter -= 1
		if (typingCounter == 0) {
			dbdetail?.update(typing: false)
		}
	}

	// MARK: - Load earlier methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func actionLoadEarlier() {

		messageToDisplay += 12
		refreshLoadEarlier()
		refreshTableView(keepOffset: true)
	}

	// MARK: - Refresh methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshLoadEarlier() {

		loadEarlierShow(messageToDisplay < messageTotalCount())
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateLastRead() {

		dbdetail?.update(lastRead: Date().timestamp())
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshDetail(_ dbdetail: DBDetail) {

		if (dbdetail.lastRead > lastRead) {
			lastRead = dbdetail.lastRead
			refreshTableView()
		}

		if (dbdetail.typing) {
			typingUsers.append(dbdetail.userId)
		} else {
			typingUsers.remove(dbdetail.userId)
		}
		typingIndicatorShow(typingUsers.count != 0)
	}

	// MARK: - Message sending methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func messageSend(text: String?, photo: UIImage?, video: URL?, audio: String?) {

		DBMessages.send(chatId, text, photo, video, audio)
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func actionTitle() {

		let groupDetailsView = GroupDetailsView(chatId)
		navigationController?.pushViewController(groupDetailsView, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionAudio() {

		let audioView = AudioView()
		audioView.delegate = self
		let navController = NavigationController(rootViewController: audioView)
		navController.isModalInPresentation = true
		navController.modalPresentationStyle = .fullScreen
		present(navController, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionStickers() {

		let stickersView = StickersView()
		stickersView.delegate = self
		let navController = NavigationController(rootViewController: stickersView)
		present(navController, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionLocation() {

		messageSend(text: nil, photo: nil, video: nil, audio: nil)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionResendMedia(_ rcmessage: RCMessage) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Resend", style: .destructive) { action in
			MediaQueue.restart(rcmessage.messageId)
		})

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

		if (error != nil) { ProgressHUD.showFailed("Saving failed.") } else { ProgressHUD.showSucceed("Successfully saved.") }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func video(_ videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

		if (error != nil) { ProgressHUD.showFailed("Saving failed.") } else { ProgressHUD.showSucceed("Successfully saved.") }
	}

	// MARK: - Cleanup methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		audioController?.stopAudio()
		audioController = nil

		DBDetail.removeObserver(gqldb, observerIdDetail)
		DBMessage.removeObserver(gqldb, observerIdMessage)

		observerIdDetail = nil
		observerIdMessage = nil

		dbdetail?.update(typing: false)

		NotificationCenter.removeObserver(self)
	}

}

// MARK: - Message Source methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func messageTotalCount() -> Int {

		return dbmessages.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func messageLoadedCount() -> Int {

		return min(messageToDisplay, messageTotalCount())
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func dbmessageAt(_ indexPath: IndexPath) -> DBMessage {

		let offset = messageTotalCount() - messageLoadedCount()
		let index = indexPath.section + offset

		return dbmessages[index]
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func rcmessageAt(_ indexPath: IndexPath) -> RCMessage {

		let dbmessage = dbmessageAt(indexPath)

		if let rcmessage = rcmessages[dbmessage.objectId] {
			rcmessage.update(dbmessage)
			loadMedia(rcmessage)
			return rcmessage
		}

		let rcmessage = RCMessage(dbmessage)
		rcmessages[dbmessage.objectId] = rcmessage
		loadMedia(rcmessage)
		return rcmessage
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func indexPathBy(_ rcmessage: RCMessage) -> IndexPath? {

		for (index, dbmessage) in dbmessages.enumerated() {
			if (dbmessage.objectId == rcmessage.messageId) {
				let offset = messageTotalCount() - messageLoadedCount()
				return IndexPath(row: 2, section: index - offset)
			}
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadMedia(_ rcmessage: RCMessage) {

		if (rcmessage.mediaStatus != MediaStatus.Unknown) { return }
		if (rcmessage.isMediaQueued && !rcmessage.isMediaOrigin) { return }

		if (rcmessage.type == MessageType.Photo)	{ RCLoaderPhoto.start(rcmessage, in: tableView)		}
		if (rcmessage.type == MessageType.Video)	{ RCLoaderVideo.start(rcmessage, in: tableView)		}
		if (rcmessage.type == MessageType.Audio)	{ RCLoaderAudio.start(rcmessage, in: tableView)		}
		if (rcmessage.type == MessageType.Location)	{ RCLoaderLocation.start(rcmessage, in: tableView)	}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return messageLoadedCount()
	}
}

// MARK: - Message Cell methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView {

	// Avatar methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func avatarInitials(_ indexPath: IndexPath) -> String {

		let rcmessage = rcmessageAt(indexPath)
		return rcmessage.userInitials
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func avatarImage(_ indexPath: IndexPath) -> UIImage? {

		let rcmessage = rcmessageAt(indexPath)
		var imageAvatar = avatarImages[rcmessage.userId]

		if (imageAvatar == nil) {
			if let path = Media.path(userId: rcmessage.userId) {
				imageAvatar = UIImage.image(path, size: 30)
				avatarImages[rcmessage.userId] = imageAvatar
			}
		}

		if (imageAvatar == nil) {
			MediaDownload.user(rcmessage.userId, rcmessage.userPictureAt) { image, error in
				if (error == nil) {
					self.refreshTableView()
				}
			}
		}

		return imageAvatar
	}

	// Header, Footer methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func textHeaderUpper(_ indexPath: IndexPath) -> String? {

		if (indexPath.section % 3 == 0) {
			let rcmessage = rcmessageAt(indexPath)
			return Convert.timestampToDayMonthTime(rcmessage.createdAt)
		} else {
			return nil
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func textHeaderLower(_ indexPath: IndexPath) -> String? {

		let rcmessage = rcmessageAt(indexPath)
		if (rcmessage.incoming) {
			return rcmessage.userFullname
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func textFooterLower(_ indexPath: IndexPath) -> String? {

		let rcmessage = rcmessageAt(indexPath)
		if (rcmessage.outgoing) {
			if (rcmessage.isDataQueued) { return MessageStatus.Queued }
			if (rcmessage.isMediaFailed) { return MessageStatus.Failed }
			if (rcmessage.isMediaQueued) { return MessageStatus.Queued }
			return (rcmessage.createdAt > lastRead) ? MessageStatus.Sent : MessageStatus.Read
		}
		return nil
	}

	// User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func actionTapBubble(_ indexPath: IndexPath) {

		let rcmessage = rcmessageAt(indexPath)

		if (rcmessage.isMediaFailed && rcmessage.isMediaOrigin) {
			actionResendMedia(rcmessage)
			return
		}

		if (rcmessage.mediaStatus == MediaStatus.Manual) {
			if (rcmessage.type == MessageType.Photo) { RCLoaderPhoto.manual(rcmessage, in: tableView) }
			if (rcmessage.type == MessageType.Video) { RCLoaderVideo.manual(rcmessage, in: tableView) }
			if (rcmessage.type == MessageType.Audio) { RCLoaderAudio.manual(rcmessage, in: tableView) }
		}

		if (rcmessage.mediaStatus == MediaStatus.Succeed) {
			if (rcmessage.type == MessageType.Photo) {
				let pictureView = PictureView(chatId: chatId, messageId: rcmessage.messageId)
				present(pictureView, animated: true)
			}
			if (rcmessage.type == MessageType.Video) {
				if let path = rcmessage.videoPath {
					let videoView = VideoView(path: path)
					present(videoView, animated: true)
				}
			}
			if (rcmessage.type == MessageType.Audio) {
				audioController?.toggleAudio(indexPath)
			}
			if (rcmessage.type == MessageType.Location) {
				let mapView = MapView(latitude: rcmessage.latitude, longitude: rcmessage.longitude)
				let navController = NavigationController(rootViewController: mapView)
				present(navController, animated: true)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func actionTapAvatar(_ indexPath: IndexPath) {

		let rcmessage = rcmessageAt(indexPath)

		if (rcmessage.userId != GQLAuth.userId()) {
			let profileView = ProfileView(rcmessage.userId, chat: false)
			navigationController?.pushViewController(profileView, animated: true)
		}
	}
}

// MARK: - Menu Controller methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func menuItems(_ indexPath: IndexPath) -> [RCMenuItem]? {

		let menuItemCopy = RCMenuItem(title: "Copy", action: #selector(actionMenuCopy(_:)))
		let menuItemSave = RCMenuItem(title: "Save", action: #selector(actionMenuSave(_:)))
		let menuItemDelete = RCMenuItem(title: "Delete", action: #selector(actionMenuDelete(_:)))
		let menuItemForward = RCMenuItem(title: "Forward", action: #selector(actionMenuForward(_:)))

		menuItemCopy.indexPath = indexPath
		menuItemSave.indexPath = indexPath
		menuItemDelete.indexPath = indexPath
		menuItemForward.indexPath = indexPath

		let rcmessage = rcmessageAt(indexPath)

		var array: [RCMenuItem] = []

		if (rcmessage.type == MessageType.Text)		{ array.append(menuItemCopy) }
		if (rcmessage.type == MessageType.Emoji)	{ array.append(menuItemCopy) }

		if (rcmessage.type == MessageType.Photo)	{ array.append(menuItemSave) }
		if (rcmessage.type == MessageType.Video)	{ array.append(menuItemSave) }
		if (rcmessage.type == MessageType.Audio)	{ array.append(menuItemSave) }

		array.append(menuItemDelete)
		array.append(menuItemForward)

		return array
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

		if (action == #selector(actionMenuCopy(_:)))	{ return true }
		if (action == #selector(actionMenuSave(_:)))	{ return true }
		if (action == #selector(actionMenuDelete(_:)))	{ return true }
		if (action == #selector(actionMenuForward(_:)))	{ return true }

		return false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuCopy(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender) {
			let rcmessage = rcmessageAt(indexPath)
			UIPasteboard.general.string = rcmessage.text
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuSave(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender) {
			let rcmessage = rcmessageAt(indexPath)
			if (rcmessage.mediaStatus == MediaStatus.Succeed) {
				if (rcmessage.type == MessageType.Photo) {
					if let image = rcmessage.photoImage {
						UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
					}
				}
				if (rcmessage.type == MessageType.Video) {
					if let path = rcmessage.videoPath {
						UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
					}
				}
				if (rcmessage.type == MessageType.Audio) {
					if let path = rcmessage.audioPath {
						let temp = File.temp("mp4")
						File.copy(path, temp, true)
						UISaveVideoAtPathToSavedPhotosAlbum(temp, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuDelete(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender) {
			let dbmessage = dbmessageAt(indexPath)
			dbmessage.update(isDeleted: true)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuForward(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender) {
			indexForward = indexPath

			let selectUsersView = SelectUsersView()
			selectUsersView.delegate = self
			let navController = NavigationController(rootViewController: selectUsersView)
			present(navController, animated: true)
		}
	}
}

// MARK: - Message Input Bar methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func actionAttachMessage() {

		dismissKeyboard()

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let alertCamera = UIAlertAction(title: "Camera", style: .default) { action in
			ImagePicker.cameraMulti(self, edit: true)
		}
		let alertPhoto = UIAlertAction(title: "Photo", style: .default) { action in
			ImagePicker.photoLibrary(self, edit: true)
		}
		let alertVideo = UIAlertAction(title: "Video", style: .default) { action in
			ImagePicker.videoLibrary(self, edit: true)
		}
		let alertAudio = UIAlertAction(title: "Audio", style: .default) { action in
			self.actionAudio()
		}
		let alertStickers = UIAlertAction(title: "Sticker", style: .default) { action in
			self.actionStickers()
		}
		let alertLocation = UIAlertAction(title: "Location", style: .default) { action in
			self.actionLocation()
		}

		let configuration	= UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
		let imageCamera		= UIImage(systemName: "camera", withConfiguration: configuration)
		let imagePhoto		= UIImage(systemName: "photo", withConfiguration: configuration)
		let imageVideo		= UIImage(systemName: "play.rectangle", withConfiguration: configuration)
		let imageAudio		= UIImage(systemName: "music.mic", withConfiguration: configuration)
		let imageStickers	= UIImage(systemName: "tortoise", withConfiguration: configuration)
		let imageLocation	= UIImage(systemName: "location", withConfiguration: configuration)

		alertCamera.setValue(imageCamera, forKey: "image"); 	alert.addAction(alertCamera)
		alertPhoto.setValue(imagePhoto, forKey: "image");		alert.addAction(alertPhoto)
		alertVideo.setValue(imageVideo, forKey: "image");		alert.addAction(alertVideo)
		alertAudio.setValue(imageAudio, forKey: "image");		alert.addAction(alertAudio)
		alertStickers.setValue(imageStickers, forKey: "image");	alert.addAction(alertStickers)
		alertLocation.setValue(imageLocation, forKey: "image");	alert.addAction(alertLocation)

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func actionSendMessage(_ text: String) {

		messageSend(text: text, photo: nil, video: nil, audio: nil)
	}
}

// MARK: - UIImagePickerControllerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

		let video = info[.mediaURL] as? URL
		let photo = info[.editedImage] as? UIImage

		messageSend(text: nil, photo: photo, video: video, audio: nil)

		picker.dismiss(animated: true)
	}
}

// MARK: - AudioDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView: AudioDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didRecordAudio(path: String) {

		messageSend(text: nil, photo: nil, video: nil, audio: path)
	}
}

// MARK: - StickersDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView: StickersDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectSticker(sticker: UIImage) {

		messageSend(text: nil, photo: sticker, video: nil, audio: nil)
	}
}

// MARK: - SelectUsersDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView: SelectUsersDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectUsers(userIds: [String]) {

		if let indexPath = indexForward {
			let dbmessage = dbmessageAt(indexPath)

			for userId in userIds {
				let chatId = DBSingles.create(userId)
				DBMessages.forward(chatId, dbmessage)
			}

			indexForward = nil
		}
	}
}
