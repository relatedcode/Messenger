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
	class func user(_ name: String, _ data: Data, completion: @escaping (Error?) -> Void) {

		start("user", name, "jpg", data, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func photo(_ name: String, _ data: Data, completion: @escaping (Error?) -> Void) {

		start("media", name, "jpg", data, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func video(_ name: String, _ data: Data, completion: @escaping (Error?) -> Void) {

		start("media", name, "mp4", data, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func audio(_ name: String, _ data: Data, completion: @escaping (Error?) -> Void) {

		start("media", name, "m4a", data, completion)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func start(_ dir: String, _ name: String, _ ext: String, _ data: Data, _ completion: @escaping (Error?) -> Void) {

		let bucket = "messenger-ios"
		let key = "\(dir)/\(name).\(ext)"

		gqlstorage.upload(bucket, key, data) { error in
			DispatchQueue.main.async {
				completion(error)
			}
		}
	}
}
