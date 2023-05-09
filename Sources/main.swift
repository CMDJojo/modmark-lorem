// Compile with xcrun --toolchain swiftwasm swift build --triple wasm32-unknown-wasi -c release

import Foundation
import LoremSwiftum

let manifest = Manifest(
    name: "lorem",
    version: "0.1.1",
    description: "Generates placeholder text",
    transforms: [
        Transform(
            from: "lorem",
            to: ["any"],
            description: "Generates lorem text. Enter the number of units in the body possibly suffixed by an unit",
            arguments: [
                Argument(
                    name: "unit",
                    description: "The unit type to generate",
                    type: .enum(["p", "paragraph", "paragraphs", "s", "sentence", "sentences", "w", "word", "words", "n", "name", "names", "@", "email", "emails", "://", "url", "urls", "tw", "tweet", "tweets", "infer"]),
                    default: .string("infer")
                )
            ]
        )
    ]
)

enum Unit {
    case paragraph, sentence, word, name, email, url, tweet
    
    init?(parse str: String) {
        switch str.lowercased() {
            case "p", "paragraph", "paragraphs": self = .paragraph
            case "s", "sentence", "sentences": self = .sentence
            case "w", "word", "words": self = .word
            case "n", "name", "names": self = .name
            case "@", "email", "emails": self = .email
            case "://", "url", "urls": self = .url
            case "tw", "tweet", "tweets": self = .tweet
            default: return nil
        }
    }
}

let args = CommandLine.arguments
if args.count == 2, args[1] == "manifest" {
    let encoder = JSONEncoder()
    let data = try encoder.encode(manifest)
    let json = String(data: data, encoding: .utf8)!
    print(json)
    exit(0)
}

guard args.count == 4, args[1] == "transform", args[2] == "lorem" else {
    fatalError("Must be called 'lorem manifest' or 'lorem transform lorem ...'")
}

let input = AnyIterator { readLine() }.joined(separator: "")
let decoder = JSONDecoder()
let module = try decoder.decode(Module.self, from: input.data(using: .utf8)!)

let numbers = module.data.prefix(while: { $0.isNumber })
guard !numbers.isEmpty else {
    fputs("Enter a length as body. Examples: '[lorem] 10', '[lorem] 1sentence'\n", stderr)
    exit(0)
}
let count = Int(numbers)!

let suffix = module.data[numbers.endIndex...].trimmingCharacters(in: .whitespaces)

var unitBase: String

if !suffix.isEmpty {
    unitBase = suffix
} else if case .string(let s) = module.arguments["unit"], s != "infer" {
    unitBase = s
} else if module.inline {
    unitBase = "word"
} else {
    unitBase = "paragraph"
}

var unit: Unit

if let u = Unit.init(parse: unitBase) {
    unit = u
} else {
    fputs("Cannot parse \(unitBase) to an unit\n", stderr)
    if module.inline {
        unit = .word
    } else {
        unit = .paragraph
    }
}

var paragraphs: [String]

switch unit {
    case .word:
        paragraphs = [Lorem.words(count)]
    case .sentence:
        paragraphs = [Lorem.sentences(count)]
    case .paragraph:
        paragraphs = Array(AnyIterator { Lorem.paragraph }.prefix(count))
    case .tweet:
        paragraphs = Array(AnyIterator { Lorem.tweet }.prefix(count))
    case .name:
        paragraphs = [AnyIterator { Lorem.fullName }.prefix(count).joined(separator: ", ")]
    case .email:
        paragraphs = [AnyIterator { Lorem.emailAddress }.prefix(count).joined(separator: ", ")]
    case .url:
        paragraphs = [AnyIterator { Lorem.url }.prefix(count).joined(separator: ", ")]
}

let encoder = JSONEncoder()
if module.inline {
    let modules = paragraphs.map {text in
        Module(name: "__text", data: text, arguments: [:], inline: true)
    }
    let data = try encoder.encode(modules)
    let json = String(data: data, encoding: .utf8)!
    print(json)
} else {
    let paragraphs = paragraphs.map {text in
        Parent(name: "__paragraph", arguments: [:], children: [
            Module(name: "__text", data: text, arguments: [:], inline: false)
        ])
    }
    let data = try encoder.encode(paragraphs)
    let json = String(data: data, encoding: .utf8)!
    print(json)
}
