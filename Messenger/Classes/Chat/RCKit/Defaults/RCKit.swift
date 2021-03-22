//
// Copyright (c) 2021 Related Code - https://relatedcode.com
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
enum RCKit {

	// General
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let widthScreen					= UIScreen.main.bounds.size.width
	static let heightScreen					= UIScreen.main.bounds.size.height

	// Section
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let sectionHeaderMargin			= CGFloat(8)
	static let sectionFooterMargin			= CGFloat(8)

	// Header upper
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let headerUpperHeight			= CGFloat(20)
	static let headerUpperLeft				= CGFloat(10)
	static let headerUpperRight				= CGFloat(10)

	static let headerUpperColor				= UIColor.lightGray
	static let headerUpperFont				= UIFont.systemFont(ofSize: 12)

	// Header lower
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let headerLowerHeight			= CGFloat(15)
	static let headerLowerLeft				= CGFloat(50)
	static let headerLowerRight				= CGFloat(50)

	static let headerLowerColor				= UIColor.lightGray
	static let headerLowerFont				= UIFont.systemFont(ofSize: 12)

	// Footer upper
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let footerUpperHeight			= CGFloat(15)
	static let footerUpperLeft				= CGFloat(50)
	static let footerUpperRight				= CGFloat(50)

	static let footerUpperColor				= UIColor.lightGray
	static let footerUpperFont				= UIFont.systemFont(ofSize: 12)

	// Footer lower
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let footerLowerHeight			= CGFloat(15)
	static let footerLowerLeft				= CGFloat(10)
	static let footerLowerRight				= CGFloat(10)

	static let footerLowerColor				= UIColor.lightGray
	static let footerLowerFont				= UIFont.systemFont(ofSize: 12)

	// Bubble
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let bubbleMarginLeft				= CGFloat(40)
	static let bubbleMarginRight			= CGFloat(40)
	static let bubbleRadius					= CGFloat(15)

	// Avatar
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let avatarDiameter				= CGFloat(30)
	static let avatarMarginLeft				= CGFloat(5)
	static let avatarMarginRight			= CGFloat(5)

	static let avatarBackColor				= UIColor.lightGray
	static let avatarTextColor				= UIColor.white

	static let avatarFont					= UIFont.systemFont(ofSize: 12)

	// Text cell
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let textBubbleWidthMax			= 0.70 * widthScreen
	static let textBubbleWidthMin			= CGFloat(45)
	static let textBubbleHeightMin			= CGFloat(35)

	static let textBubbleColorOutgoing		= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let textBubbleColorIncoming		= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

	static let textTextColorOutgoing		= UIColor.white
	static let textTextColorIncoming		= UIColor.black

	static let textFont						= UIFont.systemFont(ofSize: 16)

	static let textInsetLeft				= CGFloat(10)
	static let textInsetRight				= CGFloat(10)
	static let textInsetTop					= CGFloat(10)
	static let textInsetBottom				= CGFloat(10)

	static let textInset = UIEdgeInsets.init(top: textInsetTop, left: textInsetLeft, bottom: textInsetBottom, right: textInsetRight)

	// Emoji cell
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let emojiBubbleWidthMax			= 0.70 * widthScreen
	static let emojiBubbleWidthMin			= CGFloat(45)
	static let emojiBubbleHeightMin			= CGFloat(30)

	static let emojiBubbleColorOutgoing		= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let emojiBubbleColorIncoming		= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

	static let emojiFont					= UIFont.systemFont(ofSize: 46)

	static let emojiInsetLeft				= CGFloat(10)
	static let emojiInsetRight				= CGFloat(10)
	static let emojiInsetTop				= CGFloat(10)
	static let emojiInsetBottom				= CGFloat(10)

	static let emojiInset = UIEdgeInsets.init(top: emojiInsetTop, left: emojiInsetLeft, bottom: emojiInsetBottom, right: emojiInsetRight)

	// Photo cell
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let photoBubbleWidth				= 0.70 * widthScreen

	static let photoBubbleColorOutgoing		= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let photoBubbleColorIncoming		= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

	static let photoImageManual				= UIImage(named: "rckit_manual")!

	// Video cell
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let videoBubbleWidth				= 0.70 * widthScreen
	static let videoBubbleHeight			= 0.70 * widthScreen

	static let videoBubbleColorOutgoing		= UIColor.lightGray
	static let videoBubbleColorIncoming		= UIColor.lightGray

	static let videoImagePlay				= UIImage(named: "rckit_videoplay")!
	static let videoImageManual				= UIImage(named: "rckit_manual")!

	// Audio cell
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let audioBubbleWidht				= CGFloat(150)
	static let audioBubbleHeight			= CGFloat(40)

	static let audioBubbleColorOutgoing		= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let audioBubbleColorIncoming		= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

	static let audioTrackColorOutgoing		= UIColor.white
	static let audioTrackColorIncoming		= UIColor.white
	static let audioProgressColorOutgoing	= UIColor.lightGray
	static let audioProgressColorIncoming	= UIColor.lightGray

	static let audioDurationColorOutgoing	= UIColor.white
	static let audioDurationColorIncoming	= UIColor.black

	static let audioImagePlay				= UIImage(named: "rckit_audioplay")!
	static let audioImagePause				= UIImage(named: "rckit_audiopause")!
	static let audioImageManual				= UIImage(named: "rckit_manual")!

	static let audioFont					= UIFont.systemFont(ofSize: 12)

	// Sticker cell
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let stickerBubbleWidth			= 0.70 * widthScreen
	static let stickerBubbleHeight			= 0.70 * widthScreen

	static let stickerBubbleColorOutgoing	= UIColor.clear
	static let stickerBubbleColorIncoming	= UIColor.clear

	static let stickerImageManual			= UIImage(named: "rckit_manual")!

	// Location cell
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let locationBubbleWidth			= 0.70 * widthScreen
	static let locationBubbleHeight 		= 0.70 * widthScreen

	static let locationBubbleColorOutgoing	= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let locationBubbleColorIncoming	= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

	// Activity indicator
	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let activityColorOutgoing		= UIColor.white
	static let activityColorIncoming		= UIColor.darkGray
}
