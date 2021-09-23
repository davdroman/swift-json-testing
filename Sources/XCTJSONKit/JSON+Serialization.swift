import CoreFoundation
import Foundation

extension JSONSerialization {
    public enum Error: LocalizedError {
        case dataToJSONConversionError(Data)
        case jsonToDataConversionError(JSON)

        public var errorDescription: String? {
            switch self {
            case .dataToJSONConversionError(let data):
                return "Invalid data to JSON conversion: '\(data)'"
            case .jsonToDataConversionError(let json):
                return "Invalid JSON to data conversion: '\(json)'"
            }
        }
    }

    public class func json(
        with data: Data,
        options opt: JSONSerialization.ReadingOptions = []
    ) throws -> JSON {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: opt)
        guard let json = JSON(jsonObject) else {
            throw Error.dataToJSONConversionError(data)
        }
        return json
    }

    public class func data(
        withJSON json: JSON,
        options opt: JSONSerialization.WritingOptions = []
    ) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: json.jsonObject, options: opt)
        guard !data.isEmpty else {
            throw Error.jsonToDataConversionError(json)
        }
        return data
    }
}

extension JSON {
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
            self = .object(object.compactMapValues(JSON.init))
        case let array as [Any]:
            self = .array(array.compactMap(JSON.init))
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
