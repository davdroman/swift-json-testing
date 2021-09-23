import CustomDump
import Foundation

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        formatted(pretty: true)
    }
}

extension JSON: CustomDumpRepresentable {
    public var customDumpValue: Any {
        jsonObject
    }
}
