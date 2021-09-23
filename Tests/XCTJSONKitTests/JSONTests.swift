import CustomDump
import XCTJSONKit

final class JSONTests: XCTestCase {
    func testBasicInits() throws {
        // strings
        try assert(json: "", raw: #""""#)
        try assert(json: "hello world", raw: #""hello world""#)
        try assert(json: "hello world\nit's me", raw: #""hello world\nit's me""#)

        // numbers
        try assert(json: -3, raw: #"-3"#)
        try assert(json: 0, raw: #"0"#)
        try assert(json: 3, raw: #"3"#)
        try assert(json: 3.25, raw: #"3.25"#)

        // objects
        try assert(json: [:], raw: #"{}"#)
        try assert(json: ["": ""], raw: #"{"":""}"#)
        try assert(json: ["key": "value"], raw: #"{"key":"value"}"#)
        try assert(json: ["key": 1], raw: #"{"key":1}"#)
        try assert(json: ["key": ["otherKey": "value"]], raw: #"{"key":{"otherKey":"value"}}"#)
        try assert(json: ["key": ["value1", "value2"]], raw: #"{"key":["value1","value2"]}"#)
        try assert(json: ["key": true], raw: #"{"key":true}"#)
        try assert(json: ["key": nil], raw: #"{"key":null}"#)

        // arrays
        try assert(json: [], raw: #"[]"#)
        try assert(json: ["", "hello", "world"], raw: #"["","hello","world"]"#)
        try assert(json: ["", "hello", "world"], raw: #"["","hello","world"]"#)
        try assert(json: [1, 2, 3], raw: #"[1,2,3]"#)
        try assert(json: [["key": "value"]], raw: #"[{"key":"value"}]"#)
        try assert(json: [[1, 2, 3]], raw: #"[[1,2,3]]"#)
        try assert(json: [true, false, true], raw: #"[true,false,true]"#)
        try assert(json: [nil, nil, nil], raw: #"[null,null,null]"#)

        // booleans
        try assert(json: true, raw: #"true"#)
        try assert(json: false, raw: #"false"#)

        // null
        try assert(json: nil, raw: #"null"#)
    }

    func testEncodableConversion() throws {
        struct Empty: Encodable {}
        try assert(originalJSON: JSON(of: Empty()), json: [:], raw: #"{}"#)

        enum SingleValue: String, Encodable, CaseIterable {
            case one, two, three
        }
        try assert(originalJSON: JSON(of: SingleValue.one), json: "one", raw: #""one""#)
        try assert(originalJSON: JSON(of: SingleValue.allCases), json: ["one", "two", "three"], raw: #"["one","two","three"]"#)

        struct MultipleValue: Encodable {
            var string: String
            var int: Int
        }
        try assert(
            originalJSON: JSON(of: MultipleValue(string: "a", int: 3)),
            json: ["string": "a", "int": 3],
            raw: #"{"int":3,"string":"a"}"#
        )
    }

    func testDecodableConversion() throws {
        struct Empty: Decodable, Equatable {}
        try XCTAssertNoDifference(JSON(raw: #"{}"#).as(Empty.self), Empty())

        enum SingleValue: String, Decodable, CaseIterable, Equatable {
            case one, two, three
        }
        try XCTAssertNoDifference(JSON("one").as(SingleValue.self), .one)
        try XCTAssertNoDifference(JSON(["one", "two", "three"]).as([SingleValue].self), SingleValue.allCases)

        struct MultipleValue: Decodable, Equatable {
            var string: String
            var int: Int
        }
        try XCTAssertNoDifference(
            JSON(["string": "a", "int": 3]).as(MultipleValue.self),
            MultipleValue(string: "a", int: 3)
        )
    }

    func testDebugDescription() {
        XCTAssertNoDifference(
            JSON("foobar").debugDescription,
            """
            "foobar"
            """
        )
        XCTAssertNoDifference(
            JSON(3).debugDescription,
            """
            3
            """
        )
        XCTAssertNoDifference(
            JSON(["hello", "world"]).debugDescription,
            """
            [
              "hello",
              "world"
            ]
            """
        )
        XCTAssertNoDifference(
            JSON(["key": "value"]).debugDescription,
            """
            {
              "key" : "value"
            }
            """
        )
        XCTAssertNoDifference(
            JSON(true).debugDescription,
            """
            true
            """
        )
        XCTAssertNoDifference(
            JSON(nil).debugDescription,
            """
            null
            """
        )
    }
}

private extension JSONTests {
    func assert(
        originalJSON: JSON? = nil,
        json: JSON,
        raw: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let suts = try [
            (originalJSON != nil ? "originalJSON" : "json", originalJSON ?? json),
            ("init(raw:)", JSON(raw: raw))
        ]
        for (origin, sut) in suts {
            XCTAssertNoDifference(sut, json, "\(origin) - self", file: file, line: line)
            XCTAssert(sut.data.count > 0, "\(origin) - data is empty", file: file, line: line)
            XCTAssertNoDifference(sut.raw, raw, "\(origin) - raw", file: file, line: line)
        }
    }
}
