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
extension UIImage {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init?(path: String) {

		if let data = Data(path: path) {
			self.init(data: data)
			return
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func image(_ path: String, size: CGFloat) -> UIImage? {

		let image = UIImage(path: path)

		return image?.square(to: size)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIImage {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func resize(width: Int, height: Int) -> UIImage {

		let size = CGSize(width: width, height: height)

		return resize(size: size)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func resize(width: CGFloat, height: CGFloat) -> UIImage {

		let size = CGSize(width: width, height: height)

		return resize(size: size)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func resize(size sizeNew: CGSize) -> UIImage {

		let sizeOld = size

		let ratioOld = sizeOld.width / sizeOld.height
		let ratioNew = sizeNew.width / sizeNew.height

		var resizeImage: UIImage

		if (ratioOld > ratioNew) {

			let width = sizeOld.height * ratioNew
			let x = (sizeOld.width - width) / 2
			resizeImage = crop(x: x, y: 0, width: width, height: sizeOld.height)

		} else if (ratioOld < ratioNew) {

			let height = sizeOld.width / ratioNew
			let y = (sizeOld.height - height) / 2
			resizeImage = crop(x: 0, y: y, width: sizeOld.width, height: height)

		} else {
			resizeImage = self
		}

		UIGraphicsBeginImageContextWithOptions(sizeNew, false, 0.0)
		resizeImage.draw(in: CGRect(x: 0, y: 0, width: sizeNew.width, height: sizeNew.height))
		let resized = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return resized ?? UIImage()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIImage {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func square(to extent: Int) -> UIImage {

		return resize(width: extent, height: extent)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func square(to extent: CGFloat) -> UIImage {

		return resize(width: extent, height: extent)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func square() -> UIImage {

		if (size.width > size.height) {
			let x = (size.width - size.height) / 2
			return crop(x: x, y: 0, width: size.height, height: size.height)
		}

		if (size.height > size.width) {
			let y = (size.height - size.width) / 2
			return crop(x: 0, y: y, width: size.width, height: size.width)
		}

		return self
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func crop(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {

		if let cgImage = cgImage {
			let rect = CGRect(x: x, y: y, width: width, height: height)
			if let cropped = cgImage.cropping(to: rect) {
				return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
			}
		}
		return UIImage()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIImage {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func rotateLeft() -> UIImage? {

		let new = CGSize(width: size.height, height: size.width)

		UIGraphicsBeginImageContextWithOptions(new, false, scale)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }

		context.translateBy(x: new.width/2, y: new.height/2)
		context.rotate(by: CGFloat(-0.5 * .pi))

		self.draw(in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}
}
