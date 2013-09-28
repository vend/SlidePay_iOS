Pod::Spec.new do |s|
  s.name         = 'SlidePay'
  s.version      = '0.2.0'
  s.summary      = 'A library for processing credit cards'
  s.homepage     = 'https://github.com/cubebright/SlidePay_iOS'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
  s.author = {
    'SlidePay' => 'api@slidepay.com',
    'Alex Garcia' => 'alex@slidepay.com'
  }
  s.source = {
    :git => 'https://github.com/cubebright/SlidePay_iOS.git',
    :tag => '0.2.0'
  }
  s.header_dir   = 'SlidePay'
  s.source_files = '*.{h,m}','SlidePayCore/*.{h,m}'
  s.dependency     'RestKit'
end