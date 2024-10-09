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
extension NotificationCenter {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func addObserver(_ target: Any, selector: Selector, name: NSNotification.Name) {

		NotificationCenter.default.addObserver(target, selector: selector, name: name, object: nil)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func addObserver(_ target: Any, selector: Selector, text: String) {

		NotificationCenter.default.addObserver(target, selector: selector, name: NSNotification.Name(text), object: nil)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func removeObserver(_ target: Any) {

		NotificationCenter.default.removeObserver(target)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func post(_ text: String) {

		NotificationCenter.default.post(name: NSNotification.Name(text), object: nil)
	}
}
