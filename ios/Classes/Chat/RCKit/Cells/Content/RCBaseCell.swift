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
class RCBaseCell: RCMessagesCell {

	var indexPath: IndexPath!
	var messagesView: RCMessagesView!

	var viewBubble: UIView!

	private var imageAvatar: UIImageView!
	private var labelAvatar: UILabel!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		self.indexPath = indexPath
		self.messagesView = messagesView

		backgroundColor = UIColor.clear

		if (viewBubble == nil) {
			viewBubble = UIView()
			viewBubble.layer.cornerRadius = RCKit.bubbleRadius
			contentView.addSubview(viewBubble)
			bubbleGestureRecognizer(viewBubble)
		}

		if (imageAvatar == nil) {
			imageAvatar = UIImageView()
			imageAvatar.layer.masksToBounds = true
			imageAvatar.layer.cornerRadius = RCKit.avatarDiameter / 2
			imageAvatar.backgroundColor = RCKit.avatarBackColor
			imageAvatar.isUserInteractionEnabled = true
			contentView.addSubview(imageAvatar)
			avatarGestureRecognizer()
		}
		imageAvatar.image = messagesView.avatarImage(indexPath)

		if (labelAvatar == nil) {
			labelAvatar = UILabel()
			labelAvatar.font = RCKit.avatarFont
			labelAvatar.textColor = RCKit.avatarTextColor
			labelAvatar.textAlignment = .center
			contentView.addSubview(labelAvatar)
		}
		labelAvatar.text = (imageAvatar.image == nil) ? messagesView.avatarInitials(indexPath) : nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func layoutSubviews(_ size: CGSize) {

		super.layoutSubviews()

		let rcmessage = messagesView.rcmessageAt(indexPath)

		let widthTable = messagesView.tableView.frame.size.width

		let xBubble = rcmessage.incoming ? RCKit.bubbleMarginLeft : (widthTable - RCKit.bubbleMarginRight - size.width)
		viewBubble.frame = CGRect(x: xBubble, y: 0, width: size.width, height: size.height)

		let diameter = RCKit.avatarDiameter
		let xAvatar = rcmessage.incoming ? RCKit.avatarMarginLeft : (widthTable - RCKit.avatarMarginRight - diameter)
		imageAvatar.frame = CGRect(x: xAvatar, y: size.height - diameter, width: diameter, height: diameter)
		labelAvatar.frame = CGRect(x: xAvatar, y: size.height - diameter, width: diameter, height: diameter)
	}

	// MARK: - Gesture recognizer methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bubbleGestureRecognizer(_ view: UIView) {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapBubble))
		tapGesture.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture)

		let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongBubble(_:)))
		view.addGestureRecognizer(longGesture)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func avatarGestureRecognizer() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapAvatar))
		imageAvatar.addGestureRecognizer(tapGesture)
		tapGesture.cancelsTouchesInView = false
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionTapBubble() {

		messagesView.dismissKeyboard()
		messagesView.actionTapBubble(indexPath)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionTapAvatar() {

		messagesView.dismissKeyboard()
		messagesView.actionTapAvatar(indexPath)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionLongBubble(_ gestureRecognizer: UILongPressGestureRecognizer) {

		switch gestureRecognizer.state {
			case .began:
				actionMenu()
			default:
				break
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionMenu() {

		messagesView.becomeFirstResponder()
		messagesView.dismissKeyboard()

		let menuController = UIMenuController.shared
		menuController.menuItems = messagesView.menuItems(indexPath)

		if #available(iOS 13.0, *) {
			menuController.showMenu(from: contentView, rect: viewBubble.frame)
		} else {
			menuController.setTargetRect(viewBubble.frame, in: contentView)
			menuController.setMenuVisible(true, animated: true)
		}

		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
	}
}
