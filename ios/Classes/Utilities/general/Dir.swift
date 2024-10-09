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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Dir {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func application() -> String {

		return Bundle.main.resourcePath!
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func application(_ component: String) -> String {

		var path = application()

		path = (path as NSString).appendingPathComponent(component)

		return path
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func application(_ component1: String, and component2: String) -> String {

		var path = application()

		path = (path as NSString).appendingPathComponent(component1)
		path = (path as NSString).appendingPathComponent(component2)

		return path
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Dir {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func document() -> String {

		return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func document(_ component: String) -> String {

		var path = document()

		path = (path as NSString).appendingPathComponent(component)

		createIntermediate(path)

		return path
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func document(_ component1: String, and component2: String) -> String {

		var path = document()

		path = (path as NSString).appendingPathComponent(component1)
		path = (path as NSString).appendingPathComponent(component2)

		createIntermediate(path)

		return path
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Dir {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func caches() -> String {

		return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func caches(_ component: String) -> String {

		var path = caches()

		path = (path as NSString).appendingPathComponent(component)

		createIntermediate(path)

		return path
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Dir {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func applicationSupport() -> String {

		return NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func applicationSupport(_ component: String) -> String {

		var path = applicationSupport()

		path = (path as NSString).appendingPathComponent(component)

		createIntermediate(path)

		return path
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Dir {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func createIntermediate(_ path: String) {

		let directory = (path as NSString).deletingLastPathComponent
		if (exist(directory) == false) {
			create(directory)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func create(_ directory: String) {

		try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func exist(_ path: String) -> Bool {

		return FileManager.default.fileExists(atPath: path)
	}
}
