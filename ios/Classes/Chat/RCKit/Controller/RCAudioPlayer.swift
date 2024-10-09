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

import AudioToolbox

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCAudioPlayer {

	private var sounds: [String: SystemSoundID] = [:]

	static let shared = RCAudioPlayer()
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioPlayer {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func playIncoming() {

		playAlert(file: "rckit_incoming.aiff")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func playOutgoing() {

		playAlert(file: "rckit_outgoing.aiff")
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioPlayer {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func playSound(file: String) {

		playSound(path: Dir.application(file))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func playSound(path: String) {

		shared.playSound(path, false)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func playAlert(file: String) {

		playAlert(path: Dir.application(file))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func playAlert(path: String) {

		shared.playSound(path, true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func playVibrateSound() {

		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func stopAllSounds() {

		shared.unloadAllSounds()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func stopSound(_ path: String) {

		shared.unloadSound(path)
	}
}

// MARK: - Play methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioPlayer {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func playSound(_ path: String, _ isAlert: Bool) {

		if (path.isEmpty) { return }

		let soundId = fetchSoundId(path)

		if (soundId != 0) {
			playSound(soundId, isAlert)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func playSound(_ soundId: SystemSoundID, _ isAlert: Bool) {

		if (isAlert) {
			AudioServicesPlayAlertSound(soundId)
		} else {
			AudioServicesPlaySystemSound(soundId)
		}
	}
}

// MARK: - SoundId methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioPlayer {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func fetchSoundId(_ path: String) -> SystemSoundID {

		if let soundId = sounds[path] {
			return soundId
		}
		return createSoundId(path)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createSoundId(_ path: String) -> SystemSoundID {

		var soundId: SystemSoundID = 0
		let url = URL(fileURLWithPath: path) as CFURL
		AudioServicesCreateSystemSoundID(url, &soundId)
		sounds[path] = soundId

		return soundId
	}
}

// MARK: - Unload methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioPlayer {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unloadAllSounds() {

		for path in sounds.keys {
			unloadSound(path)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unloadSound(_ path: String) {

		if let soundId = sounds[path] {
			AudioServicesDisposeSystemSoundID(soundId)
			sounds.removeValue(forKey: path)
		}
	}
}
