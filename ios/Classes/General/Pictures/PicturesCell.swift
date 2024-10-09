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
import Gifu

//-----------------------------------------------------------------------------------------------------------------------------------------------
class PicturesCell: UICollectionViewCell {

	private let shadowLayer = CAGradientLayer()
	private let viewDescription = UIView()
	private let stackView = UIStackView()
	private let labelTitle = UILabel()
	private let labelDetails = UILabel()

	private var scrollView = UIScrollView()
	private var constraintPhotoHeight: NSLayoutConstraint!
	private var constraintPhotoWidth: NSLayoutConstraint!

	private var imagePhoto = GIFImageView()

	private var photoObject: PhotoObject!
	private var picturesView: PicturesView!

	private var readyForDismiss = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init(frame: CGRect) {

		super.init(frame: frame)

		configureScrollView()
		configureImageView()
		configureStackView()
		configureViewDescription()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		fatalError()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func prepareForReuse() {

		readyForDismiss = false

		imagePhoto.prepareForReuse()

		scrollView.zoomScale = scrollView.minimumZoomScale
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		super.layoutSubviews()

		DispatchQueue.main.async {
			self.setImage()
		}

		shadowLayer.frame = viewDescription.bounds
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesCell {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(_ photoObject: PhotoObject, _ picturesView: PicturesView) {

		self.photoObject = photoObject
		self.picturesView = picturesView

		labelTitle.attributedText = photoObject.title()
		labelDetails.attributedText = photoObject.details()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesCell {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func configureScrollView() {

		scrollView.delegate = self
		scrollView.minimumZoomScale = 1.0
		scrollView.maximumZoomScale = 5.0
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.contentInsetAdjustmentBehavior = .never
		contentView.addSubview(scrollView)

		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func configureImageView() {

		imagePhoto.contentMode = .scaleAspectFit
		scrollView.addSubview(imagePhoto)

		imagePhoto.invalidateIntrinsicContentSize()
		imagePhoto.translatesAutoresizingMaskIntoConstraints = false
		imagePhoto.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		imagePhoto.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		imagePhoto.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
		imagePhoto.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

		constraintPhotoHeight = NSLayoutConstraint(item: imagePhoto, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
		constraintPhotoWidth = NSLayoutConstraint(item: imagePhoto, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)

		constraintPhotoHeight.isActive = true
		constraintPhotoWidth.isActive = true
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func configureStackView() {

		labelTitle.numberOfLines = 0
		labelDetails.numberOfLines = 0

		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.addArrangedSubview(labelTitle)
		stackView.addArrangedSubview(labelDetails)
		contentView.addSubview(stackView)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
		stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
		stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25).isActive = true
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func configureViewDescription() {

		contentView.addSubview(viewDescription)
		contentView.bringSubviewToFront(stackView)
		viewDescription.translatesAutoresizingMaskIntoConstraints = false
		viewDescription.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		viewDescription.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		viewDescription.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		viewDescription.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -10).isActive = true

		shadowLayer.frame = viewDescription.bounds
		shadowLayer.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(1).cgColor]
		viewDescription.layer.addSublayer(shadowLayer)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesCell {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func setImage() {

		let image = photoObject.image()
		if let data = photoObject.data() {
			imagePhoto.animate(withGIFData: data)
		}
		imagePhoto.image = image

		let widthImage = image.size.width
		let heightImage = image.size.height

		let widthScroll = scrollView.frame.size.width
		let heightScroll = scrollView.frame.size.height

		let heightImageView = widthScroll * heightImage / widthImage
		let widthImageView = heightScroll * widthImage / heightImage

		if (heightScroll > widthScroll) {
			constraintPhotoHeight.constant = heightImageView
			constraintPhotoWidth.constant = widthScroll
		} else {
			constraintPhotoHeight.constant = heightScroll
			constraintPhotoWidth.constant = widthImageView
		}

		let sizeScroll = scrollView.bounds.size

		var verticalPadding = heightImageView < sizeScroll.height ? (sizeScroll.height - heightImageView) / 2 : 0
		let horizontalPadding = widthImageView < sizeScroll.width ? (sizeScroll.width - widthImageView) / 2 : 0

		verticalPadding += 1

		if (verticalPadding >= 0) {
			scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
		} else {
			scrollView.contentSize = CGSize(width: widthImageView, height: heightImageView)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesCell {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDoubleTap(_ recognizer: UITapGestureRecognizer) {

		if (scrollView.zoomScale != scrollView.minimumZoomScale) {
			scrollView.zoom(to: zoomRectForScale(scale: scrollView.minimumZoomScale, center: recognizer.location(in: imagePhoto)), animated: true)
		} else {
			let scale = min(scrollView.zoomScale * 2.0, scrollView.maximumZoomScale)
			scrollView.zoom(to: zoomRectForScale(scale: scale, center: recognizer.location(in: imagePhoto)), animated: true)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {

		var zoomRect = CGRect.zero
		zoomRect.size.height = imagePhoto.frame.size.height / scale
		zoomRect.size.width = imagePhoto.frame.size.width / scale
		let newCenter = scrollView.convert(center, from: imagePhoto)
		zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
		zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
		return zoomRect
	}
}

// MARK: - UIScrollView Delegate Methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PicturesCell: UIScrollViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {

		return imagePhoto
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewDidZoom(_ scrollView: UIScrollView) {

		let sizeImage = imagePhoto.frame.size
		let sizeScroll = scrollView.bounds.size

		var verticalPadding = sizeImage.height < sizeScroll.height ? (sizeScroll.height - sizeImage.height) / 2 : 0
		let horizontalPadding = sizeImage.width < sizeScroll.width ? (sizeScroll.width - sizeImage.width) / 2 : 0

		verticalPadding += 1

		if (verticalPadding >= 0) {
			scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
		} else {
			scrollView.contentSize = sizeImage
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewDidScroll(_ scrollView: UIScrollView) {

		let sizeImage = imagePhoto.frame.size
		let sizeScroll = scrollView.bounds.size

		var verticalPadding = sizeImage.height < sizeScroll.height ? (sizeScroll.height - sizeImage.height) / 2 : 0

		verticalPadding += 1

		let offset = verticalPadding + scrollView.contentOffset.y

		if (abs(offset) < 15) {
			readyForDismiss = true
		}

		if (readyForDismiss) && (offset < -100) {
			picturesView.actionDismiss()
		}
	}
}
