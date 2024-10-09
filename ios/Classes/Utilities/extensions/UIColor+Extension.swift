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
extension UIColor {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public convenience init(_ hex: String) {

		let hexString = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex

		guard let hexValue = UInt64(hexString, radix: 16) else {
			fatalError("Invalid hex string")
		}

		let (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat)

		switch hexString.count {
		case 6: // RRGGBB
			r = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
			g = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
			b = CGFloat(hexValue & 0x0000FF) / 255.0
			a = 1.0
		case 8: // RRGGBBAA
			r = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
			g = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
			b = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
			a = CGFloat(hexValue & 0x000000FF) / 255.0
		default:
			fatalError("Invalid hex string length")
		}

		self.init(red: r, green: g, blue: b, alpha: a)
	}
}
