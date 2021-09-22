import CoreFoundation
import CustomDump
import Foundation

public enum JSONTree: Hashable {
    case string(String)
    case number(Double)
    indirect case object([String: JSONTree])
    indirect case array([JSONTree])
    case bool(Bool)
    case null
}

extension JSONTree: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSONTree: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(Double(value))
    }
}

extension JSONTree: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}

extension JSONTree: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONTree)...) {
        self = .object(Dictionary(elements, uniquingKeysWith: { current, new in new }))
    }
}

extension JSONTree: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONTree...) {
        self = .array(elements)
    }
}

extension JSONTree: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension JSONTree: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSONTree: CustomDebugStringConvertible {
    public var debugDescription: String {
        do {
            let data = try JSONSerialization.data(
                withJSONObject: self.jsonObject,
                options: [.fragmentsAllowed, .sortedKeys, .withoutEscapingSlashes, .prettyPrinted]
            )
            guard let description = String(data: data, encoding: .utf8) else {
                throw JSON.Error.failedDataToUT8StringConversion(data)
            }
            return description
        } catch {
            print("Failed to compute debug description for JSONTree. Error: \(error)")
        }
        return "<JSONTree: no description>"
    }
}

extension JSONTree: CustomDumpRepresentable {
    public var customDumpValue: Any {
        jsonObject
    }
}

extension JSONSerialization {
    public enum Error: LocalizedError {
        case dataToJSONTreeConversionError(Data)
        case jsonTreeToDataConversionError(JSONTree)

        public var errorDescription: String? {
            switch self {
            case .dataToJSONTreeConversionError(let data):
                return "Invalid data to JSON tree conversion: '\(data)'"
            case .jsonTreeToDataConversionError(let tree):
                return "Invalid JSON tree to data conversion: '\(tree)'"
            }
        }
    }

    public class func jsonTree(
        with data: Data,
        options opt: JSONSerialization.ReadingOptions = []
    ) throws -> JSONTree {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: opt)
        guard let tree = JSONTree(jsonObject) else {
            throw Error.dataToJSONTreeConversionError(data)
        }
        return tree
    }

    public class func data(
        withJSONTree tree: JSONTree,
        options opt: JSONSerialization.WritingOptions = []
    ) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: tree.jsonObject, options: opt)
        guard !data.isEmpty else {
            throw Error.jsonTreeToDataConversionError(tree)
        }
        return data
    }
}

private extension JSONTree {
    init?(_ jsonObject: Any) {
        switch jsonObject {
        case let string as String:
            self = .string(string)
        case let nsNumber as NSNumber:
            if nsNumber.isBoolValue {
                self = .bool(nsNumber.boolValue)
            } else {
                self = .number(nsNumber.doubleValue)
            }
        case let object as [String: Any]:
            self = .object(object.compactMapValues(JSONTree.init))
        case let array as [Any]:
            self = .array(array.compactMap(JSONTree.init))
        case _ as NSNull:
            self = .null
        default:
            return nil
        }
    }

    var jsonObject: Any {
        switch self {
        case .string(let string):
            return string
        case .number(let number):
            return number
        case .object(let object):
            return object.mapValues(\.jsonObject)
        case .array(let array):
            return array.map(\.jsonObject)
        case .bool(let bool):
            return bool
        case .null:
            return NSNull()
        }
    }
}

private extension NSNumber {
    var isBoolValue: Bool {
        let boolID = CFBooleanGetTypeID() // the type ID of CFBoolean
        let numID = CFGetTypeID(self) // the type ID of num
        return numID == boolID
    }
}
