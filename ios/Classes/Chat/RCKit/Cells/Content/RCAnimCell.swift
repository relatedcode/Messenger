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
import Gifu

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCAnimCell: RCBaseCell {

	private var imageViewAnim: GIFImageView!
	private var imageViewManual: UIImageView!
	private var activityIndicator: UIActivityIndicatorView!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		viewBubble.backgroundColor = rcmessage.incoming ? RCKit.animBubbleColorIncoming : RCKit.animBubbleColorOutgoing

		if (imageViewAnim == nil) {
			imageViewAnim = GIFImageView()
			imageViewAnim.layer.masksToBounds = true
			imageViewAnim.layer.cornerRadius = RCKit.bubbleRadius
			viewBubble.addSubview(imageViewAnim)
		}

		if (activityIndicator == nil) {
			if #available(iOS 13.0, *) {
				activityIndicator = UIActivityIndicatorView(style: .large)
			} else {
				activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
			}
			viewBubble.addSubview(activityIndicator)
		}

		if (imageViewManual == nil) {
			imageViewManual = UIImageView(image: RCKit.animImageManual)
			viewBubble.addSubview(imageViewManual)
		}

		if (rcmessage.mediaStatus == MediaStatus.Unknown) {
			imageViewAnim.image = nil
			imageViewAnim.prepareForReuse()
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.Loading) {
			imageViewAnim.image = nil
			imageViewAnim.prepareForReuse()
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.Succeed) {
			if let data = rcmessage.animData {
				imageViewAnim.animate(withGIFData: data)
				imageViewAnim.contentMode = .scaleAspectFill
			}
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.Manual) {
			imageViewAnim.image = nil
			imageViewAnim.prepareForReuse()
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = false
		}

		activityIndicator.color = rcmessage.incoming ? RCKit.activityColorIncoming : RCKit.activityColorOutgoing
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCAnimCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		imageViewAnim.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		let widthActivity = activityIndicator.frame.size.width
		let heightActivity = activityIndicator.frame.size.height
		let xActivity = (size.width - widthActivity) / 2
		let yActivity = (size.height - heightActivity) / 2
		activityIndicator.frame = CGRect(x: xActivity, y: yActivity, width: widthActivity, height: heightActivity)

		let widthManual = imageViewManual.image?.size.width ?? 0
		let heightManual = imageViewManual.image?.size.height ?? 0
		let xManual = (size.width - widthManual) / 2
		let yManual = (size.height - heightManual) / 2
		imageViewManual.frame = CGRect(x: xManual, y: yManual, width: widthManual, height: heightManual)
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

		let photoWidth = CGFloat(rcmessage.mediaWidth)
		let photoHeight = CGFloat(rcmessage.mediaHeight)

		let widthBubble = CGFloat.minimum(RCKit.animBubbleWidth, photoWidth)
		let heightBubble = photoHeight * widthBubble / photoWidth

		rcmessage.sizeBubble = CGSize(width: widthBubble, height: heightBubble)
	}
}
