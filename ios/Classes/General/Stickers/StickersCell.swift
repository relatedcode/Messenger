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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class StickersCell: UICollectionViewCell {

	@IBOutlet var imageItem: UIImageView!

	private var sticker = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ sticker: String) {

		if let path = Media.path(sticker: sticker) {
			imageItem.image = UIImage(path: path)
		} else {
			loadImage(sticker)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(_ sticker: String) {

		self.sticker = sticker

		MediaDownload.sticker(sticker) { path, error in
			if (self.sticker == sticker) {
				if (error == nil) {
					self.imageItem.image = UIImage(path: path)
				} else {
					self.loadLater(sticker)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadLater(_ sticker: String) {

		DispatchQueue.main.async(after: 0.5) {
			if (self.sticker == sticker) {
				if (self.imageItem.image == nil) {
					self.loadImage(sticker)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		sticker = ""

		imageItem.image = nil
	}
}
