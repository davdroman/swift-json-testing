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
        try assert(json: JSON(of: Empty()), [:], raw: #"{}"#)

        enum SingleValue: String, Encodable, CaseIterable {
            case one, two, three
        }
        try assert(json: JSON(of: SingleValue.one), "one", raw: #""one""#)
        try assert(json: JSON(of: SingleValue.allCases), ["one", "two", "three"], raw: #"["one","two","three"]"#)

        struct MultipleValue: Encodable {
            var string: String
            var int: Int
        }
        try assert(
            json: JSON(of: MultipleValue(string: "a", int: 3)), ["string": "a", "int": 3],
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
            JSON.string("foobar").debugDescription,
            """
            "foobar"
            """
        )
        XCTAssertNoDifference(
            JSON.number(3).debugDescription,
            """
            3
            """
        )
        XCTAssertNoDifference(
            JSON.array(["hello", "world"]).debugDescription,
            """
            [
              "hello",
              "world"
            ]
            """
        )
        XCTAssertNoDifference(
            JSON.object(["key": "value"]).debugDescription,
            """
            {
              "key" : "value"
            }
            """
        )
        XCTAssertNoDifference(
            JSON.bool(true).debugDescription,
            """
            true
            """
        )
        XCTAssertNoDifference(
            JSON.null.debugDescription,
            """
            null
            """
        )
    }
}

private extension JSONTests {
    func assert(
        json: JSON...,
        raw: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let pairs: PairSequence<[JSON]>
        if json.count == 1 {
            pairs = .init(sequence: [json[0], json[0]])
        } else {
            pairs = json.adjacentPairs()
        }

        for (lhsIndex, (lhs, rhs)) in pairs.enumerated() {
            let rhsIndex = lhsIndex + 1

            let indexes = "#\(lhsIndex), #\(rhsIndex)"
            XCTAssertNoDifference(lhs, rhs, "json at indexes \(indexes)", file: file, line: line)
            XCTAssertNoDifference(lhs.data, rhs.data, "json.data at indexes \(indexes)", file: file, line: line)
            XCTAssertNoDifference(lhs.raw, rhs.raw, "json.raw at indexes \(indexes)", file: file, line: line)

            let jsonFromRaw = try JSON(raw: raw)
            XCTAssertNoDifference(lhs, jsonFromRaw, "json at index \(lhsIndex) and json from raw", file: file, line: line)
            XCTAssertNoDifference(rhs, jsonFromRaw, "json at index \(rhsIndex) and json from raw", file: file, line: line)
            XCTAssertNoDifference(lhs.data, jsonFromRaw.data, "json.data at index \(lhsIndex) and json.data from raw", file: file, line: line)
            XCTAssertNoDifference(rhs.data, jsonFromRaw.data, "json.data at index \(rhsIndex) and json.data from raw", file: file, line: line)
            XCTAssertNoDifference(lhs.raw, jsonFromRaw.raw, "json.raw at index \(lhsIndex) and json.raw from raw", file: file, line: line)
            XCTAssertNoDifference(rhs.raw, jsonFromRaw.raw, "json.raw at index \(rhsIndex) and json.raw from raw", file: file, line: line)
        }
    }
}
