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

import UIKit
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ChannelsCell: UITableViewCell {

	@IBOutlet private var imageUser: UIImageView!
	@IBOutlet private var labelInitials: UILabel!

	@IBOutlet private var labelDetails: UILabel!
	@IBOutlet private var labelLastMessage: UILabel!
	@IBOutlet private var labelElapsed: UILabel!

	@IBOutlet private var imageMuted: UIImageView!
	@IBOutlet private var viewUnread: UIView!
	@IBOutlet private var labelUnread: UILabel!

	private var objectId = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ dbchannel: DBChannel) {

		labelInitials.text = "#"
		labelDetails.text = dbchannel.name

		let isTyping = (dbchannel.typing.count > 0)
		let text = dbchannel.lastMessageText.removeHTML()

		labelLastMessage.text = isTyping ? "Typing..." : text
		labelElapsed.text = Convert.dateToCustom(dbchannel.updatedAt)

		imageMuted.isHidden = true
		viewUnread.isHidden = true

		let condition = "chatId = :chatId AND userId = :userId"
		let arguments = [":chatId": dbchannel.objectId, ":userId": GQLAuth.userId()]
		if let dbdetail = DBDetail.fetchOne(gqldb, condition, arguments) {
			let count = dbchannel.lastMessageCounter - dbdetail.lastRead
			if (count > 0) {
				labelUnread.text = "\(count)"
				viewUnread.isHidden = false
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		objectId = ""

		imageUser.image = nil
	}
}
