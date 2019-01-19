Gem::Specification.new do |s|
  s.name          = 'atomsphere'
  s.version       = '0.1.11'
  s.licenses      = ['MIT']
  s.summary       = "Unofficial Ruby client for the Dell Boomi Atomsphere API"
  s.authors       = ["Warren Guy"]
  s.email         = 'warren@guy.net.au'
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.homepage      = 'https://github.com/warrenguy/atomsphere-ruby'
  s.metadata      = { "source_code_uri" => "https://github.com/warrenguy/atomsphere-ruby" }

  s.required_ruby_version = '>= 2.2'
  s.add_runtime_dependency 'rotp', '~>4'
  s.add_runtime_dependency 'facets', '~>3'
end
