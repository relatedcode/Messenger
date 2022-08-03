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

import Foundation
import CryptoKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func md5() -> String {

		let data = Data(self.utf8)
		let hash = Insecure.MD5.hash(data: data)

		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sha1() -> String {

		let data = Data(self.utf8)
		let hash = Insecure.SHA1.hash(data: data)

		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sha256() -> String {

		let data = Data(self.utf8)
		let hash = SHA256.hash(data: data)

		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func initial() -> String {

		return String(self.prefix(1))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func removeHTML() -> String {

		var temp = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

		let characters = ["&nbsp;": " ", "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": "\"", "&apos;": "'"]

		for (escaped, unescaped) in characters {
			temp = temp.replacingOccurrences(of: escaped, with: unescaped, options: NSString.CompareOptions.literal, range: nil)
		}

		return temp
	}
}
