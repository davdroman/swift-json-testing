import Foundation

extension JSON {
    public init<T: Encodable>(of encodable: T, encoder: JSONEncoder = XCTAssertJSON.configuration.encoder) throws {
        let data = try encoder.encode(encodable)
        try self.init(data: data)
    }

    public func `as`<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = XCTAssertJSON.configuration.decoder) throws -> T {
        try decoder.decode(type, from: data)
    }
}
