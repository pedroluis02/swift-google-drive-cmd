import ArgumentParser

@main
struct GoogleDriveCmd: ParsableCommand {
    @Argument
    var arg = ""

    mutating func run() throws {
        print("Google Drive Cmd Client")
        print("arg: \(arg)")   
    }
}
