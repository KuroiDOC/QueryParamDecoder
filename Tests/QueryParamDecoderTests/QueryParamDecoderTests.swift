import XCTest
@testable import QueryParamDecoder

final class QueryParamDecoderTests: XCTestCase {
    struct MyStruct: Decodable {
        var intParam: Int
        var strParam: String
        var flag: Bool?
        var flag2: Bool
        var date: Date?
    }

    func testDecoder() throws {
        let url = URL(string: "https://example.com?intParam=5&strParam=test&flag=false&flag2&date=2023-01-13")!
        let decoder = QueryParamDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)

        let result = try! decoder.decode(MyStruct.self, from: url)

        XCTAssertEqual(result.intParam, 5)
        XCTAssertEqual(result.strParam, "test")
        XCTAssertNotNil(result.flag)
        XCTAssertFalse(result.flag!)
        XCTAssertTrue(result.flag2)
        XCTAssertEqual(result.intParam, 5)
        XCTAssertNotNil(result.date)
        XCTAssertEqual(formatter.string(from: result.date!), "2023-01-13")
    }
}
