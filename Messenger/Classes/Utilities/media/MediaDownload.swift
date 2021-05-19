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
class MediaDownload: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func user(_ name: String, _ pictureAt: TimeInterval, completion: @escaping (UIImage?, Error?) -> Void) {

		if (pictureAt != 0) {
			start("user", name, "jpg", false) { path, error in
				if (error == nil) {
					completion(UIImage(path: path), nil)
				} else {
					completion(nil, error)
				}
			}
		} else {
			completion(nil, NSError("Missing picture.", code: 100))
		}
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func photo(_ name: String, completion: @escaping (String, Error?) -> Void) {

		start("media", name, "jpg", true, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func video(_ name: String, completion: @escaping (String, Error?) -> Void) {

		start("media", name, "mp4", true, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func audio(_ name: String, completion: @escaping (String, Error?) -> Void) {

		start("media", name, "m4a", true, completion)
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func start(_ dir: String, _ name: String, _ ext: String, _ manual: Bool, _ completion: @escaping (String, Error?) -> Void) {

		let file = "\(name).\(ext)"
		let path = Dir.document(dir, and: file)

		let fileManual = file + ".manual"
		let pathManual = Dir.document(dir, and: fileManual)

		let fileLoading = file + ".loading"
		let pathLoading = Dir.document(dir, and: fileLoading)

		// Check if file is already downloaded
		//---------------------------------------------------------------------------------------------------------------------------------------
		if (File.exist(path)) {
			completion(path, nil)
			return
		}

		// Check if manual download is required
		//---------------------------------------------------------------------------------------------------------------------------------------
		if (manual) {
			if (File.exist(pathManual)) {
				completion("", NSError("Manual download required.", code: 101))
				return
			}
			try? "manual".write(toFile: pathManual, atomically: false, encoding: .utf8)
		}

		// Check if file is currently downloading
		//---------------------------------------------------------------------------------------------------------------------------------------
		let time = Int(Date().timeIntervalSince1970)

		if (File.exist(pathLoading)) {
			if let temp = try? String(contentsOfFile: pathLoading, encoding: .utf8) {
				if let check = Int(temp) {
					if (time - check < 60) {
						completion("", NSError("Already downloading.", code: 102))
						return
					}
				}
			}
		}
		try? "\(time)".write(toFile: pathLoading, atomically: false, encoding: .utf8)

		// Download the file
		//---------------------------------------------------------------------------------------------------------------------------------------
		let bucket = "messenger-ios"
		let key = "\(dir)/\(name).\(ext)"

		gqlstorage.download(bucket, key) { data, error in
			File.remove(pathLoading)
			data?.write(path: path, options: .atomic)
			DispatchQueue.main.async {
				completion(path, error)
			}
		}
	}
}
