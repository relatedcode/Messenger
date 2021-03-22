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

import CryptoKit
import Foundation

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Cryptor: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func encrypt(text: String) -> String? {

		if let dataDecrypted = text.data(using: .utf8) {
			if let dataEncrypted = encrypt(data: dataDecrypted) {
				return dataEncrypted.base64EncodedString()
			}
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func decrypt(text: String) -> String? {

		if let dataEncrypted = Data(base64Encoded: text) {
			if let dataDecrypted = decrypt(data: dataEncrypted) {
				return String(data: dataDecrypted, encoding: .utf8)
			}
		}
		return nil
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func encrypt(path: String) {

		if let dataDecrypted = Data(path: path) {
			if let dataEncrypted = encrypt(data: dataDecrypted) {
				dataEncrypted.write(path: path, options: .atomic)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func decrypt(path: String) {

		if let dataEncrypted = Data(path: path) {
			if let dataDecrypted = decrypt(data: dataEncrypted) {
				dataDecrypted.write(path: path, options: .atomic)
			}
		}
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func encrypt(data: Data) -> Data? {

		return try? encrypt(data: data, key: Password.get())
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func decrypt(data: Data) -> Data? {

		return try? decrypt(data: data, key: Password.get())
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func encrypt(data: Data, key: String) throws -> Data {

		let cryptedBox = try ChaChaPoly.seal(data, using: symmetricKey(key))
		let sealedBox = try ChaChaPoly.SealedBox(combined: cryptedBox.combined)

		return sealedBox.combined
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func decrypt(data: Data, key: String) throws -> Data {

		let sealedBox = try ChaChaPoly.SealedBox(combined: data)
		let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey(key))

		return decryptedData
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func symmetricKey(_ key: String) -> SymmetricKey {

		let dataKey = Data(key.utf8)
		let hash256 = SHA256.hash(data: dataKey)
		return SymmetricKey(data: hash256)
	}
}
