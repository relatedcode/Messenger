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
class DirectsCell: UITableViewCell {

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
	func bindData(_ dbdirect: DBDirect) {

		if let dbuser = DBUser.fetchOne(gqldb, key: dbdirect.userId()) {
			labelInitials.text = dbuser.initials()
			labelDetails.text = dbuser.fullName
			loadImage(dbuser)
		}

		let isTyping = (dbdirect.typing.count > 0)
		let text = dbdirect.lastMessageText.removeHTML()

		labelLastMessage.text = isTyping ? "Typing..." : text
		labelElapsed.text = Convert.dateToCustom(dbdirect.updatedAt)

		imageMuted.isHidden = true
		viewUnread.isHidden = true

		let condition = "chatId = :chatId AND userId = :userId"
		let arguments = [":chatId": dbdirect.objectId, ":userId": GQLAuth.userId()]
		if let dbdetail = DBDetail.fetchOne(gqldb, condition, arguments) {
			let count = dbdirect.lastMessageCounter - dbdetail.lastRead
			if (count > 0) {
				labelUnread.text = "\(count)"
				viewUnread.isHidden = false
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(_ dbuser: DBUser) {

		objectId = dbuser.objectId

		MediaDownload.user(dbuser.thumbnailURL) { image, later in
			if (self.objectId == dbuser.objectId) {
				DispatchQueue.main.async {
					if let image = image {
						self.labelInitials.text = nil
						self.imageUser.image = image.square(to: 50)
					} else if (later) {
						self.loadLater(dbuser)
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadLater(_ dbuser: DBUser) {

		DispatchQueue.main.async(after: 0.5) {
			if (self.objectId == dbuser.objectId) {
				if (self.imageUser.image == nil) {
					self.loadImage(dbuser)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		objectId = ""

		imageUser.image = nil
	}
}
