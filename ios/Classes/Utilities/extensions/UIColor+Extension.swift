//
// Copyright (c) 2023 Related Code - https://relatedcode.com
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
	public convenience init?(_ hex: String) {

		var hexstr = hex
		var hexnum = UInt64(0)

		if hex.hasPrefix("#") {
			hexstr = String(hex.dropFirst())
		}

		let scanner = Scanner(string: hexstr)

		if (scanner.scanHexInt64(&hexnum)) {
			if (hexstr.count == 6) {
				let r = CGFloat((hexnum & 0xff0000) >> 16) / 255
				let g = CGFloat((hexnum & 0x00ff00) >> 8) / 255
				let b = CGFloat((hexnum & 0x0000ff) >> 0) / 255
				self.init(red: r, green: g, blue: b, alpha: 1.0)
				return
			}
			if (hexstr.count == 8) {
				let r = CGFloat((hexnum & 0xff000000) >> 24) / 255
				let g = CGFloat((hexnum & 0x00ff0000) >> 16) / 255
				let b = CGFloat((hexnum & 0x0000ff00) >> 8) / 255
				let a = CGFloat((hexnum & 0x000000ff) >> 0) / 255
				self.init(red: r, green: g, blue: b, alpha: a)
				return
			}
		}

		return nil
	}
}
