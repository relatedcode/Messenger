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

import NYTPhotoViewer

//-----------------------------------------------------------------------------------------------------------------------------------------------
class NYTPhotoSource: NSObject, NYTPhotoViewerDataSource {

	var photoItems: [NYTPhoto] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(photoItems: [NYTPhoto]) {

		self.init()
		self.photoItems = photoItems
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	var numberOfPhotos: NSNumber? {

		return NSNumber(value: photoItems.count)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func index(of photo: NYTPhoto) -> Int {

		if let photoItem = photo as? NYTPhotoItem {
			if let index = photoItems.firstIndex(where: { $0.image == photoItem.image }) {
				return index
			}
		}
		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func photo(at index: Int) -> NYTPhoto? {

		if (photoItems.count > index) {
			return photoItems[index]
		}
		return nil
	}
}
