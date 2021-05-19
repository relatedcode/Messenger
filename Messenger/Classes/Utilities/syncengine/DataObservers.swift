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

import UIKit
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class DataObservers: NSObject {

	private var callbackIdUser:		String?
	private var callbackIdRelation:	String?
	private var callbackIdMember:	String?
	private var callbackIdSingle:	String?
	private var callbackIdGroup:	String?
	private var callbackIdDetail:	String?
	private var callbackIdMessage:	String?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: DataObservers = {
		let instance = DataObservers()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenter.addObserver(self, selector: #selector(connect), text: Notifications.AppStarted)
		NotificationCenter.addObserver(self, selector: #selector(disconnect), text: Notifications.AppWillResign)

		NotificationCenter.addObserver(self, selector: #selector(connect), text: Notifications.UserLoggedIn)
		NotificationCenter.addObserver(self, selector: #selector(disconnect), text: Notifications.UserLoggedOut)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func networkChanged() {

		GQLNetwork.isReachable() ? connect() : disconnect()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func connect() {

		if (GQLAuth.userId() != "") {
			if (GQLNetwork.isReachable()) {
				gqlserver.connect() { error in
					if let error = error {
						print(error.localizedDescription)
					} else {
						self.initObservers()
					}
				}
			}
		}

		NotificationCenter.addObserver(self, selector: #selector(networkChanged), text: "GQLNetworkChanged")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func disconnect() {

		stopObservers()
		DispatchQueue.main.async(after: 0.25) {
			gqlserver.disconnect()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func initObservers() {

		subscribeUser()
		subscribeRelation()
		subscribeMember()

		subscribeSingle() { [self] in
			subscribeGroup() { [self] in
				subscribeDetail() { [self] in
					subscribeMessage()
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func stopObservers() {

		unsubscribeUser()
		unsubscribeRelation()
		unsubscribeMember()
		unsubscribeSingle()
		unsubscribeGroup()
		unsubscribeDetail()
		unsubscribeMessage()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func fetch(_ queryName: String, _ variables: [String: Any], _ table: String, completion: @escaping () -> Void) {

		let query = GQLQuery[queryName]

		gqlserver.query(query, variables) { result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let dictionary = result.values.first as? [String: Any] {
					if let array = dictionary["items"] as? [[String: Any]] {
						for values in array {
							self.updateDatabase(table, values)
						}
					}
				}
			}
			completion()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribe(_ queryName: String, _ table: String) -> String {

		let query = GQLQuery[queryName]

		let callbackId = gqlserver.subscription(query, [:]) { result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let values = result.values.first as? [String: Any] {
					self.updateDatabase(table, values)
				}
			}
		}
		return callbackId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribe(_ callbackId: String?) {

		if let callbackId = callbackId {
			gqlserver.subscription(cancel: callbackId) { error in
				if let error = error {
					print(error.localizedDescription)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateDatabase(_ table: String, _ values: [String: Any]) {

		gqldb.updateInsert(table, values)
		LastUpdated.update(table, values)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	// MARK: - User
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeUser() {

		if (callbackIdUser == nil) {
			let updatedAt = LastUpdated["DBUser"]
			let variables = ["updatedAt": updatedAt]
			fetch("DBUserQuery", variables, "DBUser") { [self] in
				callbackIdUser = subscribe("DBUserSubscription", "DBUser")
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeUser() {

		unsubscribe(callbackIdUser)
		callbackIdUser = nil
	}

	// MARK: - Relation
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeRelation() {

		if (callbackIdRelation == nil) {
			let updatedAt = LastUpdated["DBRelation"]
			let variables = ["updatedAt": updatedAt]
			fetch("DBRelationQuery", variables, "DBRelation") { [self] in
				callbackIdRelation = subscribe("DBRelationSubscription", "DBRelation")
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeRelation() {

		unsubscribe(callbackIdRelation)
		callbackIdRelation = nil
	}

	// MARK: - Member
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeMember() {

		if (callbackIdMember == nil) {
			let updatedAt = LastUpdated["DBMember"]
			let variables = ["updatedAt": updatedAt]
			fetch("DBMemberQuery", variables, "DBMember") { [self] in
				callbackIdMember = subscribe("DBMemberSubscription", "DBMember")
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeMember() {

		unsubscribe(callbackIdMember)
		callbackIdMember = nil
	}

	// MARK: - Single
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeSingle(completion: @escaping () -> Void) {

		if (callbackIdSingle == nil) {
			let updatedAt = LastUpdated["DBSingle"]
			let variables = ["updatedAt": updatedAt]
			fetch("DBSingleQuery", variables, "DBSingle") { [self] in
				callbackIdSingle = subscribe("DBSingleSubscription", "DBSingle")
				completion()
			}
		} else {
			completion()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeSingle() {

		unsubscribe(callbackIdSingle)
		callbackIdSingle = nil
	}

	// MARK: - Group
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeGroup(completion: @escaping () -> Void) {

		if (callbackIdGroup == nil) {
			let updatedAt = LastUpdated["DBGroup"]
			let variables = ["updatedAt": updatedAt]
			fetch("DBGroupQuery", variables, "DBGroup") { [self] in
				callbackIdGroup = subscribe("DBGroupSubscription", "DBGroup")
				completion()
			}
		} else {
			completion()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeGroup() {

		unsubscribe(callbackIdGroup)
		callbackIdGroup = nil
	}

	// MARK: - Detail
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeDetail(completion: @escaping () -> Void) {

		if (callbackIdDetail == nil) {
			let updatedAt = LastUpdated["DBDetail"]
			let variables = ["updatedAt": updatedAt]
			fetch("DBDetailQuery", variables, "DBDetail") { [self] in
				callbackIdDetail = subscribe("DBDetailSubscription", "DBDetail")
				completion()
			}
		} else {
			completion()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeDetail() {

		unsubscribe(callbackIdDetail)
		callbackIdDetail = nil
	}

	// MARK: - Message
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeMessage() {

		if (callbackIdMessage == nil) {
			let updatedAt = LastUpdated["DBMessage"]
			let variables = ["updatedAt": updatedAt]
			fetch("DBMessageQuery", variables, "DBMessage") { [self] in
				callbackIdMessage = subscribe("DBMessageSubscription", "DBMessage")
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeMessage() {

		unsubscribe(callbackIdMessage)
		callbackIdMessage = nil
	}
}
