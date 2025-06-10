# Copyright (c) 2024-2025, Antonio Caggiano. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause

cask "vulkan-sdk" do
  name "Vulkan SDK"
  desc "The Vulkan SDK enables Vulkan developers to develop Vulkan applications"
  homepage "https://vulkan.lunarg.com/sdk/home"
  url "https://sdk.lunarg.com/sdk/download/1.4.313.1/mac/vulkansdk-macos-1.4.313.1.zip"
  sha256 "69cdbdd8dbf7fe93b40f1b653b7b3e458bf3cbe368582b56476f6a780c662aa3"
  version "1.4.313.1"

  depends_on formula: "python3"

  installer script: {
    executable: "vulkansdk-macOS-#{version}.app/Contents/MacOS/vulkansdk-macOS-#{version}",
    args: [
      "--root", "#{staged_path}/#{token}", "--accept-licenses", "--default-answer",
      "--confirm-command", "install"
    ],
  }

  installer script: {
    executable: "#{HOMEBREW_PREFIX}/bin/python3",
    args: [
      "#{staged_path}/#{token}/install_vulkan.py",
      "--install-json-location",
      "#{staged_path}/#{token}"
    ],
    sudo: true,
  }

  uninstall script: {
    executable: "#{staged_path}/#{token}/uninstall.sh",
    sudo: true,
  }

  uninstall delete: [
    "#{staged_path}/#{token}"
  ]
end

