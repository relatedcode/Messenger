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

import AVKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class VideoView: UIViewController {

	private var url: URL!
	private var controller: AVPlayerViewController?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(url: URL) {

		super.init(nibName: nil, bundle: nil)

		self.url = url

		self.isModalInPresentation = true
		self.modalPresentationStyle = .fullScreen
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(path: String) {

		super.init(nibName: nil, bundle: nil)

		self.url = URL(fileURLWithPath: path)

		self.isModalInPresentation = true
		self.modalPresentationStyle = .fullScreen
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		NotificationCenter.addObserver(self, selector: #selector(actionDone), name: .AVPlayerItemDidPlayToEndTime)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: .defaultToSpeaker)

		controller = AVPlayerViewController()
		controller?.player = AVPlayer(url: url)
		controller?.player?.play()

		if (controller != nil) {
			addChild(controller!)
			view.addSubview(controller!.view)
			controller!.view.frame = view.frame
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		NotificationCenter.removeObserver(self)
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		dismiss(animated: true)
	}
}
