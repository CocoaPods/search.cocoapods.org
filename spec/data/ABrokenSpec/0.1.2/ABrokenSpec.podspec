Pod::Spec.new do |s|
  s.namee    = 'ABrokenSpec' # Typo
  s.version  = '.1' # Wrong
  s.sumary   = 'Typo! This spec is broken, for test purposes'
  s.homepage = 'https://cocoapods.org'
  s.author   = { 'Break McFailure' => nil }
  s.source   = {} # Missing
end
