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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ChannelCell: UITableViewCell {

	@IBOutlet private var imageUser: UIImageView!
	@IBOutlet private var labelInitials: UILabel!
	@IBOutlet private var labelName: UILabel!
	@IBOutlet private var labelStatus: UILabel!

	private var objectId = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		objectId = ""

		imageUser.image = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ dbuser: DBUser) {

		labelInitials.text = dbuser.initials()
		labelName.text = dbuser.fullName
		labelStatus.text = dbuser.email
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(_ dbuser: DBUser) {

		objectId = dbuser.objectId

		MediaDownload.user(dbuser.thumbnailURL) { [weak self] image, later in
			guard let self = self else { return }
			if (objectId == dbuser.objectId) {
				if let image = image {
					labelInitials.text = nil
					imageUser.image = image.square(to: 40)
				} else if later {
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
