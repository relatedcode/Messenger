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

import CoreLocation

//-----------------------------------------------------------------------------------------------------------------------------------------------
class Location: NSObject, CLLocationManagerDelegate {

	private var locationManager: CLLocationManager?
	private var location = CLLocation()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Location = {
		let instance = Location()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func start() {

		shared.locationManager?.startUpdatingLocation()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func stop() {

		shared.locationManager?.stopUpdatingLocation()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func latitude() -> CLLocationDegrees {

		return shared.location.coordinate.latitude
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func longitude() -> CLLocationDegrees {

		return shared.location.coordinate.longitude
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func address(completion: @escaping (String?, String?, String?) -> Void) {

		CLGeocoder().reverseGeocodeLocation(shared.location) { placemarks, error in
			if let placemark = placemarks?.first {
				completion(placemark.locality, placemark.country, placemark.isoCountryCode)
			} else {
				completion(nil, nil, nil)
			}
		}
	}

	// MARK: - Instance methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.desiredAccuracy = kCLLocationAccuracyBest
		locationManager?.requestWhenInUseAuthorization()
	}

	// MARK: - CLLocationManagerDelegate
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

		if let location = locations.last {
			self.location = location
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

	}
}
