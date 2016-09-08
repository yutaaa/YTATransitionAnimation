Pod::Spec.new do |s|
  s.name         = "YTATransitionAnimation"
  s.version      = "0.0.1"
  s.summary      = "Simple slide & zoom transition"
  s.homepage     = "https://github.com/yutaaa/YTATransitionAnimation"
  s.license      = "MIT"
  s.author       = { "Yuta Takahashi" => "takahashiyuta1011@gmail.com" }
  s.source       = { :git => "https://github.com/yutaaa/YTATransitionAnimation.git", :tag => "#{s.version}" }
  s.source_files = 'YTATransitionAnimation'
  s.requires_arc = true
  s.frameworks = "Foundation", "UIKit"
  s.ios.deployment_target = '7.0'
end
