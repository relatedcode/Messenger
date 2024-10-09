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

import Foundation
import CryptoKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Data {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init?(url: URL) {

		try? self.init(contentsOf: url)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init?(path: String) {

		try? self.init(contentsOf: URL(fileURLWithPath: path))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func write(path: String, options: Data.WritingOptions = []) {

		try? self.write(to: URL(fileURLWithPath: path), options: options)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Data {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func md5() -> String {

		let hash = Insecure.MD5.hash(data: self)

		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}
}
