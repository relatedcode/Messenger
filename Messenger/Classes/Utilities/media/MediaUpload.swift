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
class MediaUpload: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func user(_ name: String, data: Data, completion: @escaping (Error?) -> Void) {

		start(dir: "user", name: name, ext: "jpg", data: data, completion: completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func photo(_ name: String, data: Data, completion: @escaping (Error?) -> Void) {

		start(dir: "media", name: name, ext: "jpg", data: data, completion: completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func video(_ name: String, data: Data, completion: @escaping (Error?) -> Void) {

		start(dir: "media", name: name, ext: "mp4", data: data, completion: completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func audio(_ name: String, data: Data, completion: @escaping (Error?) -> Void) {

		start(dir: "media", name: name, ext: "m4a", data: data, completion: completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func start(dir: String, name: String, ext: String, data: Data, completion: @escaping (Error?) -> Void) {

		let bucket = "messenger-ios"
		let key = "\(dir)/\(name).\(ext)"

		gqlstorage.upload(bucket, key, data) { error in
			DispatchQueue.main.async {
				completion(error)
			}
		}
	}
}
