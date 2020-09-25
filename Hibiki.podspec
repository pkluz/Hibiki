Pod::Spec.new do |s|
  s.name         = "Hibiki"
  s.version      = "0.2.0"
  s.summary      = "An image viewer browser based on KSPhotoBrowser supporting infinite scroll."
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Kyle Sun" => "skx926@gmail.com", "Philip Kluz" => "philip.kluz@gmail.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/pkluz/Hibiki.git", :tag => "#{s.version}" }
  s.source_files = "Hibiki", "Hibiki/**/*.{h,m}"
  s.homepage     = "https://www.github.com/pkluz/Hibiki"
  s.framework    = "UIKit"
  s.dependency "SDWebImage", "~> 5.9.1"
end
