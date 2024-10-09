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
class PhotoObject {

	private var idX: String = ""

	private var dataX: Data?
	private var imageX: UIImage!

	private var titleX: String = ""
	private var detailsX: String = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ id: String, _ data: Data, _ title: String = "", _ details: String = "") {

		idX = id
		dataX = data
		imageX = UIImage(data: data)
		titleX = title
		detailsX = details
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ id: String, _ image: UIImage, _ title: String = "", _ details: String = "") {

		idX = id
		dataX = nil
		imageX = image
		titleX = title
		detailsX = details
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PhotoObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func id() -> String {

		return idX
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PhotoObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func data() -> Data? {

		return dataX
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func image() -> UIImage {

		return imageX
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PhotoObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func title() -> NSAttributedString {

		let font = UIFont.systemFont(ofSize: 20)
		let color = UIColor.white
		let style = NSMutableParagraphStyle()
		style.alignment = .left

		return NSAttributedString(string: titleX, attributes: [.font: font, .foregroundColor: color, .paragraphStyle: style])
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func details() -> NSAttributedString {

		let font = UIFont.systemFont(ofSize: 15)
		let color = UIColor.lightGray
		let style = NSMutableParagraphStyle()
		style.alignment = .left

		return NSAttributedString(string: detailsX, attributes: [.font: font, .foregroundColor: color, .paragraphStyle: style])
	}
}
