import XCTJSONKit

final class XCTAssertJSONTests: XCTestCase {
    func testXCTAssertJSONCoding() throws {
        struct Empty: Codable, Equatable {}
        try XCTAssertJSONCoding(Empty())

        enum GoodSingleValue: String, Codable, CaseIterable, Equatable {
            case one, two, three
        }
        try XCTAssertJSONCoding(GoodSingleValue.one)

        #if !os(Linux)
        enum BadSingleValue: String, Codable, CaseIterable, Equatable {
            case one, two, three

            init(from decoder: Decoder) throws {
                self = .two
            }
        }
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONCoding(BadSingleValue.one)
        #endif

        struct GoodMultipleValue: Codable, Equatable {
            var string: String
            var int: Int
        }
        try XCTAssertJSONCoding(GoodMultipleValue(string: "a", int: 3))

        #if !os(Linux)
        struct BadMultipleValue: Codable, Equatable {
            var string: String
            var int: Int

            private enum CodingKeys: String, CodingKey { case string, int }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(string, forKey: .string)
                try container.encode(int + 1, forKey: .int)
            }
        }
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONCoding(BadMultipleValue(string: "a", int: 3))
        #endif
    }

    func testXCTAssertJSONCoding_enum() throws {
        enum GoodEnum: String, Codable, CaseIterable {
            case one, two, three
        }
        try XCTAssertJSONCoding(GoodEnum.self)

        #if !os(Linux)
        enum BadEnum: String, Codable, CaseIterable {
            case one, two, three

            init(from decoder: Decoder) throws {
                self = .two
            }
        }
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONCoding(BadEnum.self)
        #endif
    }

    func testXCTAssertJSONEncoding() throws {
        struct Empty: Encodable {}
        try XCTAssertJSONEncoding(Empty(), JSON(raw: #"{}"#))
        #if !os(Linux)
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONEncoding(Empty(), JSON(raw: #"[]"#))
        #endif

        enum SingleValue: String, Encodable, CaseIterable {
            case one, two, three
        }
        try XCTAssertJSONEncoding(SingleValue.one, "one")
        try XCTAssertJSONEncoding(SingleValue.allCases, ["one", "two", "three"])
        #if !os(Linux)
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONEncoding(SingleValue.two, "one")
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONEncoding(SingleValue.allCases.reversed(), ["one", "two", "three"])
        #endif

        struct MultipleValue: Encodable {
            var string: String
            var int: Int
        }
        try XCTAssertJSONEncoding(
            MultipleValue(string: "a", int: 3),
            ["string": "a", "int": 3]
        )
        #if !os(Linux)
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONEncoding(
            MultipleValue(string: "b", int: 4),
            ["string": "a", "int": 3]
        )
        #endif
    }

    func testXCTAssertJSONDecoding() throws {
        struct Empty: Decodable, Equatable {}
        try XCTAssertJSONDecoding(JSON(raw: #"{}"#), Empty())

        enum SingleValue: String, Decodable, CaseIterable, Equatable {
            case one, two, three
        }
        try XCTAssertJSONDecoding("one", SingleValue.one)
        try XCTAssertJSONDecoding(["one", "two", "three"], SingleValue.allCases)
        #if !os(Linux)
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONDecoding("two", SingleValue.one)
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONDecoding(["two", "one", "three"], SingleValue.allCases)
        #endif

        struct MultipleValue: Decodable, Equatable {
            var string: String
            var int: Int
        }
        try XCTAssertJSONDecoding(
            ["string": "a", "int": 3],
            MultipleValue(string: "a", int: 3)
        )
        #if !os(Linux)
        XCTExpectFailure(options: Self.options)
        try XCTAssertJSONDecoding(
            ["string": "a", "int": 3],
            MultipleValue(string: "b", int: 4)
        )
        #endif
    }
}

#if !os(Linux)
private extension XCTAssertJSONTests {
    static let options: XCTExpectedFailure.Options = {
        let options = XCTExpectedFailure.Options()
        options.isStrict = true
        options.issueMatcher = { $0.type == .assertionFailure }
        return options
    }()
}
#endif
