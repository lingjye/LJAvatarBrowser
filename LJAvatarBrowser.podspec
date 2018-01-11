Pod::Spec.new do |s|
  s.name         = "LJAvatarBrowser"
  s.version      = "1.1.1"
  s.summary      = "A lightweight picture viewer"
  s.homepage     = "https://github.com/iBoCoding/LJAvatarBrowser"
  s.license      = "MIT"
  s.author       = { "iBo Wong" => "825238111@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/iBoCoding/LJAvatarBrowser.git", :tag => s.version.to_s }
  s.source_files = "LJAvatarBrowser/*.{h,m}"
  s.requires_arc = true
  s.dependency "SDWebImage"
end
