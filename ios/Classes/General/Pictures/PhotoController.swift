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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class PhotoController: NavigationController {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(data: Data, caption: String = "") {

		let picturesView = PicturesView(data: data, caption: caption)

		self.init(rootViewController: picturesView)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(image: UIImage, caption: String = "") {

		let picturesView = PicturesView(image: image, caption: caption)

		self.init(rootViewController: picturesView)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(_ photoObjects: [PhotoObject], _ currentIndex: Int = 0) {

		let picturesView = PicturesView(photoObjects, currentIndex)

		self.init(rootViewController: picturesView)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(_ photoObjects: [PhotoObject], _ selectedId: String = "") {

		let picturesView = PicturesView(photoObjects, selectedId)

		self.init(rootViewController: picturesView)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		isModalInPresentation = true
		modalPresentationStyle = .fullScreen

		overrideUserInterfaceStyle = .dark
	}
}
