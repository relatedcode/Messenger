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
import InputBarAccessoryView

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCMessagesView: UIViewController {

	@IBOutlet var viewTitle: UIView!
	@IBOutlet var labelTitle1: UILabel!
	@IBOutlet var labelTitle2: UILabel!

	@IBOutlet var tableView: UITableView!
	@IBOutlet var viewLoadEarlier: UIView!

	var messageInputBar = InputBarAccessoryView()
	private var keyboardManager = KeyboardManager()

	private var isTyping = false
	private var textTitle: String?

	private var heightKeyboard: CGFloat = 0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init() {

		self.init(nibName: "RCMessagesView", bundle: nil)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		navigationItem.titleView = viewTitle

		tableView.register(RCHeaderCell1.self, forCellReuseIdentifier: "RCHeaderCell1")
		tableView.register(RCHeaderCell2.self, forCellReuseIdentifier: "RCHeaderCell2")

		tableView.register(RCTextCell.self, forCellReuseIdentifier: "RCTextCell")
		tableView.register(RCEmojiCell.self, forCellReuseIdentifier: "RCEmojiCell")
		tableView.register(RCPhotoCell.self, forCellReuseIdentifier: "RCPhotoCell")
		tableView.register(RCAnimCell.self, forCellReuseIdentifier: "RCAnimCell")
		tableView.register(RCVideoCell.self, forCellReuseIdentifier: "RCVideoCell")
		tableView.register(RCAudioCell.self, forCellReuseIdentifier: "RCAudioCell")
		tableView.register(RCStickerCell.self, forCellReuseIdentifier: "RCStickerCell")

		tableView.register(RCFooterCell1.self, forCellReuseIdentifier: "RCFooterCell1")
		tableView.register(RCFooterCell2.self, forCellReuseIdentifier: "RCFooterCell2")

		tableView.tableHeaderView = viewLoadEarlier

		configureKeyboardActions()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		if (messageInputBar.superview == nil) {
			configureMessageInputBar()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLayoutSubviews() {

		super.viewDidLayoutSubviews()

		layoutTableView()
	}

	// MARK: - Typing indicator methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorShow(_ typing: Bool, text: String = "typing...") {

		if (typing == true) && (isTyping == false) {
			textTitle = labelTitle2.text
			labelTitle2.text = text
		}
		if (typing == false) && (isTyping == true) {
			labelTitle2.text = textTitle
		}
		isTyping = typing
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorUpdate() {

	}

	// MARK: - Load earlier methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadEarlierShow(_ show: Bool) {

		viewLoadEarlier.isHidden = !show
		var frame: CGRect = viewLoadEarlier.frame
		frame.size.height = show ? 50 : 0
		viewLoadEarlier.frame = frame
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLoadEarlier(_ sender: Any) {

		actionLoadEarlier()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionLoadEarlier() {

	}

	// MARK: - Title methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionTitle(_ sender: Any) {

		actionTitle()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionTitle() {

	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func resizeTableView(_ duration: TimeInterval) {

		var frame1 = tableView.frame
		var frame2 = tableView.frame

		frame1.origin.y = frame1.origin.y - heightKeyboard
		frame2.size.height = frame2.size.height - heightKeyboard

		UIView.animate(withDuration: duration, animations: {
			self.tableView.frame = frame1
		}, completion: { _ in
			self.tableView.frame = frame2
			self.positionToBottom()
		})
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func layoutTableView() {

		let widthView	= view.frame.size.width
		let heightView	= view.frame.size.height

		let leftSafe	= view.safeAreaInsets.left
		let rightSafe	= view.safeAreaInsets.right

		let heightInput = messageInputBar.bounds.height

		let widthTable = widthView - leftSafe - rightSafe
		let heightTable = heightView - heightInput - heightKeyboard

		tableView.frame = CGRect(x: leftSafe, y: 0, width: widthTable, height: heightTable)
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshTableView() {

		tableView.reloadData()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshTableView(keepOffset: Bool) {

		tableView.setContentOffset(tableView.contentOffset, animated: false)

		let contentSize1 = tableView.contentSize
		tableView.reloadData()
		tableView.layoutIfNeeded()
		let contentSize2 = tableView.contentSize

		let offsetX = tableView.contentOffset.x + (contentSize2.width - contentSize1.width)
		let offsetY = tableView.contentOffset.y + (contentSize2.height - contentSize1.height)

		tableView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func positionToBottom() {

		scrollToBottom(animated: false)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollToBottom() {

		scrollToBottom(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollToBottom(animated: Bool) {

		if (tableView.numberOfSections > 0) {
			let indexPath = IndexPath(row: 0, section: tableView.numberOfSections-1)
			tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
		}
	}
}

// MARK: - Message Source methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func rcmessageAt(_ indexPath: IndexPath) -> RCMessage {

		return RCMessage()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func indexPathBy(_ rcmessage: RCMessage) -> IndexPath? {

		return nil
	}
}

// MARK: - Message Cell methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView {

	// Avatar methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func avatarInitials(_ indexPath: IndexPath) -> String {

		return ""
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func avatarImage(_ indexPath: IndexPath) -> UIImage? {

		return nil
	}

	// Header, Footer methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func textHeaderUpper(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func textHeaderLower(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func textFooterUpper(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func textFooterLower(_ indexPath: IndexPath) -> String? {

		return nil
	}

	// User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionTapBubble(_ indexPath: IndexPath) {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionTapAvatar(_ indexPath: IndexPath) {

	}
}

// MARK: - Menu Controller methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func menuItems(_ indexPath: IndexPath) -> [RCMenuItem]? {

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

		return false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override var canBecomeFirstResponder: Bool {

		return true
	}
}

// MARK: - Keyboard methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func configureKeyboardActions() {

		NotificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification)
		NotificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification)
		NotificationCenter.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func keyboardWillShow(_ notification: Notification?) {

		if (heightKeyboard != 0) { return }

		if let info = notification?.userInfo {
			if let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
				if let keyboard = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
					heightKeyboard = keyboard.size.height
					if (tableView.contentSize.height >= tableView.frame.size.height) {
						resizeTableView(duration)
						scrollToBottom()
					} else {
						layoutTableView()
						positionToBottom()
					}
				}
			}
		}

		UIMenuController.shared.menuItems = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func keyboardWillHide(_ notification: Notification?) {

		heightKeyboard = 0

		layoutTableView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func keyboardWillChange(_ notification: Notification?) {

		if let info = notification?.userInfo {
			if let frameBegin = info[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
				if let frameEnd = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
					let heightScreen = UIScreen.main.bounds.size.height
					if (frameBegin.origin.y != heightScreen) && (frameEnd.origin.y != heightScreen) {
						heightKeyboard = frameEnd.size.height
						layoutTableView()
						scrollToBottom()
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func dismissKeyboard() {

		messageInputBar.inputTextView.resignFirstResponder()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func keyboardHeight() -> CGFloat {

		if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
			let inputSetContainerView = NSClassFromString("UIInputSetContainerView"),
			let inputSetHostView = NSClassFromString("UIInputSetHostView") {

			for window in UIApplication.shared.windows {
				if window.isKind(of: keyboardWindowClass) {
					for firstSubView in window.subviews {
						if firstSubView.isKind(of: inputSetContainerView) {
							for secondSubView in firstSubView.subviews {
								if secondSubView.isKind(of: inputSetHostView) {
									return secondSubView.frame.size.height
								}
							}
						}
					}
				}
			}
		}
		return 0
	}
}

// MARK: - Message Input Bar methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func configureMessageInputBar() {

		view.addSubview(messageInputBar)

		keyboardManager.bind(inputAccessoryView: messageInputBar)
		keyboardManager.bind(to: tableView)

		messageInputBar.delegate = self

		let button = InputBarButtonItem()
		button.image = UIImage(named: "rckit_attach")
		button.setSize(CGSize(width: 36, height: 36), animated: false)

		button.onKeyboardSwipeGesture { item, gesture in
			if (gesture.direction == .left)	 { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true) }
			if (gesture.direction == .right) { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true) }
		}

		button.onTouchUpInside { item in
			self.actionAttachMessage()
		}

		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(actionLongPress(_:)))
		button.addGestureRecognizer(longPress)

		messageInputBar.setStackViewItems([button], forStack: .left, animated: false)

		messageInputBar.sendButton.title = nil
		messageInputBar.sendButton.image = UIImage(named: "rckit_send")
		messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)

		messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: true)
		messageInputBar.setRightStackViewWidthConstant(to: 36, animated: true)

		messageInputBar.inputTextView.isImagePasteEnabled = false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionLongPress(_ gesture: UILongPressGestureRecognizer) {

		if (gesture.state == .began) {
			actionAttachLong()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionAttachLong() {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionAttachMessage() {

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionSendMessage(_ text: String) {

	}
}

// MARK: - InputBarAccessoryViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView: InputBarAccessoryViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {

		if (text != "") {
			typingIndicatorUpdate()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {

		DispatchQueue.main.async(after: 0.1) {
			self.scrollToBottom()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

		for component in inputBar.inputTextView.components {
			if let text = component as? String {
				actionSendMessage(text)
			}
		}
		messageInputBar.inputTextView.text = ""
		messageInputBar.invalidatePlugins()
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.row == 0)	{ return tableViewCell(tableView, for: RCHeaderCell1.self, at: indexPath)	}
		if (indexPath.row == 1)	{ return tableViewCell(tableView, for: RCHeaderCell2.self, at: indexPath)	}

		if (indexPath.row == 2) {
			let rcmessage = rcmessageAt(indexPath)
			if (rcmessage.type == MessageType.Text)		{ return tableViewCell(tableView, for: RCTextCell.self, at: indexPath)		}
			if (rcmessage.type == MessageType.Emoji)	{ return tableViewCell(tableView, for: RCEmojiCell.self, at: indexPath)		}
			if (rcmessage.type == MessageType.Photo)	{ return tableViewCell(tableView, for: RCPhotoCell.self, at: indexPath)		}
			if (rcmessage.type == MessageType.Anim)		{ return tableViewCell(tableView, for: RCAnimCell.self, at: indexPath)		}
			if (rcmessage.type == MessageType.Video)	{ return tableViewCell(tableView, for: RCVideoCell.self, at: indexPath)		}
			if (rcmessage.type == MessageType.Audio)	{ return tableViewCell(tableView, for: RCAudioCell.self, at: indexPath)		}
			if (rcmessage.type == MessageType.Sticker)	{ return tableViewCell(tableView, for: RCStickerCell.self, at: indexPath)	}
		}

		if (indexPath.row == 3)	{ return tableViewCell(tableView, for: RCFooterCell1.self, at: indexPath)	}
		if (indexPath.row == 4)	{ return tableViewCell(tableView, for: RCFooterCell2.self, at: indexPath)	}

		return UITableViewCell()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableViewCell<T: RCMessagesCell>(_ tableView: UITableView, for cellType: T.Type, at indexPath: IndexPath) -> T {

		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: cellType), for: indexPath) as! T
		cell.bindData(self, at: indexPath)
		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

		view.tintColor = UIColor.clear
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {

		view.tintColor = UIColor.clear
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		if (indexPath.row == 0)	{ return RCHeaderCell1.height(self, at: indexPath)	}
		if (indexPath.row == 1)	{ return RCHeaderCell2.height(self, at: indexPath)	}

		if (indexPath.row == 2) {
			let rcmessage = rcmessageAt(indexPath)
			if (rcmessage.type == MessageType.Text)		{ return RCTextCell.height(self, at: indexPath)		}
			if (rcmessage.type == MessageType.Emoji)	{ return RCEmojiCell.height(self, at: indexPath)	}
			if (rcmessage.type == MessageType.Photo)	{ return RCPhotoCell.height(self, at: indexPath)	}
			if (rcmessage.type == MessageType.Anim)		{ return RCAnimCell.height(self, at: indexPath)		}
			if (rcmessage.type == MessageType.Video)	{ return RCVideoCell.height(self, at: indexPath)	}
			if (rcmessage.type == MessageType.Audio)	{ return RCAudioCell.height(self, at: indexPath)	}
			if (rcmessage.type == MessageType.Sticker)	{ return RCStickerCell.height(self, at: indexPath)	}
		}

		if (indexPath.row == 3)	{ return RCFooterCell1.height(self, at: indexPath)	}
		if (indexPath.row == 4)	{ return RCFooterCell2.height(self, at: indexPath)	}

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

		return RCKit.sectionHeaderMargin
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		return RCKit.sectionFooterMargin
	}
}
