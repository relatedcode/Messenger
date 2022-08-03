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
class RCAudioCell: RCBaseCell {

	private var imageViewPlay: UIImageView!
	private var viewProgress: UIProgressView!
	private var labelDuration: UILabel!
	private var imageViewManual: UIImageView!
	private var activityIndicator: UIActivityIndicatorView!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		viewBubble.backgroundColor = rcmessage.incoming ? RCKit.audioBubbleColorIncoming : RCKit.audioBubbleColorOutgoing

		if (imageViewPlay == nil) {
			imageViewPlay = UIImageView()
			viewBubble.addSubview(imageViewPlay)
		}

		if (viewProgress == nil) {
			viewProgress = UIProgressView()
			viewBubble.addSubview(viewProgress)
		}

		if (labelDuration == nil) {
			labelDuration = UILabel()
			labelDuration.font = RCKit.audioFont
			viewBubble.addSubview(labelDuration)
		}

		if (activityIndicator == nil) {
			if #available(iOS 13.0, *) {
				activityIndicator = UIActivityIndicatorView(style: .medium)
			} else {
				activityIndicator = UIActivityIndicatorView(style: .white)
			}
			viewBubble.addSubview(activityIndicator)
		}

		if (imageViewManual == nil) {
			imageViewManual = UIImageView(image: RCKit.audioImageManual)
			viewBubble.addSubview(imageViewManual)
		}

		if (rcmessage.audioStatus == AudioStatus.Stopped)	{ imageViewPlay.image = RCKit.audioImagePlay	}
		if (rcmessage.audioStatus == AudioStatus.Playing)	{ imageViewPlay.image = RCKit.audioImagePause	}
		if (rcmessage.audioStatus == AudioStatus.Paused)	{ imageViewPlay.image = RCKit.audioImagePlay	}

		viewProgress.trackTintColor = rcmessage.incoming ? RCKit.audioTrackColorIncoming : RCKit.audioTrackColorOutgoing
		viewProgress.progressTintColor = rcmessage.incoming ? RCKit.audioProgressColorIncoming : RCKit.audioProgressColorOutgoing

		labelDuration.textColor = rcmessage.incoming ? RCKit.audioDurationColorIncoming : RCKit.audioDurationColorOutgoing

		updateProgress(rcmessage)
		updateDuration(rcmessage)

		if (rcmessage.mediaStatus == MediaStatus.Unknown) {
			imageViewPlay.isHidden = true
			viewProgress.isHidden = true
			labelDuration.isHidden = true
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.Loading) {
			imageViewPlay.isHidden = true
			viewProgress.isHidden = true
			labelDuration.isHidden = true
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.Succeed) {
			imageViewPlay.isHidden = false
			viewProgress.isHidden = false
			labelDuration.isHidden = false
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MediaStatus.Manual) {
			imageViewPlay.isHidden = true
			viewProgress.isHidden = true
			labelDuration.isHidden = true
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = false
		}

		activityIndicator.color = rcmessage.incoming ? RCKit.activityColorIncoming : RCKit.activityColorOutgoing
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCAudioCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		let widthPlay = imageViewPlay.image?.size.width ?? 0
		let heightPlay = imageViewPlay.image?.size.height ?? 0
		let yPlay = (size.height - heightPlay) / 2
		imageViewPlay.frame = CGRect(x: 10, y: yPlay, width: widthPlay, height: heightPlay)

		let xProgress = widthPlay + 20
		let yProgress = size.height / 2 - 10
		let widthProgress = size.width - widthPlay - 30
		viewProgress.frame = CGRect(x: xProgress, y: yProgress, width: widthProgress, height: 5)

		let heightDuration = size.height / 2
		let xDuration = widthPlay + 20
		let yDuration = size.height / 2 - 5
		labelDuration.frame = CGRect(x: xDuration, y: yDuration, width: 50, height: heightDuration)

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

		return CGSize(width: RCKit.audioBubbleWidht, height: RCKit.audioBubbleHeight)
	}

	// MARK: - Progress, Duration update methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateProgress(_ rcmessage: RCMessage) {

		let progress = Float(rcmessage.audioCurrent) / Float(rcmessage.mediaDuration)

		viewProgress.progress = (progress > 0.05) ? progress : 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateDuration(_ rcmessage: RCMessage) {

		if (rcmessage.audioStatus == AudioStatus.Stopped)	{ updateDuration(rcmessage.mediaDuration)		}
		if (rcmessage.audioStatus == AudioStatus.Playing)	{ updateDuration(Int(rcmessage.audioCurrent))	}
		if (rcmessage.audioStatus == AudioStatus.Paused)	{ updateDuration(Int(rcmessage.audioCurrent))	}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateDuration(_ duration: Int) {

		if (duration < 60) {
			labelDuration.text = String(format: "0:%02ld", duration)
		} else {
			labelDuration.text = String(format: "%ld:%02ld", duration / 60, duration % 60)
		}
	}
}
