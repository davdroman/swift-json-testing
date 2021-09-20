import CustomDump
import Foundation

public struct JSON: Equatable {
    public enum Error: LocalizedError {
        case failedDataToUT8StringConversion(Data)
        case invalidData(Data)
        case invalidRawJSON(String)

        public var errorDescription: String? {
            switch self {
            case .failedDataToUT8StringConversion(let data):
                return "Failed to convert Data into UTF-8 string: '\(data)'"
            case .invalidData(let data):
                return "Invalid data to JSON value serialization: '\(data)'"
            case .invalidRawJSON(let rawJSON):
                return "Invalid raw JSON value serialization: '\(rawJSON)'"
            }
        }
    }

    public let jsonObject: AnyHashable
    public let data: Data
    public let raw: String

    public init<T>(_ jsonObject: T) throws where T: Hashable {
        let data = try Self.dataFromJSONObject(jsonObject)
        let jsonObject = try Self.jsonObjectFromData(data)
        guard let raw = String(data: data, encoding: .utf8) else {
            throw Error.failedDataToUT8StringConversion(data)
        }
        self.jsonObject = jsonObject
        self.data = data
        self.raw = raw
    }

    public init(_ data: Data) throws {
        try self.init(Self.jsonObjectFromData(data))
    }

    public init(raw rawJSON: String) throws {
        guard let data = rawJSON.data(using: .utf8) else {
            throw Error.invalidRawJSON(rawJSON)
        }
        try self.init(data)
    }

    private static func dataFromJSONObject(_ jsonObject: AnyHashable) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: jsonObject,
            options: [.fragmentsAllowed, .sortedKeys, .withoutEscapingSlashes]
        )
    }

    private static func jsonObjectFromData(_ data: Data) throws -> AnyHashable {
        guard let jsonObject = try JSONSerialization.jsonObject(
            with: data,
            options: [.allowFragments]
        ) as? AnyHashable else {
            throw Error.invalidData(data)
        }
        return jsonObject
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

extension JSON {
    public static var null: JSON {
        get throws {
            try JSON(NSNull())
        }
    }
}
