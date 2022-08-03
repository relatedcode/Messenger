//
// Copyright (c) 2022 Related Code - https://relatedcode.com
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
extension Character {

	var isEmoji: Bool {
		guard let scalar = unicodeScalars.first else { return false }
		return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func containsEmojiOnly() -> Bool {

		for character in self {
			if !character.isEmoji {
				return false
			}
		}
		return (count != 0)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func containsEmoji() -> Bool {

		for character in self {
			if character.isEmoji {
				return true
			}
		}
		return false
	}
}
