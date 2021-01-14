Gem::Specification.new do |s|
  s.name        = 'safe_sti'
  s.version     = '1.0.0'
  s.date        = '2021-01-14'
  s.summary     = "Safe STI"
  s.description = "prevent inconsistent behavior of ActiveRecord STI"
  s.authors     = ["Kenneth Law"]
  s.email       = 'cyt05108@gmail.com'
  s.files       = ["lib/safe_sti.rb"]
  s.homepage    =
    'https://github.com/Kenneth-KT/safe_sti'
  s.license       = 'MIT'
  s.add_runtime_dependency 'activerecord'
  s.add_runtime_dependency 'activesupport'
end
