#
# Be sure to run `pod lib lint Modal.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Modal'
  s.version          = '1.0.0'
  s.summary          = 'Create custom modals for iOS without worrying worrying displaying, positioning, sizing, and screen orientation.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Create custom modals for iOS without worrying worrying displaying, positioning, sizing, and screen orientation. You can provide a fixed size for each modal, or use relative sizing. Compatible with iPhone and iPad apps.
                       DESC

  s.homepage         = 'https://github.com/amirshayegh/Modal'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'amirshayegh' => 'shayegh@me.com' }
  s.source           = { :git => 'https://github.com/amirshayegh/Modal.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Modal/Classes/**/*.{swift}'

  s.resource_bundles = {
  #   'Modal' => ['Modal/Assets/*.png']
      'Modal' => ['Modal/Classes/**/*.{storyboard,xib}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
