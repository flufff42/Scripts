import Foundation
import Commandant
import Result

extension String {
    func pointAt(offset: String.CharacterView.IndexDistance, context: Int = 0, pointer: Character = "^") throws -> String {
        guard let offsetStart = index(startIndex, offsetBy: offset, limitedBy: endIndex) else { throw "Offset beyond input length \(distance(from: startIndex, to: endIndex))" }
        let rangeOfLine = lineRange(for: offsetStart..<offsetStart)

        var precedingContextLines = [String]()
        var precedingLineRange = rangeOfLine
        (0..<context).forEach { (_) in
            if let range = lineBefore(range: precedingLineRange) {
                precedingLineRange = range
                precedingContextLines.append(substring(with: range))
            }
        }

        let lineOfInterest = substring(with: rangeOfLine)
        let indent = offset - distance(from: startIndex, to: rangeOfLine.lowerBound)
        var indicator = String([Character].init(repeating: " ", count: indent))
        indicator.append("\(pointer)\n")

        var succeedingContextLines = [String]()
        var succeedingLineRange = rangeOfLine
        (0..<context).forEach { (_) in
            if let range = lineAfter(range: succeedingLineRange) {
                succeedingLineRange = range
                succeedingContextLines.append(substring(with: range))
            }
        }
        
        return precedingContextLines.reversed().joined().appending(lineOfInterest.appending(indicator)).appending(succeedingContextLines.joined())
    }

    /// Returns the line prior to the given range, if any.
    ///
    /// - Parameter range: The range passed here should be the result of a call to `lineRange(for:)`
    func lineBefore(range: Range<String.Index>) -> Range<String.Index>? {
        guard range.lowerBound != startIndex else { return nil }
        return lineRange(for: index(before: range.lowerBound)..<index(before: range.lowerBound))
    }

    /// Returns the line following to the given range, if any.
    ///
    /// - Parameter range: The range passed here should be the result of a call to `lineRange(for:)`
    func lineAfter(range: Range<String.Index>) -> Range<String.Index>? {
        guard range.upperBound != endIndex else { return nil }
        return lineRange(for: index(after: range.upperBound)..<index(after: range.upperBound))
    }
}

extension String: Error {}

struct OffsetOptions: OptionsProtocol {
    let offset: Int
    let context: Int
    let pointer: String
    let filePath: String
    
    static func create(_ offset: Int) -> (Int) -> (String) -> (String) -> OffsetOptions {
        return { context in
            return { pointer in
                return { filePath in
                    OffsetOptions.init(offset: offset, context: context, pointer: pointer, filePath: filePath)
                }
            }
        }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<OffsetOptions, CommandantError<String>> {
        return create
            <*> m <| Option(key: "offset", defaultValue: 0, usage: "The offset for the pointer to be output")
            <*> m <| Option(key: "context", defaultValue: 0, usage: "Lines of context to show around the line pointed at")
            <*> m <| Option(key: "pointer", defaultValue: "^", usage: "Character to use to point at offset")
            <*> m <| Argument(usage: "the file path containing the offset to point at")
    }
}

struct PointCommand: CommandProtocol {
    var verb: String = "pointer"
    var function: String = "Outputs a pointer to the specified offset in the given file"
    
    func run(_ options: OffsetOptions) -> Result<(), String> {
        do {
            let pointer = Character(options.pointer)
            let contents = try String(contentsOfFile: options.filePath)
            print(try contents.pointAt(offset: options.offset, context: options.context, pointer: pointer))
            return .success()
        } catch let error as String {
            return .failure(error)
        } catch {
            return .failure("Unexpected error \(error)")
        }
    }
}

let commands = CommandRegistry<String>()
commands.register(PointCommand())
let help = HelpCommand(registry: commands)
commands.register(help)

var arguments = CommandLine.arguments

commands.main(arguments: arguments, defaultVerb: "help") { (error) in
    print("Error: \(error)")
}
