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
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class LastUpdated: NSObject {

	private static var initialized = false

	private static var cache: [String: TimeInterval] = [:]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class subscript(_ table: String) -> String {

		loadCache()

		if let cached = cache[table] {
			return GQLDate[cached]
		}

		return GQLDate[0]
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension LastUpdated {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func loadCache() {

		if (initialized) { return }

		if let temp = UserDefaults.object(key: "LastUpdated") as? [String: TimeInterval] {
			cache = temp
		}

		initialized = true
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func saveCache() {

		UserDefaults.setObject(cache, key: "LastUpdated")
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension LastUpdated {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(_ table: String, _ array: [[String: Any]]) {

		for values in array {
			update(table, values)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(_ table: String, _ values: [String: Any]) {

		if let updatedAt = values["updatedAt"] as? String {
			update(table, updatedAt)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(_ table: String, _ updatedAt: String) {

		update(table, GQLDate[updatedAt].timeIntervalSince1970)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(_ table: String, _ updatedAt: TimeInterval) {

		loadCache()

		if let cached = cache[table] {
			if (updatedAt <= cached) {
				return
			}
		}
		cache[table] = updatedAt

		saveCache()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension LastUpdated {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func clear(_ table: String) {

		cache.removeValue(forKey: table)

		saveCache()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanup() {

		cache.removeAll()

		saveCache()
	}
}
