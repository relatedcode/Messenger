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

	private var observerIdUser:		String?
	private var observerIdRelation:	String?
	private var observerIdMember:	String?
	private var observerIdSingle:	String?
	private var observerIdGroup:	String?
	private var observerIdDetail:	String?
	private var observerIdMessage:	String?

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

		NotificationCenter.addObserver(target: self, selector: #selector(connect), name: UIApplication.didBecomeActiveNotification.rawValue)
		NotificationCenter.addObserver(target: self, selector: #selector(disconnect), name: UIApplication.willResignActiveNotification.rawValue)

		NotificationCenter.addObserver(target: self, selector: #selector(connect), name: Notifications.UserLoggedIn)
		NotificationCenter.addObserver(target: self, selector: #selector(disconnect), name: Notifications.UserLoggedOut)

		NotificationCenter.addObserver(target: self, selector: #selector(networkChanged), name: "GQLNetworkChanged")
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

		if (observerIdUser == nil)		{ createObserverUser()		}
		if (observerIdRelation == nil)	{ createObserverRelation()	}
		if (observerIdMember == nil)	{ createObserverMember()	}
		if (observerIdSingle == nil)	{ createObserverSingle()	}
		if (observerIdGroup == nil)		{ createObserverGroup()		}
		if (observerIdDetail == nil)	{ createObserverDetail()	}
		if (observerIdMessage == nil)	{ createObserverMessage()	}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func stopObservers() {

		if (observerIdUser != nil)		{ removeObserverUser()		}
		if (observerIdRelation != nil)	{ removeObserverRelation()	}
		if (observerIdMember != nil)	{ removeObserverMember()	}
		if (observerIdSingle != nil)	{ removeObserverSingle()	}
		if (observerIdGroup != nil)		{ removeObserverGroup()		}
		if (observerIdDetail != nil)	{ removeObserverDetail()	}
		if (observerIdMessage != nil)	{ removeObserverMessage()	}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func fetch(_ query: String, _ variables: [String: Any], _ table: String) {

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
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribe(_ query: String, _ variables: [String: Any], _ table: String) -> String {

		let callbackId = gqlserver.subscription(query, variables) { result, error in
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

		if let updatedAt = values["updatedAt"] as? String {
			LastUpdated.update(table, updatedAt)
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	// MARK: - User
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverUser() {

		let table = "DBUser"

		let query = GQLQuery["DBUserQuery"]
		let updatedAt = LastUpdated[table]
		let variables = ["updatedAt": updatedAt]

		fetch(query, variables, table)

		let subscription = GQLQuery["DBUserSubscription"]
		observerIdUser = subscribe(subscription, [:], table)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverUser() {

		unsubscribe(observerIdUser)
		observerIdUser = nil
	}

	// MARK: - Relation
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverRelation() {

		let table = "DBRelation"

		let query = GQLQuery["DBRelationQuery"]
		let updatedAt = LastUpdated[table]
		let variables = ["updatedAt": updatedAt]

		fetch(query, variables, table)

		let subscription = GQLQuery["DBRelationSubscription"]
		observerIdRelation = subscribe(subscription, [:], table)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverRelation() {

		unsubscribe(observerIdRelation)
		observerIdRelation = nil
	}

	// MARK: - Member
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverMember() {

		let table = "DBMember"

		let query = GQLQuery["DBMemberQuery"]
		let updatedAt = LastUpdated[table]
		let variables = ["updatedAt": updatedAt]

		fetch(query, variables, table)

		let subscription = GQLQuery["DBMemberSubscription"]
		observerIdMember = subscribe(subscription, [:], table)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverMember() {

		unsubscribe(observerIdMember)
		observerIdMember = nil
	}

	// MARK: - Single
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverSingle() {

		let table = "DBSingle"

		let query = GQLQuery["DBSingleQuery"]
		let updatedAt = LastUpdated[table]
		let variables = ["updatedAt": updatedAt]

		fetch(query, variables, table)

		let subscription = GQLQuery["DBSingleSubscription"]
		observerIdSingle = subscribe(subscription, [:], table)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverSingle() {

		unsubscribe(observerIdSingle)
		observerIdSingle = nil
	}

	// MARK: - Group
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverGroup() {

		let table = "DBGroup"

		let query = GQLQuery["DBGroupQuery"]
		let updatedAt = LastUpdated[table]
		let variables = ["updatedAt": updatedAt]

		fetch(query, variables, table)

		let subscription = GQLQuery["DBGroupSubscription"]
		observerIdGroup = subscribe(subscription, [:], table)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverGroup() {

		unsubscribe(observerIdGroup)
		observerIdGroup = nil
	}

	// MARK: - Detail
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverDetail() {

		let table = "DBDetail"

		let query = GQLQuery["DBDetailQuery"]
		let updatedAt = LastUpdated[table]
		let variables = ["updatedAt": updatedAt]

		fetch(query, variables, table)

		let subscription = GQLQuery["DBDetailSubscription"]
		observerIdDetail = subscribe(subscription, [:], table)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverDetail() {

		unsubscribe(observerIdDetail)
		observerIdDetail = nil
	}

	// MARK: - Message
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverMessage() {

		let table = "DBMessage"

		let query = GQLQuery["DBMessageQuery"]
		let updatedAt = LastUpdated[table]
		let variables = ["updatedAt": updatedAt]

		fetch(query, variables, table)

		let subscription = GQLQuery["DBMessageSubscription"]
		observerIdMessage = subscribe(subscription, [:], table)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverMessage() {

		unsubscribe(observerIdMessage)
		observerIdMessage = nil
	}
}
