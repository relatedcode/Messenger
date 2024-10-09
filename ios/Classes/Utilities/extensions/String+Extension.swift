//
// Copyright (c) 2024 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
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
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	var notEmpty: Bool {

		return !self.isEmpty
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func removeHTML() -> String {

		var temp = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

		let characters = ["&nbsp;": " ", "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": "\"", "&apos;": "'"]

		for (escaped, unescaped) in characters {
			temp = temp.replacingOccurrences(of: escaped, with: unescaped, options: NSString.CompareOptions.literal, range: nil)
		}

		return temp
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func convertHTML() -> String {

		if let data = self.data(using: .utf8) {

			let document = NSAttributedString.DocumentType.html
			let encoding = String.Encoding.utf8.rawValue

			let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: document, .characterEncoding: encoding]

			if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
				return attributed.string
			}
		}

		return ""
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func height(_ width: CGFloat, font: UIFont) -> CGFloat {

		let size = CGSize(width: width, height: .greatestFiniteMagnitude)
		let rect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

		return ceil(rect.height)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func width(_ height: CGFloat, font: UIFont) -> CGFloat {

		let size = CGSize(width: .greatestFiniteMagnitude, height: height)
		let rect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

		return ceil(rect.width)
	}
}
