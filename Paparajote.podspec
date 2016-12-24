Pod::Spec.new do |s|
  s.name             = 'Paparajote'
  s.version          = '1.0.3'
  s.summary          = 'OAuth2 handler written in Swift'
  s.homepage         = 'https://github.com/carambalabs/Paparajote'
  s.social_media_url = "https://twitter.com/carambalabs"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pedro Piñera' => 'pepibumur@gmail.com', 'Sergi Gracia' => 'sergigram@gmail.com', 'Isaac Roldán' => "isaac.roldan@gmail.com" }
  s.source           = { :git => 'https://github.com/carambalabs/Paparajote.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Paparajote/Classes/**/*'

  s.dependency 'NSURL+QueryDictionary', '~> 1.2'
end
