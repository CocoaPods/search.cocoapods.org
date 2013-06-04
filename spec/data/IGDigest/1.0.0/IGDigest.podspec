Pod::Spec.new do |s|
  s.name     = 'IGDigest'
  s.version  = '1.0.0'
  s.summary  = 'Provides convenient wrappers for popular message digest formats (MD5, SHA1 and SHA256).'

  s.homepage = 'https://github.com/siuying/IGDigest'
  s.author   = { 'Francis Chong' => 'francis@ignition.hk' }
  s.license  = 'MIT'
  s.source   = { :git => 'https://github.com/siuying/IGDigest.git', :tag => '1.0.0' }

  s.requires_arc = true
  s.platform = :ios, '5.0'
  s.source_files = 'IGDigest/Digest/*.{m,h}'
end