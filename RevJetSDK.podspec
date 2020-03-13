Pod::Spec.new do |s|
  s.name             = 'RevJetSDK'
  s.version          = '1.13.1'
  s.summary          = 'RevJet advertising SDK for iOS.'

  s.description      = <<-DESC
  RevJet is the first comprehensive Ad Experience Platform, for every audience, channel, format, inventory, and device.
                       DESC

  s.homepage         = 'https://github.com/RevJet/revjet-sdk-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'RevJet' => 'support@revjet.com' }
  s.source           = { :git => 'https://github.com/RevJet/revjet-sdk-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/gorevjet'

  s.ios.deployment_target = '11.0'

  s.source_files   = 'RevJetSDK/Classes/**/*'
  s.requires_arc   = true
  #s.compiler_flags = '-Wno-deprecated-declarations -Wno-deprecated-implementations'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'AdSupport', 'CoreGraphics', 'CoreTelephony', 'EventKit', 'EventKitUI', 'Foundation', 'ImageIO', 'MediaPlayer', 'StoreKit', 'SystemConfiguration', 'UIKit'
end
