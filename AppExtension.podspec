#
# Be sure to run `pod lib lint AppExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppExtension'
  s.version          = '1.0'
  s.swift_version    = '4.0'
  s.summary          = 'A Candy for extension in swift'

  s.homepage         = 'https://github.com/karthikAdaptavant/AppExtension'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'karthikAdaptavant' => 'karthik.samy@a-cti.com' }
  s.source           = { :git => 'https://github.com/karthikAdaptavant/AppExtension.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/i_am_kaarthik'

  s.ios.deployment_target = '10.0'

  s.source_files = 'AppExtension/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AppExtension' => ['AppExtension/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
