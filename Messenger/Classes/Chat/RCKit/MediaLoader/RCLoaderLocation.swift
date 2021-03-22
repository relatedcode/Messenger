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

import MapKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCLoaderLocation: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func start(_ rcmessage: RCMessage, in tableView: UITableView) {

		loadMedia(rcmessage, in: tableView)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func loadMedia(_ rcmessage: RCMessage, in tableView: UITableView) {

		rcmessage.mediaStatus = MediaStatus.Loading

		var region: MKCoordinateRegion = MKCoordinateRegion()
		region.center.latitude = rcmessage.latitude
		region.center.longitude = rcmessage.longitude
		region.span.latitudeDelta = CLLocationDegrees(0.005)
		region.span.longitudeDelta = CLLocationDegrees(0.005)

		let options = MKMapSnapshotter.Options()
		options.region = region
		options.size = CGSize(width: RCKit.locationBubbleWidth, height: RCKit.locationBubbleHeight)
		options.scale = UIScreen.main.scale

		let snapshotter = MKMapSnapshotter(options: options)
		snapshotter.start(with: DispatchQueue.global(qos: .default), completionHandler: { snapshot, error in
			if let snapshot = snapshot {
				DispatchQueue.main.async {
					showMedia(rcmessage, snapshot: snapshot)
					tableView.reloadData()
				}
			}
		})
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func showMedia(_ rcmessage: RCMessage, snapshot: MKMapSnapshotter.Snapshot) {

		UIGraphicsBeginImageContextWithOptions(snapshot.image.size, true, snapshot.image.scale)
		do {
			snapshot.image.draw(at: CGPoint.zero)
			let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
			var point = snapshot.point(for: CLLocationCoordinate2DMake(rcmessage.latitude, rcmessage.longitude))
			point.x += pin.centerOffset.x - (pin.bounds.size.width / 2)
			point.y += pin.centerOffset.y - (pin.bounds.size.height / 2)
			pin.image?.draw(at: point)
			rcmessage.locationThumbnail = UIGraphicsGetImageFromCurrentImageContext()
		}
		UIGraphicsEndImageContext()

		rcmessage.mediaStatus = MediaStatus.Succeed
	}
}
