Pod::Spec.new do |s|
  s.name             = "TTGEmojiRate"
  s.version          = "0.1.0"
  s.summary          = "A short description of TTGEmojiRate."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://github.com/zekunyan/TTGEmojiRate"
  s.license          = 'MIT'
  s.author           = { "zekunyan" => "zekunyan@163.com" }
  s.source           = { :git => "https://github.com/zekunyan/TTGEmojiRate.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/zorro_tutuge'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'TTGEmojiRate' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
end
