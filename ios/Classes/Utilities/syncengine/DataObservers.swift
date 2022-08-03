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

import UIKit
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class DataObservers: NSObject {

	private var callbackIdWorkspace:	String?
	private var callbackIdUser:			String?
	private var callbackIdChannel:		String?
	private var callbackIdDirect:		String?
	private var callbackIdDetail:		String?
	private var callbackIdMessage:		String?
	private var callbackIdPresence:		String?

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
		NotificationCenter.addObserver(self, selector: #selector(disconnect), text: Notifications.UserWillLogout)

		NotificationCenter.addObserver(self, selector: #selector(networkChanged), text: "GQLNetworkChanged")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func networkChanged() {

		GQLNetwork.isReachable() ? connect() : disconnect()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func connect() {

		if (GQLAuth.userId() != "") {
			if (GQLNetwork.isReachable()) {
				gqlserver.connectAuth() { error in
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

		subscribeWorkspace()
		subscribeUser()
		subscribeChannel()
		subscribeDirect()
		subscribeDetail()
		subscribeMessage()
		subscribePresence()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func stopObservers() {

		unsubscribeWorkspace()
		unsubscribeUser()
		unsubscribeChannel()
		unsubscribeDirect()
		unsubscribeDetail()
		unsubscribeMessage()
		unsubscribePresence()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func fetch(_ queryName: String, _ variables: [String: Any], _ table: String, completion: @escaping () -> Void) {

		let query = GQLQuery[queryName]

		gqlserver.sendAuth(query, variables) { result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let array = result.values.first as? [[String: Any]] {
					print("\(table) fetch: \(array.count)")
					LastUpdated.update(table, array)
					gqldb.updateInsert(table, array, true) {
						DispatchQueue.main.async {
							completion()
						}
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribe(_ queryName: String, _ table: String) -> String? {

		let query = GQLQuery[queryName]

		let callbackId = gqlserver.subscription(query, [:]) { result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				print("\(table) subscribe: \(result.values.count)")
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

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeWorkspace() {

		let table = "DBWorkspace"

		if (callbackIdWorkspace == nil) {
			let updatedAt = LastUpdated[table]
			let variables = ["updatedAt": updatedAt]
			fetch("ListWorkspaces", variables, table) { [self] in
				callbackIdWorkspace = subscribe("OnUpdateWorkspace", table)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeWorkspace() {

		unsubscribe(callbackIdWorkspace)
		callbackIdWorkspace = nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeUser() {

		let table = "DBUser"

		if (callbackIdUser == nil) {
			let updatedAt = LastUpdated[table]
			let variables = ["updatedAt": updatedAt]
			fetch("ListUsers", variables, table) { [self] in
				callbackIdUser = subscribe("OnUpdateUser", table)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeUser() {

		unsubscribe(callbackIdUser)
		callbackIdUser = nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeChannel() {

		let table = "DBChannel"

		if (callbackIdChannel == nil) {
			let updatedAt = LastUpdated[table]
			let variables = ["updatedAt": updatedAt]
			fetch("ListChannels", variables, table) { [self] in
				callbackIdChannel = subscribe("OnUpdateChannel", table)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeChannel() {

		unsubscribe(callbackIdChannel)
		callbackIdChannel = nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeDirect() {

		let table = "DBDirect"

		if (callbackIdDirect == nil) {
			let updatedAt = LastUpdated[table]
			let variables = ["updatedAt": updatedAt]
			fetch("ListDirects", variables, table) { [self] in
				callbackIdDirect = subscribe("OnUpdateDirect", table)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeDirect() {

		unsubscribe(callbackIdDirect)
		callbackIdDirect = nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeDetail() {

		let table = "DBDetail"

		if (callbackIdDetail == nil) {
			let updatedAt = LastUpdated[table]
			let variables = ["updatedAt": updatedAt]
			fetch("ListDetails", variables, table) { [self] in
				callbackIdDetail = subscribe("OnUpdateDetail", table)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeDetail() {

		unsubscribe(callbackIdDetail)
		callbackIdDetail = nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribeMessage() {

		let table = "DBMessage"

		if (callbackIdMessage == nil) {
			let updatedAt = LastUpdated[table]
			var variables: [String: Any] = [:]
			variables["limit"] = 10000
			variables["updatedAt"] = updatedAt
			fetch("ListMessages", variables, table) { [self] in
				callbackIdMessage = subscribe("OnUpdateMessage", table)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribeMessage() {

		unsubscribe(callbackIdMessage)
		callbackIdMessage = nil
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension DataObservers {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribePresence() {

		let table = "DBPresence"

		if (callbackIdPresence == nil) {
			let updatedAt = LastUpdated[table]
			let variables = ["updatedAt": updatedAt]
			fetch("ListPresences", variables, table) { [self] in
				callbackIdPresence = subscribe("OnUpdatePresence", table)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribePresence() {

		unsubscribe(callbackIdPresence)
		callbackIdPresence = nil
	}
}
