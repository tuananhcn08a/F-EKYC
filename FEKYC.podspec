#
# Be sure to run `pod lib lint FEKYC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FEKYC'
  s.version          = '0.1.4'
  s.summary          = 'A short description of FEKYC.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/tuananhcn08a/F-EKYC'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anhdt64' => 'anhdt64@fpt.com.vn' }
  s.source           = { :http => 'https://github.com/tuananhcn08a/F-EKYC.git' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'FEKYC/**/*.{h,m,swift}'
  
  # s.resource_bundles = {
  #   'FEKYC' => ['FEKYC/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  s.dependency 'MBProgressHUD'
  s.dependency 'Alamofire'
  s.dependency 'TPKeyboardAvoiding'
  s.dependency 'HydraAsync'
  s.dependency 'IDMPhotoBrowser'
end
