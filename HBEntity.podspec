#
# Be sure to run `pod lib lint HBEntity.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HBEntity"
  s.version          = "0.2.0"
  s.summary          = "This is a tool transfer NSArray and NSDictionary object to your custom entity,using runtime"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  							This is a tool transfer NSArray and NSDictionary object to your custom entity/model,using runtime.
  							we don't have to declair which properties in entity/model are belongs to whitelist and blacklist,
  							we also made an adpter to meet the desire that custom entity/model's property name  is not the same to original keys.
                       DESC

  s.homepage         = "https://github.com/knighthb/HBEntity"
  s.license          = 'MIT'
  s.author           = { "knight" => "huangbin911@gmail.com" }
  s.source           = { :git => "https://github.com/knighthb/HBEntity.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'HBEntity' => ['Pod/Assets/*.png']
  }

end
