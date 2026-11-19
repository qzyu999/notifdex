// swift-tools-version: 5.9
import PackageDescription

#if os(macOS)
// The macOS SDK supplies SQLite headers and the library directly.
let sqlitePkgConfig: String? = nil
#else
let sqlitePkgConfig: String? = "sqlite3"
#endif

let package = Package(
    name: "Notifdex",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "NotifdexCore", targets: ["NotifdexCore"]),
        .executable(name: "notifdex-capture", targets: ["NotifdexCapture"]),
        .executable(name: "Notifdex", targets: ["NotifdexApp"])
    ],
    targets: [
        .systemLibrary(name: "CSQLite", pkgConfig: sqlitePkgConfig),
        .target(
            name: "NotifdexCore",
            dependencies: ["CSQLite"],
            path: ".",
            exclude: ["AGENTS.md", "README.md", "Sources/CSQLite", "Sources/NotifdexMac",
                      "Sources/NotifdexCapture", "Sources/NotifdexApp", "Tests", "tests", "spec", "tools", "docs", "dist"],
            sources: [
                "Sources/NotifdexCore/AppSettings.swift",
                "Sources/NotifdexCore/CaptureStore.swift",
                "Sources/NotifdexCore/Inbox.swift",
                "Sources/NotifdexCore/InboxPresentation.swift",
                "Sources/NotifdexCore/Observation.swift",
                "Sources/NotifdexCore/RelationshipTemplate.swift"
            ],
            resources: [
                .copy("Sources/NotifdexCore/schema.sql"), .copy("Sources/NotifdexCore/inbox-work.sql"),
                .copy("Sources/NotifdexCore/filters.sql"), .copy("Sources/NotifdexCore/person-matches.sql"),
                .copy("Sources/NotifdexCore/person-notes.sql"), .copy("Sources/NotifdexCore/flags.sql"),
                .copy("Sources/NotifdexCore/hide-rules.sql"), .copy("Sources/NotifdexCore/relationship-templates.sql"),
                .copy("Sources/NotifdexCore/workspaces.sql"), .copy("templates")
            ]
        ),
        .target(name: "NotifdexMac", dependencies: ["NotifdexCore"]),
        .executableTarget(name: "NotifdexCapture", dependencies: ["NotifdexCore", "NotifdexMac"]),
        .executableTarget(name: "NotifdexApp", dependencies: ["NotifdexCore", "NotifdexMac"]),
        .testTarget(name: "NotifdexCoreTests", dependencies: ["NotifdexCore", "CSQLite"]),
        .testTarget(name: "NotifdexMacTests", dependencies: ["NotifdexMac", "NotifdexCore"])
    ]
)
