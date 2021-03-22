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
class LastUpdated: NSObject, GQLObject {

	@objc var name = ""
	@objc var updatedAt: TimeInterval = 0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "name"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension LastUpdated {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class subscript(_ table: String) -> String {

		let lastUpdated = LastUpdated.fetchOne(gqldb, key: table)
		let updatedAt = lastUpdated?.updatedAt ?? 0

		return GQLDate[updatedAt]
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension LastUpdated {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func update(_ table: String, _ value: String) {

		let updatedAt = GQLDate[value].timeIntervalSince1970

		if let lastUpdated = LastUpdated.fetchOne(gqldb, key: table) {
			if (updatedAt > lastUpdated.updatedAt) {
				lastUpdated.updatedAt = updatedAt
				lastUpdated.update(gqldb)
			}
		} else {
			let lastUpdated = LastUpdated()
			lastUpdated.name = table
			lastUpdated.updatedAt = updatedAt
			lastUpdated.insert(gqldb)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func clear(_ table: String) {

		let lastUpdated = LastUpdated()
		lastUpdated.name = table
		lastUpdated.updatedAt = 0
		lastUpdated.update(gqldb)
	}
}
