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
class MapView: UIViewController {

	@IBOutlet private var mapView: MKMapView!

	private var location: CLLocation!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(location: CLLocation) {

		super.init(nibName: nil, bundle: nil)

		self.location = location
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {

		super.init(nibName: nil, bundle: nil)

		self.location = CLLocation(latitude: latitude, longitude: longitude)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Map"

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDismiss))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		var region: MKCoordinateRegion = MKCoordinateRegion()
		region.center.latitude = location.coordinate.latitude
		region.center.longitude = location.coordinate.longitude
		region.span.latitudeDelta = CLLocationDegrees(0.01)
		region.span.longitudeDelta = CLLocationDegrees(0.01)
		mapView.setRegion(region, animated: false)

		let annotation = MKPointAnnotation()
		mapView.addAnnotation(annotation)
		annotation.coordinate = location.coordinate
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}
}
