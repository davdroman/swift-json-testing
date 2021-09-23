import Foundation

extension JSON {
    public init<T: Encodable>(of encodable: T, encoder: JSONEncoder = JSONEncoder()) throws {
        let data = try encoder.encode(encodable)
        try self.init(data: data)
    }

    public func `as`<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(type, from: data)
    }
}
