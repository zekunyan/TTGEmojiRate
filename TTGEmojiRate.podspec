Pod::Spec.new do |s|
  s.name             = "TTGEmojiRate"
  s.module_name      = "TTGEmojiRate"
  s.version          = "1.0.0"
  s.summary          = "An expressive emoji rating view for iOS."

  s.description      = <<-DESC
                        TTGEmojiRate is an expressive emoji rating view for iOS.
                        It turns direct emoji interaction into continuous or stepped rating input,
                        with configurable ranges, face shapes, expression presets, fills, gradients,
                        custom drawing paths, read-only display, and Swift/Objective-C examples.
                       DESC

  s.homepage         = "https://github.com/zekunyan/TTGEmojiRate"
  s.license          = 'MIT'
  s.author           = { "zekunyan" => "zekunyan@163.com" }
  s.source           = { :git => "https://github.com/zekunyan/TTGEmojiRate.git", :tag => s.version.to_s }
  s.social_media_url = 'http://tutuge.me'

  s.platform         = :ios, '16.0'
  s.swift_version    = "5.9"
  s.requires_arc     = true

  s.source_files = 'Pod/Classes/**/*.{swift,h}'
  s.public_header_files = 'Pod/Classes/**/*.h'
end
