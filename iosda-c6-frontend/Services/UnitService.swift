import Foundation

protocol UnitServiceProtocol {
    func fetchUnits() async throws -> [Unit]
    func createUnit(_ request: CreateUnitRequest) async throws -> Unit
    func deleteUnit(id: String) async throws
}

class UnitService: UnitServiceProtocol {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func fetchUnits() async throws -> [Unit] {
        let response: APIResponse<[Unit]> = try await networkManager.request(endpoint: "/units")

        guard response.success else {
            throw NetworkError.serverError(0)
        }

        guard let units = response.data else {
            throw NetworkError.decodingError
        }

        return units
    }

    func createUnit(_ request: CreateUnitRequest) async throws -> Unit {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let bodyData = try encoder.encode(request)

        let response: APIResponse<Unit> = try await networkManager.request(
            endpoint: "/units",
            method: .POST,
            body: bodyData
        )


        guard response.success else {
            throw NetworkError.serverError(0)
        }

        guard let unit = response.data else {
            throw NetworkError.decodingError
        }

        return unit
    }

    func deleteUnit(id: String) async throws {
           try await networkManager.requestEmpty(endpoint: "/units/\(id)", method: .DELETE)
       }
}
