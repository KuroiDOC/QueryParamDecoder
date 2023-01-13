import Foundation

public class QueryParamDecoder: Decoder {
    public var codingPath: [CodingKey] = []
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    public var dateDecodingStrategy: DateDecodingStrategy?

    private var queryParams: [String: String?] = [:]

    public init() {}

    static func convertToDictionary(queryParams: String) -> [String: String] {
        return queryParams.split(separator: "&").reduce(into: [String: String]()) { (result, pair) in
            let keyValue = pair.split(separator: "=")
            result[String(keyValue[0])] = String(keyValue[1])
        }
    }

    public func container<Key>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(QueryParamKeyedDecodingContainer<Key>(decoder: self, codingPath: self.codingPath, queryParams: queryParams))
    }

    public func unkeyedContainer() -> UnkeyedDecodingContainer {
        fatalError("unkeyed container not supported")
    }

    public func singleValueContainer() -> SingleValueDecodingContainer {
        fatalError("single value container not supported")
    }

    public func decode<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        queryParams = queryItems?.reduce([String: String?]()) { result, item in
            var result = result
            result[item.name.lowercased()] = item.value
            return result
        } ?? [:]
        return try T(from: self)
    }

    public enum DateDecodingStrategy: Sendable {
        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)

        /// Decode the `Date` as a custom value decoded by the given closure.
        @preconcurrency case custom(@Sendable (_ value: String) throws -> Date?)
    }
}

class QueryParamKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    var decoder: QueryParamDecoder
    var codingPath: [CodingKey]
    var allKeys: [Key] {
        return queryParams.keys.compactMap { Key(stringValue: $0) }
    }
    let queryParams: [String: String?]

    init(decoder: QueryParamDecoder, codingPath: [CodingKey], queryParams: [String: String?]) {
        self.decoder = decoder
        self.codingPath = codingPath
        self.queryParams = queryParams
    }

    func contains(_ key: Key) -> Bool {
        return queryParams[key.stringValue.lowercased()] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        let value = queryParams[key.stringValue] ?? nil
        return value?.isEmpty ?? true
    }

    private func queryItemValue(for key: Key) -> String? {
        queryParams[key.stringValue.lowercased()] ?? nil
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "No value found for key \(key.stringValue)"))
        }

        guard let value = queryItemValue(for: key) else {
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Null found for key \(key.stringValue)"))
        }

        return value
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        if let value = queryItemValue(for: key)?.lowercased() {
            guard let boolValue = Bool(value) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Bool"))
            }
            return boolValue
        }

        // Assume flag parameters to be true just for being present
        return true
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let doubleValue = Double(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Bool"))
        }

        return doubleValue
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let floatValue = Float(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Bool"))
        }

        return floatValue
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = Int(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = Int8(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = Int16(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = Int32(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = Int64(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = UInt(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = UInt8(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = UInt16(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = UInt32(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key), let intValue = UInt64(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Int"))
        }

        return intValue
    }

    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        return try? decode(type, forKey: key)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        switch type {
        case is Date.Type:
            guard let strategy = decoder.dateDecodingStrategy else {
                fatalError("No strategy for decoding date")
            }
            return try decode(strategy: strategy, forKey: key) as! T
        default:
            break
        }

        fatalError("Not supported")
    }

    func decode(strategy: QueryParamDecoder.DateDecodingStrategy, forKey key: Key) throws -> Date {
        guard contains(key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found"))
        }

        guard let value = queryItemValue(for: key) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Date"))
        }

        switch strategy {
        case .formatted(let formatter):
            guard let date = formatter.date(from: value) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Date"))
            }

            return date
        case .custom(let closure):
            guard let date = try? closure(value) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Could not convert value to Date"))
            }

            return date
        }
    }


    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("nestedContainer not supported")
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError("nestedUnkeyedContainer not supported")
    }

    func superDecoder() throws -> Decoder {
        fatalError("superDecoder not supported")
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError("superDecoder not supported")
    }
}

