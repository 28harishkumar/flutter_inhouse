Pod::Spec.new do |s|
  s.name             = 'flutter_inhouse'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for TryInhouse tracking SDK.'
  s.description      = <<-DESC
A Flutter plugin for tracking app installs, sessions, and user interactions with shortlinks and deep links using the TryInhouse SDK.
                       DESC
  s.homepage         = 'https://github.com/28harishkumar/flutter-inhouse-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TryInhouse' => 'support@tryinhouse.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'InhouseTrackingSDK', '~> 1.0.6'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end 