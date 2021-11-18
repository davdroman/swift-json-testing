import Foundation

public enum JSON: Hashable {
    case string(String)
    case number(Double)
    indirect case object([String: JSON])
    indirect case array([JSON])
    case bool(Bool)
    case null

    public init(_ json: JSON) {
        self = json
    }

    public init(data: Data) throws {
        self = try JSONSerialization.json(
            with: data,
            options: [.allowFragments]
        )
    }

    public init(raw rawJSON: String) throws {
        let data = Data(rawJSON.utf8)
        try self.init(data: data)
    }

    public var data: Data {
        Self.data(from: self, pretty: false)
    }

    public var raw: String {
        formatted(pretty: false)
    }
    
    public func formatted(pretty: Bool) -> String {
        let data = Self.data(from: self, pretty: pretty)
        guard let string = String(data: data, encoding: .utf8) else {
            preconditionFailure("Failed to convert Data into UTF-8 string: '\(data)'")
        }
        return string
    }

    private static func data(from json: JSON, pretty: Bool) -> Data {
        do {
            return try JSONSerialization.data(
                withJSON: json,
                options: [.fragmentsAllowed, .sortedKeys, .withoutEscapingSlashes, pretty ? .prettyPrinted : []]
            )
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
}
