import Foundation

extension UserDefaults {
    // MARK: - Encode And Set
    func encodeAndSet<T: Encodable>(_ value: T, forKey key: SaveKey) throws {
        let encodedValue = try JSONEncoder().encode(value)
        
        setValue(encodedValue, forKey: key.rawValue)
    }
    
    // MARK: - Load And Decode
    func loadAndDecode<T: Decodable>(fromKey key: SaveKey) throws -> T {
        guard let loadedValue = data(forKey: key.rawValue) else {
            throw UserDefaultsDecodingError.noValueForKey
        }
        
        return try JSONDecoder().decode(T.self, from: loadedValue)
    }
    
    func loadAndDecode<T: Decodable>(fromKey key: SaveKey, withDefault defaultValue: T) -> T {
        (try? loadAndDecode(fromKey: key) as T) ?? defaultValue
    }
    
    // MARK: - Decoding Error
    enum UserDefaultsDecodingError: Error, LocalizedError {
        case noValueForKey
        
        var errorDescription: String? {
            switch self {
            case .noValueForKey:
                return "There is no value with the given key."
            }
        }
    }
    
    // MARK: - Save Keys
    enum SaveKey: String {
        case customerName
    }
}

