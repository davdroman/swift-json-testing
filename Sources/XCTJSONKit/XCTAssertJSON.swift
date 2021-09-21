import CustomDump
import XCTest

public func XCTAssertJSONCoding<T>(
    _ codable: @autoclosure () throws -> T,
    _ encoder: JSONEncoder = JSONEncoder(),
    _ decoder: JSONDecoder = JSONDecoder(),
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws where T: Codable, T: Equatable {
    let codable = try codable()
    let sut = try decoder.decode(T.self, from: encoder.encode(codable))
    XCTAssertNoDifference(sut, codable, message(), file: file, line: line)
}

public func XCTAssertJSONCoding<T>(
    _ codableEnum: T.Type,
    _ encoder: JSONEncoder = JSONEncoder(),
    _ decoder: JSONDecoder = JSONDecoder(),
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws where T: Codable, T: Equatable, T: CaseIterable {
    let allCases = codableEnum.allCases
    for `case` in allCases {
        try XCTAssertJSONCoding(`case`, encoder, decoder, message(), file: file, line: line)
    }
}

public func XCTAssertJSONEncoding<T>(
    _ encodable: @autoclosure () throws -> T,
    _ json: @autoclosure () throws -> JSON,
    _ encoder: JSONEncoder = JSONEncoder(),
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws where T: Encodable {
    let sut = try JSON(of: encodable(), encoder: encoder)
    let json = try json()
    XCTAssertNoDifference(sut, json, message(), file: file, line: line)
}

public func XCTAssertJSONDecoding<T>(
    _ json: @autoclosure () throws -> JSON,
    _ decodable: @autoclosure () throws -> T,
    _ decoder: JSONDecoder = JSONDecoder(),
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws where T: Decodable, T: Equatable {
    let sut = try json().as(T.self, decoder: decoder)
    let decodable = try decodable()
    XCTAssertNoDifference(sut, decodable, message(), file: file, line: line)
}
