Pod::Spec.new do |s|
  s.name         = "Ashton"
  s.version      = "0.1.1"
  s.summary      = "Converts NSAttributedStrings between AppKit, CoreText, UIKit and HTML."
  s.homepage     = "https://github.com/IdeasOnCanvas/Ashton"

  s.license      = { :type => 'MIT', :file => 'MIT-LICENSE.txt' }
  s.author       = { "Martin Schuerrer" => "martin@schuerrer.org" }

  s.source       = { :git => "https://github.com/IdeasOnCanvas/Ashton.git", :tag => "v#{s.version}" }

  s.source_files = 'Ashton/*.{h,m}'
  s.ios.deployment_target = '5.0'
  s.ios.frameworks = 'CoreText'
  s.ios.exclude_files = '**/*AppKit*'

  s.osx.deployment_target = '10.7'
  s.osx.frameworks = 'CoreText'
  s.osx.exclude_files = '**/*UIKit*'

  s.requires_arc = true
end
