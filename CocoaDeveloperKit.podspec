#
#  Be sure to run `pod spec lint CocoaDeveloperKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name                    = "CocoaDeveloperKit"
  s.version                 = "0.0.24"
  s.summary                 = "CocoaDeveloperKit is a collection of useful classes, categories and wrappers that make iOS development easier and more efficient."
  s.description             = <<-DESC
'CocoaDeveloperKit' is a collection of useful classes, categories and wrappers that make iOS development easier and more efficient.

You will need to include the following line to your PodFile in order for this library to build correctly as it uses SQLCipher for an encrypted database.
pod 'EncryptedCoreData', :git => 'https://github.com/project-imas/encrypted-core-data.git'

                   DESC
  s.homepage                = "https://github.com/miken01/CocoaDeveloperKit"
  s.license                 = "MIT"
  s.author                  = { "Mike Neill" => "michael_neill@me.com" }
  s.platform                = :ios, "7.0"
  s.source                  = { :git => "https://github.com/miken01/CocoaDeveloperKit.git", :tag => "0.0.24" }
  s.public_header_files     = "CocoaDeveloperKit/**/*.h"
  s.source_files            = "CocoaDeveloperKit/**/*.{h,m}"
  s.requires_arc            = true
  s.ios.deployment_target   = '7.0'
  s.ios.frameworks          = 'SystemConfiguration', 'Security', 'CoreData', 'UIKit', 'Foundation'
end
