Pod::Spec.new do |s|
  s.name         = 'SlidePay'
  s.version      = '0.2.2'
  s.summary      = 'A library for processing credit cards'
  s.homepage     = 'https://github.com/SlidePay/SlidePay_iOS.git'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.requires_arc = true
  s.ios.deployment_target = '6.0'
  s.author = {
    'SlidePay' => 'api@slidepay.com',
    'Alex Garcia' => 'alex@slidepay.com'
  }
  s.source = {
    :git => 'https://github.com/SlidePay/SlidePay_iOS.git',
    :tag => '0.2.2'
  }
  s.source_files = '*.h', 'SlidePayCore/*.h'
  s.dependency     'RestKit'
  
end
