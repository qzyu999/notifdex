import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
APP_SOURCES = ROOT / "Sources" / "NotifdexApp"


class MacOSBuildContractTests(unittest.TestCase):
    def test_package_excludes_built_apps(self):
        manifest = (ROOT / "Package.swift").read_text(encoding="utf-8")
        excludes = re.search(r"exclude:\s*\[(.*?)\]", manifest, re.DOTALL)
        self.assertIsNotNone(excludes)
        self.assertIn('"dist"', excludes[1])
        self.assertTrue((ROOT / "dist" / ".gitignore").is_file())

    def test_app_avoids_swiftui_state_macro(self):
        # The macOS 27 standalone Command Line Tools build failed when @State
        # needed a SwiftUI macro plugin that was absent on that toolchain.
        state_attribute = re.compile(r"^\s*@(?:SwiftUI\.)?State\b", re.MULTILINE)
        violations = []
        for source in sorted(APP_SOURCES.rglob("*.swift")):
            text = source.read_text(encoding="utf-8")
            for match in state_attribute.finditer(text):
                line = text.count("\n", 0, match.end()) + 1
                violations.append(f"{source.relative_to(APP_SOURCES)}:{line}")
        self.assertEqual(violations, [], "Use observable model state in the macOS app.")
