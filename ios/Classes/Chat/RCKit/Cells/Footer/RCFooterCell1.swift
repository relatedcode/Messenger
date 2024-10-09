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
class RCFooterCell1: RCMessagesCell {

	private var indexPath: IndexPath!
	private var messagesView: RCMessagesView!

	private var labelText: UILabel!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		self.indexPath = indexPath
		self.messagesView = messagesView

		let rcmessage = messagesView.rcmessageAt(indexPath)

		backgroundColor = UIColor.clear

		if (labelText == nil) {
			labelText = UILabel()
			labelText.font = RCKit.footerUpperFont
			labelText.textColor = RCKit.footerUpperColor
			contentView.addSubview(labelText)
		}

		labelText.textAlignment = rcmessage.incoming ? .left : .right
		labelText.text = messagesView.textFooterUpper(indexPath)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		super.layoutSubviews()

		let widthTable = messagesView.tableView.frame.size.width

		let width = widthTable - RCKit.footerUpperLeft - RCKit.footerUpperRight
		let height = (labelText.text != nil) ? RCKit.footerUpperHeight : 0

		labelText.frame = CGRect(x: RCKit.footerUpperLeft, y: 0, width: width, height: height)
	}

	// MARK: - Size methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func height(_ messagesView: RCMessagesView, at indexPath: IndexPath) -> CGFloat {

		return (messagesView.textFooterUpper(indexPath) != nil) ? RCKit.footerUpperHeight : 0
	}
}
