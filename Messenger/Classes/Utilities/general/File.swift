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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class File: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func temp(ext: String) -> String {

		let name = UUID().uuidString
		let file = "\(name).\(ext)"
		return Dir.cache(file)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func exist(path: String) -> Bool {

		return FileManager.default.fileExists(atPath: path)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func remove(path: String) {

		try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func copy(src: String, dest: String, overwrite: Bool) {

		if (overwrite) { remove(path: dest) }

		if (exist(path: dest) == false) {
			try? FileManager.default.copyItem(atPath: src, toPath: dest)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func created(path: String) -> Date {

		let attributes = try! FileManager.default.attributesOfItem(atPath: path)
		return attributes[.creationDate] as! Date
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func modified(path: String) -> Date {

		let attributes = try! FileManager.default.attributesOfItem(atPath: path)
		return attributes[.modificationDate] as! Date
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func size(path: String) -> Int64 {

		let attributes = try! FileManager.default.attributesOfItem(atPath: path)
		return attributes[.size] as! Int64
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func diskFree() -> Int64 {

		let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		let attributes = try! FileManager.default.attributesOfFileSystem(forPath: path)
		return attributes[.systemFreeSize] as! Int64
	}
}
