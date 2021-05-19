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
@objc protocol CountriesDelegate: AnyObject {

	func didSelectCountry(name: String, code: String)
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class CountriesView: UIViewController {

	@IBOutlet weak var delegate: CountriesDelegate?

	@IBOutlet private var tableView: UITableView!

	private var countries: [[String: String]] = []
	private var sections: [[[String: String]]] = []
	private let collation = UILocalizedIndexedCollation.current()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Countries"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionDismiss))

		loadCountries()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadCountries() {

		let path = Dir.application("countries.plist")
		if let array = NSArray(contentsOfFile: path) as? [[String: String]] {
			countries = array
		}

		let selector = #selector(NSDictionary.name)
		sections = Array(repeating: [], count: collation.sectionTitles.count)

		if let sorted = collation.sortedArray(from: countries, collationStringSelector: selector) as? [[String: String]] {
			for country in sorted {
				let section = collation.section(for: country, collationStringSelector: selector)
				sections[section].append(country)
			}
		}
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension CountriesView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return sections.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return sections[section].count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		return (sections[section].count != 0) ? collation.sectionTitles[section] : nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {

		return collation.sectionIndexTitles
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {

		return collation.section(forSectionIndexTitle: index)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: "cell") }

		let country = sections[indexPath.section][indexPath.row]
		cell.textLabel?.text = country["name"]

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension CountriesView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let country = sections[indexPath.section][indexPath.row]

		dismiss(animated: true) {
			if let name = country["name"], let code = country["dial_code"] {
				self.delegate?.didSelectCountry(name: name, code: code)
			}
		}
	}
}
