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

import Foundation

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension Array where Element: Hashable {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	mutating func appendUnique(_ element: Element) {

		if !self.contains(element) {
			self.append(element)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	mutating func remove(_ element: Element) {

		while let index = self.firstIndex(of: element) {
			self.remove(at: index)
		}
	}
}
