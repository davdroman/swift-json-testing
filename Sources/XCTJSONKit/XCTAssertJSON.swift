import CustomDump
import XCTest

public func XCTAssertJSONCoding<T>(
    _ codable: @autoclosure () throws -> T,
    _ encoder: JSONEncoder = JSONEncoder(),
    _ decoder: JSONDecoder = JSONDecoder(),
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) rethrows where T: Codable, T: Equatable {
    let codable = try codable()
    XCTAssertNoDifference(
        try decoder.decode(T.self, from: encoder.encode(codable)),
        codable,
        message(),
        file: file,
        line: line
    )
}

public func XCTAssertJSONCoding<T>(
    _ codableEnum: T.Type,
    _ encoder: JSONEncoder = JSONEncoder(),
    _ decoder: JSONDecoder = JSONDecoder(),
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) where T: Codable, T: Equatable, T: CaseIterable {
    let allCases = codableEnum.allCases
    for `case` in allCases {
        XCTAssertJSONCoding(`case`, encoder, decoder, message(), file: file, line: line)
    }
}

public func XCTAssertJSONEncoding<T>(
    _ encodable: @autoclosure () throws -> T,
    _ json: @autoclosure () throws -> JSON,
    _ encoder: JSONEncoder = JSONEncoder(),
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) rethrows where T: Encodable {
    let encodable = try encodable()
    let json = try json()
    XCTAssertNoDifference(
        try JSON(of: encodable, encoder: encoder),
        json,
        message(),
        file: file,
        line: line
    )
}

public func XCTAssertJSONDecoding<T>(
    _ json: @autoclosure () throws -> JSON,
    _ decodable: @autoclosure () throws -> T,
    _ decoder: JSONDecoder = JSONDecoder(),
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) rethrows where T: Decodable, T: Equatable {
    let json = try json()
    let decodable = try decodable()
    XCTAssertNoDifference(
        try json.as(T.self, decoder: decoder),
        decodable,
        message(),
        file: file,
        line: line
    )
}
