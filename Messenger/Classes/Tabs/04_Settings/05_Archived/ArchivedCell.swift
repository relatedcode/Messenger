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

import UIKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ArchivedCell: UITableViewCell {

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
	func bindData(_ chatObject: ChatObject) {

		labelDetails.text = chatObject.details
		labelLastMessage.text = chatObject.typing ? "Typing..." : chatObject.lastMessageText

		labelElapsed.text = Convert.timestampToCustom(chatObject.lastMessageAt)

		imageMuted.isHidden = (chatObject.mutedUntil < Date().timestamp())
		viewUnread.isHidden = (chatObject.unreadCount == 0)

		labelUnread.text = (chatObject.unreadCount < 100) ? "\(chatObject.unreadCount)" : "..."
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(_ chatObject: ChatObject) {

		objectId = chatObject.objectId

		imageUser.image = nil
		labelInitials.text = chatObject.initials

		if (chatObject.isPrivate) {
			if let path = Media.path(userId: chatObject.userId) {
				imageUser.image = UIImage.image(path, size: 50)
				labelInitials.text = nil
			} else {
				downloadImage(chatObject)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func downloadImage(_ chatObject: ChatObject) {

		MediaDownload.user(chatObject.userId, chatObject.pictureAt) { image, error in
			if (self.objectId == chatObject.objectId) {
				if (error == nil) {
					self.imageUser.image = image?.square(to: 50)
					self.labelInitials.text = nil
				} else if (error!.code() == 102) {
					self.downloadLater(chatObject)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func downloadLater(_ chatObject: ChatObject) {

		DispatchQueue.main.async(after: 0.5) {
			if (self.objectId == chatObject.objectId) {
				if (self.imageUser.image == nil) {
					self.downloadImage(chatObject)
				}
			}
		}
	}
}
