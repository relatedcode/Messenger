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

import UIKit
import PasscodeKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class PasscodeView: UIViewController {

	@IBOutlet private var tableView: UITableView!

	@IBOutlet private var cellTurnPasscode: UITableViewCell!
	@IBOutlet private var cellChangePasscode: UITableViewCell!
	@IBOutlet private var cellBiometric: UITableViewCell!

	@IBOutlet private var switchBiometric: UISwitch!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Passcode"

		switchBiometric.addTarget(self, action: #selector(actionBiometric), for: .valueChanged)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		updateViewDetails()
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionTurnPasscode() {

		if (PasscodeKit.enabled()) {
			PasscodeKit.removePasscode(self)
		} else {
			PasscodeKit.createPasscode(self)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionChangePasscode() {

		if (PasscodeKit.enabled()) {
			PasscodeKit.changePasscode(self)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionBiometric() {

		PasscodeKit.biometric(switchBiometric.isOn)
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateViewDetails() {

		if (PasscodeKit.enabled()) {
			cellTurnPasscode.textLabel?.text = "Turn Passcode Off"
			cellChangePasscode.textLabel?.textColor = UIColor.systemBlue
		} else {
			cellTurnPasscode.textLabel?.text = "Turn Passcode On"
			cellChangePasscode.textLabel?.textColor = UIColor.lightGray
		}

		switchBiometric.isOn = PasscodeKit.biometric()

		tableView.reloadData()
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PasscodeView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return PasscodeKit.enabled() ? 2 : 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 2 }
		if (section == 1) { return 1 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {

		if (section == 1) { return "Allow to use Face ID (or Touch ID) to unlock the app." }

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellTurnPasscode	}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellChangePasscode	}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellBiometric		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PasscodeView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 0) { actionTurnPasscode()		}
		if (indexPath.section == 0) && (indexPath.row == 1) { actionChangePasscode()	}
	}
}
