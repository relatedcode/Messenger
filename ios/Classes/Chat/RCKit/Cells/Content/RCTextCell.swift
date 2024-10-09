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
class RCTextView: UITextView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

		return false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func becomeFirstResponder() -> Bool {

		return true
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCTextCell: RCBaseCell {

	private var textView: UITextView!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		viewBubble.backgroundColor = rcmessage.incoming ? RCKit.textBubbleColorIncoming : RCKit.textBubbleColorOutgoing

		if (textView == nil) {
			textView = RCTextView()
			textView.font = RCKit.textFont
			textView.isEditable = false
			textView.isSelectable = false
			textView.isScrollEnabled = false
			textView.isUserInteractionEnabled = false
			textView.backgroundColor = UIColor.clear
			textView.textContainer.lineFragmentPadding = 0
			textView.textContainerInset = RCKit.textInset

			textView.isSelectable = true
			textView.dataDetectorTypes = .link
			textView.isUserInteractionEnabled = true

			viewBubble.addSubview(textView)
			bubbleGestureRecognizer(textView)
		}

		textView.textColor = rcmessage.incoming ? RCKit.textTextColorIncoming : RCKit.textTextColorOutgoing
		textView.tintColor = rcmessage.incoming ? RCKit.textTextColorIncoming : RCKit.textTextColorOutgoing

		textView.text = rcmessage.text
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCTextCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		textView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
	}

	// MARK: - Size methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func height(_ messagesView: RCMessagesView, at indexPath: IndexPath) -> CGFloat {

		let size = self.size(messagesView, at: indexPath)
		return size.height
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func size(_ messagesView: RCMessagesView, at indexPath: IndexPath) -> CGSize {

		let rcmessage = messagesView.rcmessageAt(indexPath)

		if (rcmessage.sizeBubble == CGSize.zero) {
			calculate(rcmessage)
		}

		return rcmessage.sizeBubble
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func calculate(_ rcmessage: RCMessage) {

		let maxwidth = RCKit.textBubbleWidthMax - RCKit.textInsetLeft - RCKit.textInsetRight

		let rect = rcmessage.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: RCKit.textFont], context: nil)

		let width = rect.size.width + RCKit.textInsetLeft + RCKit.textInsetRight
		let height = rect.size.height + RCKit.textInsetTop + RCKit.textInsetBottom

		let widthBubble = CGFloat.maximum(width, RCKit.textBubbleWidthMin)
		let heightBubble = CGFloat.maximum(height, RCKit.textBubbleHeightMin)

		rcmessage.sizeBubble = CGSize(width: widthBubble, height: heightBubble)
	}
}
