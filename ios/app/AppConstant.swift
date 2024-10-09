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

// MARK: -
enum Notifications {

	static let AppStarted		= "NotificationAppStarted"
	static let AppWillResign	= "NotificationAppWillResign"

	static let UserLoggedIn		= "NotificationUserLoggedIn"
	static let UserWillLogout	= "NotificationUserWillLogout"
}

// MARK: -
enum MessageType {

	static let Text		= "text"
	static let Emoji	= "emoji"
	static let Anim		= "anim"
	static let Photo	= "photo"
	static let Video	= "video"
	static let Audio	= "audio"
	static let Sticker	= "sticker"
	static let File		= "file"
}

// MARK: -
enum MessageStatus {

	static let Queued	= "Queued"
	static let Failed	= "Failed"
	static let Sent		= "Sent"
	static let Read		= "Read"
}

// MARK: -
enum MediaType {

	static let Photo	= 1
	static let Video	= 2
	static let Audio	= 3
}

// MARK: -
enum MediaStatus {

	static let Unknown	= 0
	static let Loading	= 1
	static let Manual	= 2
	static let Succeed	= 3
}

// MARK: -
enum AudioStatus {

	static let Stopped	= 1
	static let Playing	= 2
	static let Paused	= 3
}

// MARK: -
enum AppColor {

	static let main = UIColor.systemTeal
	static let third = UIColor.systemBlue
	static let second = UIColor.white
}

// MARK: -
enum Appx {

	static let DefaultTab	= 0
	static let MaxVideo		= 10.0
	static let TextShareApp	= "Check out https://related.chat"
}

// MARK: -
enum Screen {

	static let width	= UIScreen.main.bounds.size.width
	static let height	= UIScreen.main.bounds.size.height
}
