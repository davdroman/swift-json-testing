import CustomDump
import XCTJSONKit

final class JSONTests: XCTestCase {
    func testBasicInits() throws {
        // strings
        try assert(jsonTree: "", raw: #""""#)
        try assert(jsonTree: "hello world", raw: #""hello world""#)
        try assert(jsonTree: "hello world\nit's me", raw: #""hello world\nit's me""#)

        // numbers
        try assert(jsonTree: -3, raw: #"-3"#)
        try assert(jsonTree: 0, raw: #"0"#)
        try assert(jsonTree: 3, raw: #"3"#)
        try assert(jsonTree: 3.25, raw: #"3.25"#)

        // objects
        try assert(jsonTree: [:], raw: #"{}"#)
        try assert(jsonTree: ["": ""], raw: #"{"":""}"#)
        try assert(jsonTree: ["key": "value"], raw: #"{"key":"value"}"#)
        try assert(jsonTree: ["key": 1], raw: #"{"key":1}"#)
        try assert(jsonTree: ["key": ["otherKey": "value"]], raw: #"{"key":{"otherKey":"value"}}"#)
        try assert(jsonTree: ["key": ["value1", "value2"]], raw: #"{"key":["value1","value2"]}"#)
        try assert(jsonTree: ["key": true], raw: #"{"key":true}"#)
        try assert(jsonTree: ["key": nil], raw: #"{"key":null}"#)

        // arrays
        try assert(jsonTree: [], raw: #"[]"#)
        try assert(jsonTree: ["", "hello", "world"], raw: #"["","hello","world"]"#)
        try assert(jsonTree: ["", "hello", "world"], raw: #"["","hello","world"]"#)
        try assert(jsonTree: [1, 2, 3], raw: #"[1,2,3]"#)
        try assert(jsonTree: [["key": "value"]], raw: #"[{"key":"value"}]"#)
        try assert(jsonTree: [[1, 2, 3]], raw: #"[[1,2,3]]"#)
        try assert(jsonTree: [true, false, true], raw: #"[true,false,true]"#)
        try assert(jsonTree: [nil, nil, nil], raw: #"[null,null,null]"#)

        // booleans
        try assert(jsonTree: true, raw: #"true"#)
        try assert(jsonTree: false, raw: #"false"#)

        // null
        try assert(jsonTree: nil, raw: #"null"#)
    }

    func testEncodableConversion() throws {
        struct Empty: Encodable {}
        try assert(json: JSON(of: Empty()), jsonTree: [:], raw: #"{}"#)

        enum SingleValue: String, Encodable, CaseIterable {
            case one, two, three
        }
        try assert(json: JSON(of: SingleValue.one), jsonTree: "one", raw: #""one""#)
        try assert(json: JSON(of: SingleValue.allCases), jsonTree: ["one", "two", "three"], raw: #"["one","two","three"]"#)

        struct MultipleValue: Encodable {
            var string: String
            var int: Int
        }
        try assert(
            json: JSON(of: MultipleValue(string: "a", int: 3)),
            jsonTree: ["string": "a", "int": 3],
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
}

private extension JSONTests {
    func assert(
        json: JSON? = nil,
        jsonTree: JSONTree,
        raw: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let suts = try [
            (json != nil ? "Original JSON" : "init(_ jsonObject:)", json ?? JSON(jsonTree)),
            ("init(raw:)", JSON(raw: raw))
        ]
        for (origin, sut) in suts {
            XCTAssertNoDifference(sut.tree, jsonTree, "\(origin) - 'jsonObject' property", file: file, line: line)
            XCTAssert(sut.data.count > 0, "\(origin) - 'data' is empty", file: file, line: line)
            XCTAssertNoDifference(sut.raw, raw, "\(origin) - 'raw' property", file: file, line: line)
        }
    }
}
