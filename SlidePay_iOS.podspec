Pod::Spec.new do |s|
  s.name         = "SlidePay_iOS"
  s.version      = "0.2.3"
  s.summary      = "Core SDK for SlidePay"
  s.homepage     = "https://github.com/SlidePay/SlidePay_iOS"
  s.license      = 'LICENSE'
  s.authors      = { "SlidePay" => "api@slidepay.com", "Alex Garcia" => "alex@slidepay.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/SlidePay/SlidePay_iOS.git", :tag => "0.2.3" }
  s.source_files = 'SlidePayCore/','*.h','*.m'
  s.requires_arc = true
  s.dependency 'RestKit', '~>0.20.0'
  s.ios.frameworks = 'CFNetwork', 'Security', 'MobileCoreServices', 'SystemConfiguration'
end
