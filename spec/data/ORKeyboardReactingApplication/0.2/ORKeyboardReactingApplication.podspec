Pod::Spec.new do |s|
  s.name         = "ORKeyboardReactingApplication"
  s.version      = "0.2"
  s.summary      = "Use Keyboard Bindings with the iOS Simulator."
  s.description  = "Provides a great API to block based keyboard actions."
  s.homepage     = "https://github.com/orta/ORKeyboardReactingApplication"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "orta" => 'orta.therox@gmail.com' }
  s.source       = { :git => "https://github.com/orta/ORSimulatorKeyboardAccessor.git", :tag => "0.2"}
  s.platform     = :ios, '5.0'
  s.source_files = 'ORKeyboardReactingApplication.{h,m}'
  s.requires_arc = true
end