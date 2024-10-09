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

import Foundation
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
var gqldb: GQLDatabase!
var gqlserver: GQLServer!
var scheduler: Scheduler!

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Backend {

	#warning("Please update your server address here.")
	static let base = "https://yourserveraddress.com"

	static let shared = Backend()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init() {

		initDatabase()
		initServer()
		initScheduler()

		GQLNetwork.setup()
		DataObservers.setup()

		Presence.setup()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Backend {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initDatabase() {

		gqldb = GQLDatabase()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initServer() {

		let link = Backend.link()
		gqlserver = GQLServer(link)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initScheduler() {

		scheduler = Scheduler()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Backend {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func link() -> String {

		return base + ":4000"
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func link(_ path: String) -> String? {

		if (path.isEmpty) {
			return nil
		}
		return base + ":4000" + path
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func url(_ path: String) -> URL? {

		if let temp = link(path) {
			return URL(string: temp)
		}
		return nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Backend {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func sticker(_ sticker: String) -> URL? {

		let link = base + "/stickers/" + sticker

		return URL(string: link)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Backend {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func api() -> String {

		return base + ":4001"
	}
}
