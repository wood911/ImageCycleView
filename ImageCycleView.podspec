
Pod::Spec.new do |s|

  s.name         = "ImageCycleView"
  s.version      = "0.0.1"
  s.summary      = "Swift版的图片轮播轻量级框架。"
  s.homepage     = "https://github.com/woodpower/ImageCycleView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "woodwu" => "powerwtf@live.com" }
  s.social_media_url   = "https://github.com/woodpower/"
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/woodpower/ImageCycleView.git", :tag => "#{s.version}" }
  s.source_files  = "Source/*.swift"
  s.exclude_files = "Source/Exclude"
  s.frameworks = "Foundation", "UIKit"
  s.requires_arc = true
  s.dependency "Kingfisher", "~> 4.0"

end
