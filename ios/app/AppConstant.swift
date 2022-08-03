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

import Foundation

//-----------------------------------------------------------------------------------------------------------------------------------------------
enum Notifications {

	static let AppStarted		= "NotificationAppStarted"
	static let AppWillResign	= "NotificationAppWillResign"

	static let UserLoggedIn		= "NotificationUserLoggedIn"
	static let UserWillLogout	= "NotificationUserWillLogout"
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------------------------------------------------------------------------
enum MessageStatus {

	static let Queued	= "Queued"
	static let Failed	= "Failed"
	static let Sent		= "Sent"
	static let Read		= "Read"
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
enum MediaType {

	static let Photo	= 1
	static let Video	= 2
	static let Audio	= 3
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
enum MediaStatus {

	static let Unknown	= 0
	static let Loading	= 1
	static let Manual	= 2
	static let Succeed	= 3
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
enum AudioStatus {

	static let Stopped	= 1
	static let Playing	= 2
	static let Paused	= 3
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
enum App {

	static let DefaultTab		= 0
	static let MaxVideoDuration	= TimeInterval(10)
	static let TextShareApp		= "Check out https://related.chat"
}
