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
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Media {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func path(user: String) -> String?	{ return path("user", user.md5(), "jpg")		}
	class func path(anim: String) -> String?	{ return path("media", anim.md5(), "gif")		}
	class func path(photo: String) -> String?	{ return path("media", photo.md5(), "jpg")		}
	class func path(video: String) -> String?	{ return path("media", video.md5(), "mp4")		}
	class func path(audio: String) -> String?	{ return path("media", audio.md5(), "m4a")		}
	class func path(sticker: String) -> String?	{ return path("media", sticker.md5(), "png")	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func path(_ dir: String, _ name: String, _ ext: String) -> String? {

		let file = "\(name).\(ext)"
		let path = Dir.document(dir, and: file)

		return File.exist(path) ? path : nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func xpath(user: String) -> String	{ return xpath("user", user.md5(), "jpg")		}
	class func xpath(anim: String) -> String	{ return xpath("media", anim.md5(), "gif")		}
	class func xpath(photo: String) -> String	{ return xpath("media", photo.md5(), "jpg")		}
	class func xpath(video: String) -> String	{ return xpath("media", video.md5(), "mp4")		}
	class func xpath(audio: String) -> String	{ return xpath("media", audio.md5(), "m4a")		}
	class func xpath(sticker: String) -> String	{ return xpath("media", sticker.md5(), "png")	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func xpath(_ dir: String, _ name: String, _ ext: String) -> String {

		let file = "\(name).\(ext)"
		return Dir.document(dir, and: file)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Media {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func clearManual(anim: String)	{ clearManual("media", anim.md5(), "gif")	}
	class func clearManual(photo: String)	{ clearManual("media", photo.md5(), "jpg")	}
	class func clearManual(video: String)	{ clearManual("media", video.md5(), "mp4")	}
	class func clearManual(audio: String)	{ clearManual("media", audio.md5(), "m4a")	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func clearManual(_ dir: String, _ name: String, _ ext: String) {

		let file = "\(name).\(ext)"

		let fileManual = file + ".manual"
		let pathManual = Dir.document(dir, and: fileManual)

		File.remove(pathManual)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Media {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func save(_ path: String, _ data: Data) {

		data.write(path: path, options: .atomic)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Media {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupExpired() {

		if (GQLAuth.userId() != "") {
			if (KeepMedia.isWeek()) { cleanupExpired(days: 7) }
			if (KeepMedia.isMonth()) { cleanupExpired(days: 30) }
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupExpired(days: Int) {

		var isDir: ObjCBool = false
		let extensions = ["gif", "jpg", "mp4", "m4a"]

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
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.caches()) {
			for file in files {
				let path = Dir.caches(file)
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
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Media {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupManual(logout: Bool) {

		var isDir: ObjCBool = false
		let extensions = logout ? ["gif", "jpg", "mp4", "m4a", "manual"] : ["gif", "jpg", "mp4", "m4a"]

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
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.caches()) {
			for file in files {
				let path = Dir.caches(file)
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
		let extensions = ["gif", "jpg", "mp4", "m4a"]

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
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.caches()) {
			for file in files {
				let path = Dir.caches(file)
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
