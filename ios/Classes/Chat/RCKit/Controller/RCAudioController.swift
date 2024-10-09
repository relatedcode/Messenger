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

import AVKit
import Foundation

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RCAudioController: NSObject {

	private var messagesView: RCMessagesView!
	private var audioPlayer: AVAudioPlayer?
	private var rcmessage: RCMessage?
	private var timer: Timer?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init<T: RCMessagesView>(_ messagesView: T) {

		super.init()

		self.messagesView = messagesView
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	deinit {

		stopAudio()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func toggleAudio(_ indexPath: IndexPath) {

		if isCurrent(indexPath) {
			if isPlaying() { pauseAudio() }
			else if isPaused() { resumeAudio() }
		} else {
			stopAudio()
			playAudio(indexPath)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func stopAudio() {

		audioPlayer?.stop()
		audioPlayer = nil

		stopTimer()
		updateStatus(AudioStatus.Stopped)

		rcmessage = nil
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func playAudio(_ indexPath: IndexPath) {

		guard setupPlayer(indexPath) else { return }

		audioPlayer?.play()

		rcmessage = messagesView.rcmessageAt(indexPath)

		startTimer()
		updateStatus(AudioStatus.Playing)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func setupPlayer(_ indexPath: IndexPath) -> Bool {

		try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: .defaultToSpeaker)

		let rcmessage = messagesView.rcmessageAt(indexPath)
		if let path = rcmessage.audioPath {
			let url = URL(fileURLWithPath: path)
			if let player = try? AVAudioPlayer(contentsOf: url) {
				audioPlayer = player
				audioPlayer?.delegate = self
				return true
			}
		}
		return false
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func pauseAudio() {

		audioPlayer?.pause()

		stopTimer()
		updateStatus(AudioStatus.Paused)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func resumeAudio() {

		audioPlayer?.play()

		startTimer()
		updateStatus(AudioStatus.Playing)
	}
}

// MARK: -
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func isCurrent(_ indexPath: IndexPath) -> Bool {

		let rcmessage = messagesView.rcmessageAt(indexPath)

		return (self.rcmessage?.messageId == rcmessage.messageId)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func isPlaying() -> Bool {

		return (rcmessage?.audioStatus == AudioStatus.Playing)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func isPaused() -> Bool {

		return (rcmessage?.audioStatus == AudioStatus.Paused)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateStatus(_ audioStatus: Int) {

		guard let rcmessage = rcmessage else { return }

		rcmessage.audioStatus = audioStatus
		if (audioStatus == AudioStatus.Stopped) {
			rcmessage.audioCurrent = 0
		}

		messagesView.tableView.reloadData()
	}
}

// MARK: - Timer methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func startTimer() {

		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCell), userInfo: nil, repeats: true)
		RunLoop.main.add(timer!, forMode: .common)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func stopTimer() {

		timer?.invalidate()
		timer = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func updateCell() {

		guard let rcmessage = rcmessage else { return }
		guard let audioPlayer = audioPlayer else { return }

		rcmessage.audioCurrent = audioPlayer.currentTime

		if let indexPath = messagesView.indexPathBy(rcmessage) {
			if let visibleRows = messagesView.tableView.indexPathsForVisibleRows {
				if (visibleRows.contains(indexPath)) {
					if let cell = messagesView.tableView.cellForRow(at: indexPath) as? RCAudioCell {
						cell.updateProgress(rcmessage)
						cell.updateDuration(rcmessage)
					}
				}
			}
		}
	}
}

// MARK: - AVAudioPlayerDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RCAudioController: AVAudioPlayerDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

		stopAudio()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {

		stopAudio()
	}
}
