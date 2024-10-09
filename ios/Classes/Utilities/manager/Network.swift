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
class Network {

	static let All		= 0
	static let WiFi		= 1
	static let Manual	= 2

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func photo() -> Int { return UserDefaults.integer(key: "NetworkPhoto") }
	class func video() -> Int { return UserDefaults.integer(key: "NetworkVideo") }
	class func audio() -> Int { return UserDefaults.integer(key: "NetworkAudio") }

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func photo(_ value: Int) { UserDefaults.setObject(value, key: "NetworkPhoto") }
	class func video(_ value: Int) { UserDefaults.setObject(value, key: "NetworkVideo") }
	class func audio(_ value: Int) { UserDefaults.setObject(value, key: "NetworkAudio") }
}
