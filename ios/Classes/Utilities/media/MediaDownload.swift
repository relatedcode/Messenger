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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class MediaDownload: NSObject {

	static var loading: [String] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func anim(_ link: String, _ completion: @escaping (String, Error?) -> Void) {

		let path = Media.xpath(anim: link)
		checkManual(link, path, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func photo(_ link: String, _ completion: @escaping (String, Error?) -> Void) {

		let path = Media.xpath(photo: link)
		checkManual(link, path, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func video(_ link: String, _ completion: @escaping (String, Error?) -> Void) {

		let path = Media.xpath(video: link)
		checkManual(link, path, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func audio(_ link: String, _ completion: @escaping (String, Error?) -> Void) {

		let path = Media.xpath(audio: link)
		checkManual(link, path, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func checkManual(_ link: String, _ path: String, _ completion: @escaping (String, Error?) -> Void) {

		let manual = path + ".manual"
		if (File.exist(manual)) {
			completion(path, xerror("Manual download."))
			return
		}
		try? "manual".write(toFile: manual, atomically: false, encoding: .utf8)

		media(link, path, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func media(_ link: String, _ path: String, _ completion: @escaping (String, Error?) -> Void) {

		guard let url = Backend.url(link) else {
			fatalError("Backend url error.")
		}

		start(url, path) { error, later in
			completion(path, error)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaDownload {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func sticker(_ sticker: String, _ completion: @escaping (String, Error?) -> Void) {

		let path = Media.xpath(sticker: sticker)

		guard let url = Backend.sticker(sticker) else {
			fatalError("Backend url error.")
		}

		start(url, path) { error, later in
			completion(path, error)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaDownload {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func user(_ link: String, _ completion: @escaping (UIImage?, Bool) -> Void) {

		let path = Media.xpath(user: link)

		if (File.exist(path)) {
			let image = UIImage(path: path)
			completion(image, false); return
		}

		guard let url = Backend.url(link) else {
			completion(nil, false); return
		}

		start(url, path) { error, later in
			if (error == nil) {
				let image = UIImage(path: path)
				completion(image, false)
			} else {
				completion(nil, later)
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaDownload {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func start(_ url: URL, _ path: String, _ completion: @escaping (Error?, Bool) -> Void) {

		if (GQLNetwork.notReachable()) {
			completion(xerror("Network connection."), false); return
		}

		if (loading.count > 5) {
			completion(xerror("Too many processes."), true); return
		}

		if (loading.contains(path)) {
			completion(xerror("Already downloading."), true); return
		}

		loading.append(path)
		AF.request(url, method: .get).responseData { response in
			loading.remove(path)

			switch response.result {
			case .success(let data):
				Media.save(path, data)
				completion(nil, false)
			case .failure(let error):
				completion(error, false)
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension MediaDownload {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func xerror(_ text: String) -> NSError {

		return NSError(text, code: 100)
	}
}
