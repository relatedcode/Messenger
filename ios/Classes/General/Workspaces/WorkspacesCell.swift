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
import PINRemoteImage

//-----------------------------------------------------------------------------------------------------------------------------------------------
class WorkspacesCell: UITableViewCell {

	@IBOutlet private var imageWorkspace: UIImageView!
	@IBOutlet private var labelInitials: UILabel!
	@IBOutlet private var labelName: UILabel!
	@IBOutlet private var labelDetails: UILabel!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ dbworkspace: DBWorkspace) {

		let name = dbworkspace.name
		let short = String(name.prefix(2))

		let thumb = dbworkspace.thumbnailURL

		let details = dbworkspace.details
		let members = dbworkspace.members

		if let url = Backend.url(thumb) {
			labelInitials.text = nil
			imageWorkspace.pin_setImage(from: url)
		} else {
			labelInitials.text = short
			imageWorkspace.image = nil
		}

		labelName.text = name

		if (details.isEmpty) {
			labelDetails.text = "\(members.count) members"
		} else {
			labelDetails.text = details
		}
	}
}
