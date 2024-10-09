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
class PicturesView: UICollectionViewController {

	private var photoObjects: [PhotoObject] = []
	private var currentIndex = 0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(data: Data, caption: String = "") {

		self.init(collectionViewLayout: UICollectionViewFlowLayout())

		let photoObject = PhotoObject("", data, "", caption)

		self.photoObjects = [photoObject]
		self.currentIndex = 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(image: UIImage, caption: String = "") {

		self.init(collectionViewLayout: UICollectionViewFlowLayout())

		let photoObject = PhotoObject("", image, "", caption)

		self.photoObjects = [photoObject]
		self.currentIndex = 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(_ photoObjects: [PhotoObject], _ currentIndex: Int = 0) {

		self.init(collectionViewLayout: UICollectionViewFlowLayout())

		self.photoObjects = photoObjects
		self.currentIndex = currentIndex
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(_ photoObjects: [PhotoObject], _ selectedId: String = "") {

		self.init(collectionViewLayout: UICollectionViewFlowLayout())

		self.photoObjects = photoObjects
		self.currentIndex = 0

		if (selectedId.isEmpty == false) {
			for (index, photoObject) in photoObjects.enumerated() {
				if (photoObject.id() == selectedId) {
					currentIndex = index
					break
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init(collectionViewLayout layout: UICollectionViewLayout) {

		super.init(collectionViewLayout: layout)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		fatalError()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		let standardAppearance = UINavigationBarAppearance()
		standardAppearance.configureWithTransparentBackground()
		standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		standardAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
		standardAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.7)

		navigationController?.navigationBar.tintColor = .white
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.navigationBar.standardAppearance = standardAppearance
		navigationController?.navigationBar.layoutIfNeeded()

		let image = UIImage(systemName: "xmark")
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(actionDismiss))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionShare))

		NotificationCenter.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification)

		updateTitle()
		configureCollectionView()
		configureGesture()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		DispatchQueue.main.async {
			self.collectionView.reloadData()
		}
		DispatchQueue.main.async(after: 0.1) {
			self.scrollToCurrent()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - Helper Methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func orientationDidChange(_ notification: NSNotification) {

		collectionView.layoutIfNeeded()

		DispatchQueue.main.async(after: 0.1) {
			self.scrollToCurrent()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollToCurrent(_ animated: Bool = false) {

		let indexPath = IndexPath(item: currentIndex, section: 0)
		collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func updateTitle() {

		title = "\(currentIndex+1) of \(photoObjects.count)"
	}
}

// MARK: - Configure Collection View
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func configureCollectionView() {

		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.contentInsetAdjustmentBehavior = .never
		collectionView.isPagingEnabled = true
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.scrollDirection = .horizontal
			layout.minimumLineSpacing = 0
			layout.minimumInteritemSpacing = 0
			layout.sectionInset = .zero
			layout.itemSize = collectionView.frame.size
		}
		collectionView.register(PicturesCell.self, forCellWithReuseIdentifier: "PicturesCell")
	}
}

// MARK: - Configure Gesture
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func configureGesture() {

		let dubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(actionDoubleTap(_:)))
		dubleTapGesture.numberOfTapsRequired = 2

		let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(actionSingleTap(_:)))
		singleTapGesture.numberOfTapsRequired = 1
		singleTapGesture.require(toFail: dubleTapGesture)

		view.addGestureRecognizer(dubleTapGesture)
		view.addGestureRecognizer(singleTapGesture)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionSingleTap(_ recognizer: UITapGestureRecognizer) {

		UIView.animate(withDuration: 0.3) { [self] in
			navigationController?.navigationBar.alpha = (navigationController?.navigationBar.alpha == 0) ? 1 : 0
		}

		DispatchQueue.main.async(after: 0.3) {
			self.collectionView.layoutSubviews()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDoubleTap(_ recognizer: UITapGestureRecognizer) {

		if let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? PicturesCell {
			cell.actionDoubleTap(recognizer)
		}
	}
}

// MARK: - User Action
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionShare() {

		var items: [Any] = []

		let photoObject = photoObjects[currentIndex]

		if let data = photoObject.data() {
			items.append(data)
		} else {
			items.append(photoObject.image())
		}

		items.append(photoObject.title())
		items.append(photoObject.details())

		let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
		present(activity, animated: true)
	}
}

// MARK: - UICollectionViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return photoObjects.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PicturesCell", for: indexPath) as! PicturesCell

		let photoObject = photoObjects[indexPath.item]
		cell.bindData(photoObject, self)

		return cell
	}
}

// MARK: - UICollectionViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		print(#function)
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesView: UICollectionViewDelegateFlowLayout {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		return collectionView.frame.size
	}
}

// MARK: - UIScrollViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

		setCurrentIndex(from: scrollView)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

		setCurrentIndex(from: scrollView)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func setCurrentIndex(from scrollView: UIScrollView) {

		if (scrollView == collectionView) {
			let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
			let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
			if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
				currentIndex = visibleIndexPath.item
				updateTitle()
			}
		}
	}
}
