Pod::Spec.new do |s|
  s.name             = "TTGEmojiRate"
  s.module_name      = "TTGEmojiRate"
  s.version          = "0.1.1"
  s.summary          = "An emoji-based rating view for iOS, implemented in Swift."

  s.description      = <<-DESC
                        TTGEmojiRate is an emoji-based rating view for iOS which is implemented in Swift.
                        You can drop up and down on the Emoji face to change the rate with the color changing, which is more interactive.
                        TTGEmojiRate is also highly customizable that many features of it can be configure, like the emoji line width and the mouth width.
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
