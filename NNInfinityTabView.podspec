Pod::Spec.new do |s|
  s.name         = "NNInfinityTabView"
  s.version      = "0.0.1"
  s.summary      = "NNInfinityTabView"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Naoto Horiguchi" => "naoto.horiguchi@gmail.com" }
  s.social_media_url = "http://twitter.com/naonya3"
  s.platform     = :ios, '5.0'
  s.source       = { :git => "https://github.com/naonya3/NNInfinityTabView.git", :branch => "master" }
  s.source_files  = 'Classes', 'Classes/**/*.{h,m}'
  s.requires_arc = true
end
