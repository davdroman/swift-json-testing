import Foundation

public enum XCTAssertJSON {
    public struct Configuration {
        public let encoder: JSONEncoder
        public let decoder: JSONDecoder

        public init(encoder: JSONEncoder, decoder: JSONDecoder) {
            self.encoder = encoder
            self.decoder = decoder
        }
    }

    public static var configuration: Configuration {
        get { XCTAssertJSONConfiguration }
        set { XCTAssertJSONConfiguration = newValue }
    }
}

private var XCTAssertJSONConfiguration = XCTAssertJSON.Configuration(
    encoder: JSONEncoder(),
    decoder: JSONDecoder()
)
