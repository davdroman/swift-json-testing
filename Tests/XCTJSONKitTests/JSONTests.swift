import CustomDump
import XCTJSONKit

final class JSONTests: XCTestCase {
    func testBasicInits() throws {
        // strings
        try assert(jsonObject: "", raw: #""""#)
        try assert(jsonObject: "hello world", raw: #""hello world""#)
        try assert(jsonObject: "hello world\nit's me", raw: #""hello world\nit's me""#)

        // numbers
        try assert(jsonObject: -3, raw: #"-3"#)
        try assert(jsonObject: 0, raw: #"0"#)
        try assert(jsonObject: 3, raw: #"3"#)
        try assert(jsonObject: 3.25, raw: #"3.25"#)

        // objects
        try assert(jsonObject: [:] as [String: AnyHashable], raw: #"{}"#)
        try assert(jsonObject: ["": ""], raw: #"{"":""}"#)
        try assert(jsonObject: ["key": "value"], raw: #"{"key":"value"}"#)
        try assert(jsonObject: ["key": 1], raw: #"{"key":1}"#)
        try assert(jsonObject: ["key": ["otherKey": "value"]], raw: #"{"key":{"otherKey":"value"}}"#)
        try assert(jsonObject: ["key": ["value1", "value2"]], raw: #"{"key":["value1","value2"]}"#)
        try assert(jsonObject: ["key": true], raw: #"{"key":true}"#)
        try assert(jsonObject: ["key": NSNull()], raw: #"{"key":null}"#)

        // arrays
        try assert(jsonObject: [] as [AnyHashable], raw: #"[]"#)
        try assert(jsonObject: ["", "hello", "world"], raw: #"["","hello","world"]"#)
        try assert(jsonObject: ["", "hello", "world"], raw: #"["","hello","world"]"#)
        try assert(jsonObject: [1, 2, 3], raw: #"[1,2,3]"#)
        try assert(jsonObject: [["key": "value"]], raw: #"[{"key":"value"}]"#)
        try assert(jsonObject: [[1, 2, 3]], raw: #"[[1,2,3]]"#)
        try assert(jsonObject: [true, false, true], raw: #"[true,false,true]"#)
        try assert(jsonObject: [NSNull(), NSNull(), NSNull()].map(AnyHashable.init), raw: #"[null,null,null]"#)

        // booleans
        try assert(jsonObject: true, raw: #"true"#)
        try assert(jsonObject: false, raw: #"false"#)

        // null
        try assert(jsonObject: NSNull(), raw: #"null"#)
        try assert(json: JSON(Int?.none), jsonObject: NSNull(), raw: #"null"#)
    }

    func testEncodableConversion() throws {
        struct Empty: Encodable {}
        try assert(json: JSON(of: Empty()), jsonObject: [:] as [String: AnyHashable], raw: #"{}"#)

        enum SingleValue: String, Encodable, CaseIterable {
            case one, two, three
        }
        try assert(json: JSON(of: SingleValue.one), jsonObject: "one", raw: #""one""#)
        try assert(json: JSON(of: SingleValue.allCases), jsonObject: ["one", "two", "three"], raw: #"["one","two","three"]"#)

        struct MultipleValue: Encodable {
            var string: String
            var int: Int
        }
        try assert(
            json: JSON(of: MultipleValue(string: "a", int: 3)),
            jsonObject: ["string": "a", "int": 3] as [String: AnyHashable],
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
            JSON(["string": "a", "int": 3] as [String: AnyHashable]).as(MultipleValue.self),
            MultipleValue(string: "a", int: 3)
        )
    }

    func testNull() throws {
        try assert(json: .null, jsonObject: NSNull(), raw: #"null"#)
        try assert(json: .null, jsonObject: NSNull(), raw: #"null"#)
    }
}

private extension JSONTests {
    func assert(
        json: JSON? = nil,
        jsonObject: AnyHashable,
        raw: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let suts = try [
            (json != nil ? "Original JSON" : "init(_ jsonObject:)", json ?? JSON(jsonObject)),
            ("init(raw:)", JSON(raw: raw))
        ]
        for (origin, sut) in suts {
            XCTAssertNoDifference(sut.jsonObject, jsonObject, "\(origin) - 'jsonObject' property", file: file, line: line)
            XCTAssert(sut.data.count > 0, "\(origin) - 'data' is empty", file: file, line: line)
            XCTAssertNoDifference(sut.raw, raw, "\(origin) - 'raw' property", file: file, line: line)
        }
    }
}
