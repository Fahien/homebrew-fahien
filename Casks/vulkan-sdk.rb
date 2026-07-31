# Copyright (c) 2024-2025, Antonio Caggiano. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause

cask "vulkan-sdk" do
  name "Vulkan SDK"
  desc "The Vulkan SDK enables Vulkan developers to develop Vulkan applications"
  homepage "https://vulkan.lunarg.com/sdk/home"
  url "https://sdk.lunarg.com/sdk/download/1.4.357.0/mac/vulkansdk-macos-1.4.357.0.zip"
  sha256 "539433589c83522e6f31b1c7b418a4167e21597a4a361ab119e1dc0760cf3865"
  version "1.4.357.0"

  livecheck do
    url "https://vulkan.lunarg.com/sdk/latest/mac.json"
    strategy :json do |json|
      json["mac"]
    end
  end

  depends_on :macos
  depends_on formula: "python3"

  installer script: {
    executable: "#{HOMEBREW_PREFIX}/bin/python3",
    args: [
      "#{staged_path}/#{token}/install_vulkan.py",
      "--install-json-location",
      "#{staged_path}/#{token}"
    ],
    sudo: true,
  }

  # Runs before the `installer` stanza above: picks the optional SDK components
  # and runs the LunarG installer with them. The core SDK is always installed.
  preflight do
    optional_components = {
      "kosmic" => ["com.lunarg.vulkan.kosmic", "KosmicKrisp (Vulkan on Metal)"],
      "ios"    => ["com.lunarg.vulkan.ios", "Development libraries for iOS"],
      "sdl2"   => ["com.lunarg.vulkan.sdl2", "SDL libraries and headers"],
      "glm"    => ["com.lunarg.vulkan.glm", "GLM headers"],
      "volk"   => ["com.lunarg.vulkan.volk", "Volk header, source, and library"],
      "vma"    => ["com.lunarg.vulkan.vma", "Vulkan Memory Allocator header"],
    }
    default_components = ["kosmic"]

    answer = ENV.fetch("HOMEBREW_VULKAN_SDK_COMPONENTS", nil)

    if answer.nil? && $stdin.tty?
      ohai "Optional Vulkan SDK components"
      optional_components.each { |key, (_, description)| puts "  #{key.ljust(6)} #{description}" }
      puts "  all    Everything above"
      puts "  none   Core SDK only"
      puts "Set HOMEBREW_VULKAN_SDK_COMPONENTS to skip this question."
      print "Components to install [#{default_components.join(" ")}]: "
      answer = $stdin.gets&.chomp
    end

    selected = case answer&.strip
    when nil, "" then default_components
    when "all" then optional_components.keys
    when "none" then []
    else answer.strip.split(/[\s,]+/)
    end

    unknown = selected - optional_components.keys
    odie "Unknown #{token} component(s): #{unknown.join(", ")}" if unknown.any?

    ohai "Installing Vulkan SDK: #{(["core"] + selected).join(", ")}"

    executable = staged_path/"vulkansdk-macOS-#{version}.app/Contents/MacOS/vulkansdk-macOS-#{version}"
    FileUtils.chmod "+x", executable unless executable.executable?

    system_command executable,
                   args:         [
                     "--root", "#{staged_path}/#{token}", "--accept-licenses", "--default-answer",
                     "--confirm-command", "install",
                     *selected.map { |key| optional_components.fetch(key).first }
                   ],
                   print_stdout: true,
                   reset_uid:    true
  end

  uninstall script: {
    executable: "#{staged_path}/#{token}/uninstall.sh",
    sudo: true,
  }

  uninstall delete: [
    "#{staged_path}/#{token}"
  ]

  caveats do
    license "https://vulkan.lunarg.com/license/"
  end
end
