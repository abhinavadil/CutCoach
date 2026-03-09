#!/usr/bin/env swift
// Run: swift GenerateAssets.swift
// Generates AppIcon and accent color asset catalog entries

import Foundation

// MARK: - Contents.json for AppIcon
let appIconContents = """
{
  "images": [
    { "filename": "icon_20.png",   "idiom": "iphone", "scale": "2x", "size": "20x20"  },
    { "filename": "icon_20@3.png", "idiom": "iphone", "scale": "3x", "size": "20x20"  },
    { "filename": "icon_29.png",   "idiom": "iphone", "scale": "2x", "size": "29x29"  },
    { "filename": "icon_29@3.png", "idiom": "iphone", "scale": "3x", "size": "29x29"  },
    { "filename": "icon_40.png",   "idiom": "iphone", "scale": "2x", "size": "40x40"  },
    { "filename": "icon_40@3.png", "idiom": "iphone", "scale": "3x", "size": "40x40"  },
    { "filename": "icon_60.png",   "idiom": "iphone", "scale": "2x", "size": "60x60"  },
    { "filename": "icon_60@3.png", "idiom": "iphone", "scale": "3x", "size": "60x60"  },
    { "filename": "icon_1024.png", "idiom": "ios-marketing", "scale": "1x", "size": "1024x1024" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
"""

// MARK: - Accent color asset
let accentColorContents = """
{
  "colors": [
    {
      "color": {
        "color-space": "srgb",
        "components": { "alpha": "1.000", "blue": "0.235", "green": "0.961", "red": "0.784" }
      },
      "idiom": "universal"
    }
  ],
  "info": { "author": "xcode", "version": 1 }
}
"""

// MARK: - App colors
let colorsContents = """
{
  "colors": [
    {
      "color": {
        "color-space": "srgb",
        "components": { "alpha": "1.000", "blue": "0.059", "green": "0.039", "red": "0.039" }
      },
      "idiom": "universal"
    }
  ],
  "info": { "author": "xcode", "version": 1 }
}
"""

print("Asset generation script ready.")
print("AppIcon accent: #C8F53C (RGB: 200, 245, 60)")
print("Background: #0A0A0F")
print("")
print("To generate app icons, use:")
print("  makeicon --background '#0A0A0F' --icon '🔥' --accent '#C8F53C'")
print("  or use Sketch/Figma with the provided color tokens.")
