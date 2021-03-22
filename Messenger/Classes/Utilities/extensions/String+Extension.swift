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
import CryptoKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Character {

	var isEmoji: Bool {
		guard let scalar = unicodeScalars.first else { return false }
		return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func containsEmojiOnly() -> Bool {

		for character in self {
			if !character.isEmoji {
				return false
			}
		}
		return (count != 0)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func containsEmoji() -> Bool {

		for character in self {
			if character.isEmoji {
				return true
			}
		}
		return false
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension String {

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
	func between(_ str1: String, _ str2: String) -> String {

		if let range1 = self.range(of: str1)?.upperBound {
			if let range2 = self[range1...].range(of: str2)?.lowerBound {
				return String(self[range1..<range2])
			}
		}
		return ""
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func trailing(_ str: String) -> String {

		if let range = range(of: str)?.upperBound {
			return String(self[range...])
		}
		return ""
	}
}
