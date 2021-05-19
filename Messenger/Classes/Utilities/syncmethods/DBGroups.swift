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
class DBGroups: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func create(_ name: String, _ userIds: [String]) {

		let objectId = UUID().uuidString

		DBDetails.create(objectId, userIds)
		DBMembers.create(objectId, userIds)

		let dbgroup = DBGroup()
		dbgroup.objectId = objectId
		dbgroup.chatId = objectId
		dbgroup.name = name
		dbgroup.ownerId = GQLAuth.userId()
		dbgroup.members = userIds.count
		dbgroup.insertLazy()
	}
}
