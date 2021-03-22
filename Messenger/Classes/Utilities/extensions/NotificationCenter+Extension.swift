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

import Foundation

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension NotificationCenter {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func addObserver(target: Any, selector: Selector, name: String) {

		NotificationCenter.default.addObserver(target, selector: selector, name: NSNotification.Name(name), object: nil)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func removeObserver(target: Any) {

		NotificationCenter.default.removeObserver(target)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func post(notification: String) {

		NotificationCenter.default.post(name: NSNotification.Name(notification), object: nil)
	}
}
