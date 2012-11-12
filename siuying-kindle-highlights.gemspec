Gem::Specification.new do |s|
  s.name        = 'siuying-kindle-highlights'
  s.version     = '0.0.7'
  s.summary     = "Kindle highlights"
  s.description = "Until there is a Kindle API, this will suffice."
  s.authors     = ["Eric Farkas", "Francis Chong"]
  s.email       = ["eric@prudentiadigital.com", "francis@ignition.hk"]
  s.files       = ["lib/kindle-highlights.rb"]
  s.homepage    = 'https://github.com/siuying/kindle-highlights'
 
  s.add_runtime_dependency 'mechanize', '>= 2.0.1'
  s.add_runtime_dependency 'asin', '>= 1.0.0'
end