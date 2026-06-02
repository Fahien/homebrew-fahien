# Copyright (c) 2024-2025, Antonio Caggiano. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause

cask "vulkan-sdk" do
  name "Vulkan SDK"
  desc "The Vulkan SDK enables Vulkan developers to develop Vulkan applications"
  homepage "https://vulkan.lunarg.com/sdk/home"
  url "https://sdk.lunarg.com/sdk/download/1.4.350.0/mac/vulkansdk-macos-1.4.350.0.zip"
  sha256 "7acc181b8fd9b4781bf51ed086222ec95d22004b85b3d0a6683a7e48ca5a1679"
  version "1.4.350.0"

  depends_on formula: "python3"

  installer script: {
    executable: "vulkansdk-macOS-#{version}.app/Contents/MacOS/vulkansdk-macOS-#{version}",
    args: [
      "--root", "#{staged_path}/#{token}", "--accept-licenses", "--default-answer",
      "--confirm-command", "install", "com.lunarg.vulkan.kosmic"
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
