//
// Copyright (c) 2022 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Alamofire
import GraphQLite
import ProgressHUD

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Scheduler: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Scheduler {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateUser(_ values: [String: Any], _ completion: @escaping (Error?) -> Void) {

		let link = link("users", GQLAuth.userId())

		postAuth(link, values, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func presence() {

		let link = link("users", GQLAuth.userId(), "presence")

		postAuth(link, [:]) { error in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func lastRead(_ chatId: String, _ chatType: String) {

		let link = link("users", GQLAuth.userId(), "read")

		let values = ["chatId": chatId, "chatType": chatType]

		postAuth(link, values) { error in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Scheduler {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func message(_ chatId: String, _ chatType: String, _ text: String?, _ photo: UIImage?, _ video: URL?, _ audio: String?, _ sticker: String?) {

		var values = ["workspaceId": Workspace.id(), "chatId": chatId, "chatType": chatType]

		if let text = text {
			values["text"] = text
			messageSend(values)
		}

		if let photo = photo {
			if let data = photo.jpegData(compressionQuality: 1.0) {
				messageMedia(values, data, "image/jpeg", "photo.jpg")
			}
		}

		if let video = video {
			if let data = Data(path: video.path) {
				messageMedia(values, data, "video/mp4", "video.mp4")
			}
		}

		if let audio = audio {
			if let data = Data(path: audio) {
				messageMedia(values, data, "audio/mpeg", "audio.m4a")
			}
		}

		if let sticker = sticker {
			values["sticker"] = sticker
			messageSend(values)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func messageMedia(_ values: [String: Any], _ data: Data, _ mimeType: String, _ fileName: String) {

		var values = values

		uploadAuth(data, mimeType) { objectId, filePath, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				values["objectId"] = objectId
				values["filePath"] = filePath
				values["fileName"] = fileName
				self.messageSend(values)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func messageSend(_ values: [String: Any]) {

		let link = link("messages")

		postAuth(link, values) { error in
			if let error = error {
				ProgressHUD.showFailed(error.localizedDescription)
			} else {
				Audio.playMessageOutgoing()
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Scheduler {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func typingDirect(_ chatId: String, _ isTyping: Bool) {

		let link = link("directs", chatId, "typing_indicator")

		postAuth(link, ["isTyping": isTyping]) { error in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func typingChannel(_ chatId: String, _ isTyping: Bool) {

		let link = link("channels", chatId, "typing_indicator")

		postAuth(link, ["isTyping": isTyping]) { error in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Scheduler {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func postAuth(_ link: String, _ values: [String: Any], _ completion: @escaping (Error?) -> Void) {

		GQLAuth.refresh() { auth, error in
			if (error == nil) {
				self.post(link, auth, values, completion)
			} else {
				completion(error)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func post(_ link: String, _ auth: [String: String], _ values: [String: Any], _ completion: @escaping (Error?) -> Void) {

		var headers = auth

		headers["Content-Type"] = "application/json"

		var request = URLRequest(url: link.url())
		request.allHTTPHeaderFields = headers
		request.httpMethod = "POST"
		request.httpBody = data(values)

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			let xerror = self.check(data, error)
			DispatchQueue.main.async {
				completion(xerror)
			}
		}

		task.resume()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Scheduler {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func uploadAuth(_ data: Data, _ mimeType: String, _ completion: @escaping (String?, String?, Error?) -> Void) {

		ProgressHUD.show(interaction: false)

		GQLAuth.refresh() { auth, error in
			if (error == nil) {
				self.upload(auth, data, mimeType, completion)
			} else {
				ProgressHUD.dismiss()
				completion(nil, nil, error)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func upload(_ auth: [String: String], _ data: Data, _ mimeType: String, _ completion: @escaping (String?, String?, Error?) -> Void) {

		let base = Backend.link()
		let link = "\(base)/storage/b/messenger/upload"

		var headers = HTTPHeaders(auth)
		headers["Content-Type"] = "multipart/form-data"

		let objectId = UUID().uuidString
		let timestamp = Int(Date().timestamp())
		let key = "Message/\(objectId)/\(timestamp)_file"

		AF.upload(multipartFormData: { multipart in

			multipart.append(key.data(), withName: "key")
			multipart.append(data, withName: "file", fileName: "file", mimeType: mimeType)

		}, to: link.url(), method: .post, headers: headers).responseData { response in

			ProgressHUD.dismiss()
			switch response.result {
			case .success(let data):
				let values = self.convert(data)
				if let link = values["url"] as? String {
					completion(objectId, link, nil)
				} else {
					completion(nil, nil, NSError("Upload error.", code: 100))
					print(values)
				}
			case .failure(let error):
				completion(nil, nil, error)
			}
		}
	}
}

// MARK: - Convert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Scheduler {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func data(_ values: [String: Any]) -> Data {

		if let data = try? JSONSerialization.data(withJSONObject: values) {
			return data
		}
		fatalError("JSONSerialization error. \(values)")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func convert(_ data: Data?) -> [String: Any] {

		if let data = data {
			if let values = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
				return values
			}
		}
		fatalError("JSONSerialization error.")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func check(_ data: Data?, _ error: Error?) -> Error? {

		if let error = error { return error }

		let response = convert(data)
		if let error = response["error"] as? [String: Any] {
			if let message = error["message"] as? String {
				return NSError(message, code: 100)
			}
		}
		return nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Scheduler {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func link(_ path: String) -> String {

		let link = Backend.api()

		return "\(link)/\(path)"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func link(_ path1: String, _ path2: String) -> String {

		let link = Backend.api()

		return "\(link)/\(path1)/\(path2)"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func link(_ path1: String, _ path2: String, _ path3: String) -> String {

		let link = Backend.api()

		return "\(link)/\(path1)/\(path2)/\(path3)"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func link(_ path1: String, _ path2: String, _ path3: String, _ path4: String) -> String {

		let link = Backend.api()

		return "\(link)/\(path1)/\(path2)/\(path3)/\(path4)"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
fileprivate extension String {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func url() -> URL {

		guard let url = URL(string: self) else {
			fatalError("URL error: \(self)")
		}
		return url
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func data() -> Data {

		return Data(self.utf8)
	}
}
