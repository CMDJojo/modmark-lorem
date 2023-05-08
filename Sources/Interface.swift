import Foundation

struct Manifest: Encodable {
    let name, version, description: String
    let transforms: [Transform]
}

struct Transform: Encodable {
    let from: String
    let to: [String]
    let description: String
    let arguments: [Argument]
}

struct Argument: Encodable {
    let name, description: String
    let type: ArgumentType
    let `default`: ArgumentValue
}

enum ArgumentType {
    case string, int, float, `enum`([String])
}

extension ArgumentType: Encodable {
    func encode(to encoder: Encoder) throws {
        if case .`enum`(let strs) = self {
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: strs)
        } else {
            var container = encoder.singleValueContainer()
            switch self {
                case .string: try container.encode("string")
                case .float: try container.encode("float")
                case .int: try container.encode("int")
                default: ()
            }
        }
    }
}

enum ArgumentValue {
    case string(String), int(Int), float(Float)
}

extension ArgumentValue: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .string(let s):
                try container.encode(s)
            case .int(let i):
                try container.encode(i)
            case .float(let f):
                try container.encode(f)
        }
    }
}

extension ArgumentValue {
    var string: String? {
        if case .string(let s) = self {
            return s
        } else {
            return nil
        }
    }

    var int: Int? {
        if case .int(let i) = self {
            return i
        } else {
            return nil
        }
    }

    var float: Float? {
        if case .float(let f) = self {
            return f
        } else {
            return nil
        }
    }
}

extension ArgumentValue: Decodable {
    init(from decoder: Decoder) throws {
        let item = try decoder.singleValueContainer()

        if let int = try? item.decode(Int.self) {
            self = .int(int)
        } else if let float = try? item.decode(Float.self) {
            self = .float(float)
        } else if let string = try? item.decode(String.self) {
            self = .string(string)
        } else {
            fatalError()
        }
    }
}

struct Module: Codable {
    let name, data: String
    let arguments: [String: ArgumentValue]
    let inline: Bool
}

struct Parent: Codable {
    let name: String
    let arguments: [String: ArgumentValue]
    let children: [Module]
}
