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
	override func prepareForReuse() {

		objectId = ""

		imageUser.image = nil
	}

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

		MediaDownload.user(dbuser.thumbnailURL) { [weak self] image, later in
			guard let self = self else { return }
			if (objectId == dbuser.objectId) {
				if let image = image {
					labelInitials.text = nil
					imageUser.image = image.square(to: 50)
				} else if (later) {
					loadLater(dbuser)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadLater(_ dbuser: DBUser) {

		DispatchQueue.main.async(after: 0.5) { [weak self] in
			guard let self = self else { return }
			if (objectId == dbuser.objectId) {
				if (imageUser.image == nil) {
					loadImage(dbuser)
				}
			}
		}
	}
}
