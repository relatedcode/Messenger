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

import AudioToolbox

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCAudioPlayer: NSObject {

	private var soundIDs: [String : SystemSoundID] = [:]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: RCAudioPlayer = {
		let instance = RCAudioPlayer()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func playSound(_ path: String) {

		if (path.count != 0) {
			playSound(path, isAlert: false)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func playAlert(_ path: String) {

		if (path.count != 0) {
			playSound(path, isAlert: true)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func playVibrateSound() {

		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func stopAllSounds() {

		unloadAllSounds()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func stopSound(_ path: String) {

		if (path.count != 0) {
			unloadSound(path)
		}
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func playSound(_ path: String, isAlert: Bool) {

		var soundID: SystemSoundID = 0

		if (soundIDs[path] == nil) {
			let url = URL(fileURLWithPath: path) as CFURL
			AudioServicesCreateSystemSoundID(url, &soundID)
			soundIDs[path] = soundID
		} else {
			soundID = soundIDs[path]!
		}

		if (soundID != 0) {
			if (isAlert) {
				AudioServicesPlayAlertSound(soundID)
			} else {
				AudioServicesPlaySystemSound(soundID)
			}
		}
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func unloadAllSounds() {

		for path in soundIDs.keys {
			unloadSound(path)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func unloadSound(_ path: String) {

		if let soundID = soundIDs[path] {
			AudioServicesDisposeSystemSoundID(soundID)
			soundIDs.removeValue(forKey: path)
		}
	}
}
