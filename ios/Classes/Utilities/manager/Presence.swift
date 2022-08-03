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
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Presence: NSObject {

	private var timer: Timer?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Presence = {
		let instance = Presence()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenter.addObserver(self, selector: #selector(initTimer), text: Notifications.AppStarted)
		NotificationCenter.addObserver(self, selector: #selector(initTimer), text: Notifications.UserLoggedIn)
		NotificationCenter.addObserver(self, selector: #selector(stopTimer), text: Notifications.AppWillResign)
		NotificationCenter.addObserver(self, selector: #selector(stopTimer), text: Notifications.UserWillLogout)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Presence {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func initTimer() {

		if (timer == nil) {
			updatePresence()
			timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
				self.updatePresence()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func stopTimer() {

		timer?.invalidate()
		timer = nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Presence {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updatePresence() {

		if (GQLAuth.userId() != "") {
			if (GQLNetwork.isReachable()) {
				scheduler.presence()
			}
		}
	}
}
