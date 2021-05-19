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
class MediaUploader: NSObject {

	private var timer: Timer?

	private var uploading = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: MediaUploader = {
		let instance = MediaUploader()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenter.addObserver(self, selector: #selector(initTimer), text: Notifications.UserLoggedIn)
		NotificationCenter.addObserver(self, selector: #selector(stopTimer), text: Notifications.UserLoggedOut)

		if (GQLAuth.userId() != "") {
			initTimer()
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaUploader {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func initTimer() {

		timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
			if (GQLNetwork.isReachable()) {
				self.uploadNext()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func stopTimer() {

		timer?.invalidate()
		timer = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func uploadNext() {

		if (uploading) { return }

		if let mediaQueue = MediaQueue.fetchOne(gqldb, "isQueued = ? AND isFailed = ?", [true, false], order: "updatedAt") {
			guard let dbmessage = DBMessage.fetchOne(gqldb, key: mediaQueue.objectId) else {
				fatalError("Message must exists in the local database.")
			}

			uploading = true
			upload(dbmessage) { error in
				if (error == nil) {
					dbmessage.update(isMediaQueued: false)
					mediaQueue.update(isQueued: false)
				} else {
					dbmessage.update(isMediaFailed: true)
					mediaQueue.update(isFailed: true)
				}
				self.uploading = false
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaUploader {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func upload(_ dbmessage: DBMessage, completion: @escaping (_ error: Error?) -> Void) {

		if (dbmessage.type == MessageType.Photo) { uploadPhoto(dbmessage, completion: completion) }
		if (dbmessage.type == MessageType.Video) { uploadVideo(dbmessage, completion: completion) }
		if (dbmessage.type == MessageType.Audio) { uploadAudio(dbmessage, completion: completion) }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func uploadPhoto(_ dbmessage: DBMessage, completion: @escaping (_ error: Error?) -> Void) {

		if let path = Media.path(photoId: dbmessage.objectId) {
			if let data = Data(path: path) {
				MediaUpload.photo(dbmessage.objectId, data) { error in
					completion(error)
				}
			} else { completion(NSError("Media file error.", code: 102)) }
		} else { completion(NSError("Missing media file.", code: 103)) }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func uploadVideo(_ dbmessage: DBMessage, completion: @escaping (_ error: Error?) -> Void) {

		if let path = Media.path(videoId: dbmessage.objectId) {
			if let data = Data(path: path) {
				if let encrypted = Cryptor.encrypt(data: data) {
					MediaUpload.video(dbmessage.objectId, encrypted) { error in
						completion(error)
					}
				} else { completion(NSError("Media encryption error.", code: 101)) }
			} else { completion(NSError("Media file error.", code: 102)) }
		} else { completion(NSError("Missing media file.", code: 103)) }
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func uploadAudio(_ dbmessage: DBMessage, completion: @escaping (_ error: Error?) -> Void) {

		if let path = Media.path(audioId: dbmessage.objectId) {
			if let data = Data(path: path) {
				if let encrypted = Cryptor.encrypt(data: data) {
					MediaUpload.audio(dbmessage.objectId, encrypted) { error in
						completion(error)
					}
				} else { completion(NSError("Media encryption error.", code: 101)) }
			} else { completion(NSError("Media file error.", code: 102)) }
		} else { completion(NSError("Missing media file.", code: 103)) }
	}
}
