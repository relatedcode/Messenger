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
extension DispatchQueue {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func async(after delay: TimeInterval, _ execute: @escaping () -> Void) {

		asyncAfter(deadline: .now() + delay, execute: execute)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func async(after delay: TimeInterval, _ execute: DispatchWorkItem?) {

		if let execute = execute {
			asyncAfter(deadline: .now() + delay, execute: execute)
		}
	}
}
