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
class Media: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func path(userId: String) -> String?	{ return path("user", userId, "jpg")	}
	class func path(photoId: String) -> String?	{ return path("media", photoId, "jpg")	}
	class func path(videoId: String) -> String?	{ return path("media", videoId, "mp4")	}
	class func path(audioId: String) -> String?	{ return path("media", audioId, "m4a")	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func path(_ dir: String, _ name: String, _ ext: String) -> String? {

		let file = "\(name).\(ext)"
		let path = Dir.document(dir, and: file)

		return File.exist(path) ? path : nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func xpath(photoId: String) -> String	{ return xpath("media", photoId, "jpg") }
	class func xpath(videoId: String) -> String	{ return xpath("media", videoId, "mp4") }
	class func xpath(audioId: String) -> String	{ return xpath("media", audioId, "m4a") }

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func xpath(_ dir: String, _ name: String, _ ext: String) -> String {

		let file = "\(name).\(ext)"
		return Dir.document(dir, and: file)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Media {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func clearManual(photoId: String) { clearManual("media", photoId, "jpg") }
	class func clearManual(videoId: String) { clearManual("media", videoId, "mp4") }
	class func clearManual(audioId: String) { clearManual("media", audioId, "m4a") }

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func clearManual(_ dir: String, _ name: String, _ ext: String) {

		let file = "\(name).\(ext)"

		let fileManual = file + ".manual"
		let pathManual = Dir.document(dir, and: fileManual)

		let fileLoading = file + ".loading"
		let pathLoading = Dir.document(dir, and: fileLoading)

		File.remove(pathManual)
		File.remove(pathLoading)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Media {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func save(userId: String, data: Data)		{ save(data, "user", userId, "jpg", manual: false, encrypt: true)	}
	class func save(photoId: String, data: Data)	{ save(data, "media", photoId, "jpg", manual: true, encrypt: true)	}
	class func save(videoId: String, data: Data)	{ save(data, "media", videoId, "mp4", manual: true, encrypt: false)	}
	class func save(audioId: String, data: Data)	{ save(data, "media", audioId, "m4a", manual: true, encrypt: false)	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func save(_ data: Data, _ dir: String, _ name: String, _ ext: String, manual: Bool, encrypt: Bool) {

		let file = "\(name).\(ext)"
		let path = Dir.document(dir, and: file)

		if (encrypt) {
			if let encrypted = Cryptor.encrypt(data: data) {
				encrypted.write(path: path, options: .atomic)
			}
		} else {
			data.write(path: path, options: .atomic)
		}

		if (manual) {
			let fileManual = file + ".manual"
			let pathManual = Dir.document(dir, and: fileManual)
			try? "manual".write(toFile: pathManual, atomically: false, encoding: .utf8)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Media {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupExpired() {

		if (GQLAuth.userId() != "") {
			let keepMedia = DBUsers.keepMedia()
			if (keepMedia == KeepMedia.Week) { cleanupExpired(days: 7) }
			if (keepMedia == KeepMedia.Month) { cleanupExpired(days: 30) }
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupExpired(days: Int) {

		var isDir: ObjCBool = false
		let extensions = ["jpg", "mp4", "m4a"]

		let past = Date().addingTimeInterval(TimeInterval(-days * 24 * 60 * 60))

		// Clear Documents files
		//---------------------------------------------------------------------------------------------------------------------------------------
		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						let created = File.created(path)
						if (created.compare(past) == .orderedAscending) {
							File.remove(path)
						}
					}
				}
			}
		}

		// Clear Caches files
		//---------------------------------------------------------------------------------------------------------------------------------------
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
			for file in files {
				let path = Dir.cache(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (ext == "mp4") {
						let created = File.created(path)
						if (created.compare(past) == .orderedAscending) {
							File.remove(path)
						}
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupManual(logout: Bool) {

		var isDir: ObjCBool = false
		let extensions = logout ? ["jpg", "mp4", "m4a", "manual", "loading"] : ["jpg", "mp4", "m4a"]

		// Clear Documents files
		//---------------------------------------------------------------------------------------------------------------------------------------
		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						File.remove(path)
					}
				}
			}
		}

		// Clear Caches files
		//---------------------------------------------------------------------------------------------------------------------------------------
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
			for file in files {
				let path = Dir.cache(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (ext == "mp4") {
						File.remove(path)
					}
				}
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Media {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func total() -> Int64 {

		var isDir: ObjCBool = false
		let extensions = ["jpg", "mp4", "m4a"]

		var total: Int64 = 0

		// Count Documents files
		//---------------------------------------------------------------------------------------------------------------------------------------
		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						total += File.size(path)
					}
				}
			}
		}

		// Count Caches files
		//---------------------------------------------------------------------------------------------------------------------------------------
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
			for file in files {
				let path = Dir.cache(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (ext == "mp4") {
						total += File.size(path)
					}
				}
			}
		}

		return total
	}
}
