import CustomDump
import Foundation

public struct JSON: Equatable {
    public enum Error: LocalizedError {
        case failedDataToUT8StringConversion(Data)
        case failedUT8StringToDataConversion(String)

        public var errorDescription: String? {
            switch self {
            case .failedDataToUT8StringConversion(let data):
                return "Failed to convert Data into UTF-8 string: '\(data)'"
            case .failedUT8StringToDataConversion(let string):
                return "Failed to convert UTF-8 string into Data: '\(string)'"
            }
        }
    }

    public let tree: JSONTree
    public let data: Data
    public let raw: String

    public init(_ jsonTree: JSONTree) throws {
        let data = try Self.data(from: jsonTree)
        let tree = try Self.jsonTree(from: data)
        guard let raw = String(data: data, encoding: .utf8) else {
            throw Error.failedDataToUT8StringConversion(data)
        }
        self.tree = tree
        self.data = data
        self.raw = raw
    }

    public init(_ data: Data) throws {
        try self.init(Self.jsonTree(from: data))
    }

    public init(raw rawJSON: String) throws {
        guard let data = rawJSON.data(using: .utf8) else {
            throw Error.failedUT8StringToDataConversion(rawJSON)
        }
        try self.init(data)
    }

    private static func data(from jsonTree: JSONTree) throws -> Data {
        try JSONSerialization.data(
            withJSONTree: jsonTree,
            options: [.fragmentsAllowed, .sortedKeys, .withoutEscapingSlashes]
        )
    }

    private static func jsonTree(from data: Data) throws -> JSONTree {
        try JSONSerialization.jsonTree(
            with: data,
            options: [.fragmentsAllowed]
        )
    }
}

extension JSON {
    public init<T: Encodable>(of encodable: T, encoder: JSONEncoder = JSONEncoder()) throws {
        let data = try encoder.encode(encodable)
        try self.init(data)
    }

    public func `as`<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(type, from: data)
    }
}
