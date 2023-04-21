#
# Be sure to run `pod lib lint WZCardSlide.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WZCardSlide'
  s.version          = '2.1.6'
  s.summary          = 'A short description of WZCardSlide.卡片滑动'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/WZLYiOS/WZCardSlide'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qiuqixiang' => '739140860@qq.com' }
  s.source           = { :git => 'https://github.com/WZLYiOS/WZCardSlide.git', :tag => s.version.to_s }
  

  s.ios.deployment_target = '10.0'
  s.swift_version         = '5.0'
  s.requires_arc = true
  s.static_framework = true
  s.source_files = "WZCardSlide/Classes/**/*.{h,swift}"
end
