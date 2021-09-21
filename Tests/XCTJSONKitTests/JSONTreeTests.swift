import CustomDump
import XCTJSONKit

final class JSONTreeTests: XCTestCase {
    func testDebugDescription() {
        XCTAssertNoDifference(
            ("foobar" as JSONTree).debugDescription,
            """
            "foobar"
            """
        )
        XCTAssertNoDifference(
            (3 as JSONTree).debugDescription,
            """
            3
            """
        )
        XCTAssertNoDifference(
            (["hello", "world"] as JSONTree).debugDescription,
            """
            [
              "hello",
              "world"
            ]
            """
        )
        XCTAssertNoDifference(
            (["key": "value"] as JSONTree).debugDescription,
            """
            {
              "key" : "value"
            }
            """
        )
        XCTAssertNoDifference(
            (true as JSONTree).debugDescription,
            """
            true
            """
        )
        XCTAssertNoDifference(
            (nil as JSONTree).debugDescription,
            """
            null
            """
        )
    }
}
