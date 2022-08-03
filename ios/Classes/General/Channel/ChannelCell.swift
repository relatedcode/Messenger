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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ChannelCell: UITableViewCell {

	@IBOutlet private var imageUser: UIImageView!
	@IBOutlet private var labelInitials: UILabel!
	@IBOutlet private var labelName: UILabel!
	@IBOutlet private var labelStatus: UILabel!

	private var objectId = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ dbuser: DBUser) {

		labelInitials.text = dbuser.initials()
		labelName.text = dbuser.fullName
		labelStatus.text = dbuser.email
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(_ dbuser: DBUser) {

		objectId = dbuser.objectId

		MediaDownload.user(dbuser.thumbnailURL) { image, later in
			if (self.objectId == dbuser.objectId) {
				DispatchQueue.main.async {
					if let image = image {
						self.labelInitials.text = nil
						self.imageUser.image = image.square(to: 40)
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
