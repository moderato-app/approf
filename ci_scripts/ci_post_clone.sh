#!/bin/bash

#defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

mkdir -p ~/Library/org.swift.swiftpm/security/
cp macros.json ~/Library/org.swift.swiftpm/security/
