//
//  UserDefaultsWrapper.swift
//
//  Created by Artur on 18/06/2020.
//

import Foundation

enum UserDefaultsKey {}

@propertyWrapper
struct CodableUserDefaultsBacked<Value: Codable> {
    let key: String
    let defaultValue: Value?
    let storage: UserDefaults
    
    init(_ key: String, defaultValue: Value? = nil, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
    
    var wrappedValue: Value? {
        get {
            guard let saved = storage.object(forKey: self.key) as? Data else { return nil }
            return try? JSONDecoder().decode(Value.self, from: saved)
        }
        set {
            if let newValue = newValue, let encoded = try? JSONEncoder().encode(newValue) {
                storage.set(encoded, forKey: self.key)
            } else {
                storage.removeObject(forKey: self.key)
            }
        }
    }
}

@propertyWrapper
struct UserDefaultsBacked<Value> {
    let key: String
    let defaultValue: Value
    let storage: UserDefaults
    
    init(_ key: String, defaultValue: Value, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.setValue(newValue, forKey: key)
            }

        }
    }
}

extension UserDefaultsBacked where Value: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = .standard) {
        self.init(key, defaultValue: nil, storage: storage)
    }
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}
