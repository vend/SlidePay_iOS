Pod::Spec.new do |s|
  s.name         = 'SlidePay'
  s.version      = '0.2.0'
  s.summary      = 'A library for processing credit cards'
  s.homepage     = 'https://github.com/cubebright/SlidePay_iOS'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author = {
    'SlidePay' => 'api@slidepay.com'
    'Alex Garcia' => 'alex@slidepay.com'
  }
  s.source = {
    :git => 'git@github.com:cubebright/SlidePay_iOS.git',
    :tag => '0.2.0'
  }
  s.platform     = :ios, '5.0'
  s.source_files = '*.{h,m}'
  s.dependency     'RestKit'
end