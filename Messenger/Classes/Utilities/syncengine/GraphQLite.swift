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
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
var gqldb: GQLDatabase!
var gqlserver: GQLServer!
var gqlsync: GQLSync!
var gqlstorage: GQLStorage!

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GraphQLite: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GraphQLite = {
		let instance = GraphQLite()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		initAuth()
		initDatabase()
		initServer()
		initStorage()
		initPush()

		GQLNetwork.setup()
		ChatObserver.setup()
		DataObservers.setup()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GraphQLite {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initAuth() {

		let domain = "relatedcode.us.auth0.com"
		let clientId = "iXagTRt5E6ktOKJsRudIbFyau5LvWggW"
		let clientSecret = "TR0yU0V8vr-htFDpuR5HsrYYKgfzkcXh__Rn8X261tbAH22x7zu7bvh1HdnTqQQl"
		GQLAuth.setup(domain, clientId, clientSecret)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initDatabase() {

		gqldb = GQLDatabase()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initServer() {

		let key = "da2-xawfk6wda5eldn6l3ddswajcyu"
		let link = "https://s2n6e4bbwbflpgdxzutrsrlj5i.appsync-api.us-east-2.amazonaws.com/graphql"
		gqlserver = GQLServer(AppSync: link, key: key)

		gqlsync = GQLSync(gqlserver)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initStorage() {

		let secretKey = "AKIA3DPPRMO2I2ZDI2IS"
		let accessKey = "aXBBbI0LMAcpUstvjoG6HQk49TIEOxXNDV+mQU6S"
		gqlstorage = GQLStorage(AmazonS3: "us-east-2", secretKey, accessKey)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initPush() {

		let appId = "277d0aab-5925-475f-ba99-4af140776900"
		let keyAPI = "MWQxZGZmNzMtMTc0ZS00N2U5LWEyNjgtYTdlNzYzNTk4NTM5"
		GQLPush.setup(appId, keyAPI)
	}
}
