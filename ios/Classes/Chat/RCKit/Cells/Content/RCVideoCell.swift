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
class RCVideoCell: RCBaseCell {

	private var imageViewThumb: UIImageView!
	private var imageViewPlay: UIImageView!
	private var imageViewManual: UIImageView!
	private var activityIndicator: UIActivityIndicatorView!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		viewBubble.backgroundColor = rcmessage.incoming ? RCKit.videoBubbleColorIncoming : RCKit.videoBubbleColorOutgoing

		if (imageViewThumb == nil) {
			imageViewThumb = UIImageView()
			imageViewThumb.layer.masksToBounds = true
			imageViewThumb.layer.cornerRadius = RCKit.bubbleRadius
			viewBubble.addSubview(imageViewThumb)
		}

		if (imageViewPlay == nil) {
			imageViewPlay = UIImageView(image: RCKit.videoImagePlay)
			viewBubble.addSubview(imageViewPlay)
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
			imageViewManual = UIImageView(image: RCKit.videoImageManual)
			viewBubble.addSubview(imageViewManual)
		}

		if (rcmessage.mediaStatus == MediaStatus.Unknown) {
			imageViewThumb.image = nil
			imageViewPlay.isHidden = true
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.Loading) {
			imageViewThumb.image = nil
			imageViewPlay.isHidden = true
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.Succeed) {
			imageViewThumb.image = rcmessage.videoThumbnail
			imageViewPlay.isHidden = false
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.Manual) {
			imageViewThumb.image = nil
			imageViewPlay.isHidden = true
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = false
		}

		activityIndicator.color = rcmessage.incoming ? RCKit.activityColorIncoming : RCKit.activityColorOutgoing
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCVideoCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		imageViewThumb.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		let widthPlay = imageViewPlay.image?.size.width ?? 0
		let heightPlay = imageViewPlay.image?.size.height ?? 0
		let xPlay = (size.width - widthPlay) / 2
		let yPlay = (size.height - heightPlay) / 2
		imageViewPlay.frame = CGRect(x: xPlay, y: yPlay, width: widthPlay, height: heightPlay)

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

		return CGSize(width: RCKit.videoBubbleWidth, height: RCKit.videoBubbleHeight)
	}
}
