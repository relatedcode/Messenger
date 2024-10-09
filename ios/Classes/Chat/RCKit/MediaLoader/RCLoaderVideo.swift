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
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCLoaderVideo {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func start(_ rcmessage: RCMessage, in tableView: UITableView) {

		if let path = Media.path(video: rcmessage.fileURL) {
			showMedia(rcmessage, path: path)
		} else {
			loadMedia(rcmessage, in: tableView)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func manual(_ rcmessage: RCMessage, in tableView: UITableView) {

		Media.clearManual(video: rcmessage.fileURL)
		downloadMedia(rcmessage, in: tableView)
		tableView.reloadData()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func loadMedia(_ rcmessage: RCMessage, in tableView: UITableView) {

		let network = Network.video()

		if (network == Network.Manual) || ((network == Network.WiFi) && (GQLNetwork.isWiFi() == false)) {
			rcmessage.mediaStatus = MediaStatus.Manual
		} else {
			downloadMedia(rcmessage, in: tableView)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func downloadMedia(_ rcmessage: RCMessage, in tableView: UITableView) {

		rcmessage.mediaStatus = MediaStatus.Loading

		MediaDownload.video(rcmessage.fileURL) { path, error in
			if (error == nil) {
				showMedia(rcmessage, path: path)
			} else {
				rcmessage.mediaStatus = MediaStatus.Manual
			}
			tableView.reloadData()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func showMedia(_ rcmessage: RCMessage, path: String) {

		let thumbnail = Video.thumbnail(path)

		rcmessage.videoPath = path
		rcmessage.videoThumbnail = thumbnail.square(to: 200)
		rcmessage.mediaStatus = MediaStatus.Succeed
	}
}
