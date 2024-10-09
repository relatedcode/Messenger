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
class KeepMedia {

	static let Forever	= 0
	static let Month	= 1
	static let Week		= 2
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension KeepMedia {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func isForever() -> Bool	{ return (value() == Forever)	}
	class func isMonth() -> Bool	{ return (value() == Month)		}
	class func isWeek() -> Bool		{ return (value() == Week)		}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension KeepMedia {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setForever()	{ value(Forever)	}
	class func setMonth()	{ value(Month)		}
	class func setWeek()	{ value(Week)		}

}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension KeepMedia {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func value() -> Int {

		return UserDefaults.integer(key: "KeepMedia")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func value(_ value: Int) {

		UserDefaults.setObject(value, key: "KeepMedia")
	}
}
