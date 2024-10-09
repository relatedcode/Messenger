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
protocol StickersDelegate: AnyObject {

	func didSelectSticker(sticker: String)
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class StickersView: UIViewController {

	weak var delegate: StickersDelegate?

	@IBOutlet private var collectionView: UICollectionView!

	private var stickers: [String] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Stickers"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionDismiss))

		collectionView.register(UINib(nibName: "StickersCell", bundle: nil), forCellWithReuseIdentifier: "StickersCell")

		loadStickers()
	}
}

// MARK: - Load stickers
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension StickersView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadStickers() {

		for index in 1...78 {
			let sticker = String(format: "sticker%02d.png", index)
			stickers.append(sticker)
		}
	}
}

// MARK: - User actions
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension StickersView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension StickersView: UICollectionViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return stickers.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickersCell", for: indexPath) as! StickersCell

		cell.bindData(stickers[indexPath.item])

		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension StickersView: UICollectionViewDelegateFlowLayout {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		return CGSize(width: Screen.width/3, height: Screen.width/3)
	}
}

// MARK: - UICollectionViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension StickersView: UICollectionViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		collectionView.deselectItem(at: indexPath, animated: true)

		let sticker = stickers[indexPath.item]
		delegate?.didSelectSticker(sticker: sticker)

		dismiss(animated: true)
	}
}
