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

import UIKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension UIImage {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init?(path: String) {

		if let dataEncrypted = Data(path: path) {
			if let dataDecrypted = Cryptor.decrypt(data: dataEncrypted) {
				self.init(data: dataDecrypted)
				return
			}
		}

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func image(_ path: String, size: CGFloat) -> UIImage? {

		let image = UIImage(path: path)
		return image?.square(to: size)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func square(to extent: CGFloat) -> UIImage {

		var cropped: UIImage!

		let width = self.size.width
		let height = self.size.height

		if (width == height) {
			cropped = self
		} else if (width > height) {
			let xpos = (width - height) / 2
			cropped = self.crop(x: xpos, y: 0, width: height, height: height)
		} else if (height > width) {
			let ypos = (height - width) / 2
			cropped = self.crop(x: 0, y: ypos, width: width, height: width)
		}

		return cropped.resize(width: extent, height: extent)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func resize(width: CGFloat, height: CGFloat) -> UIImage {

		let size = CGSize(width: width, height: height)
		let rect = CGRect(x: 0, y: 0, width: width, height: height)

		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		self.draw(in: rect)
		let resized = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return resized!
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func crop(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {

		let rect = CGRect(x: x, y: y, width: width, height: height)

		if let cgImage = self.cgImage {
			if let cropped = cgImage.cropping(to: rect) {
				return UIImage(cgImage: cropped, scale: self.scale, orientation: self.imageOrientation)
			}
		}

		return UIImage()
	}
}
