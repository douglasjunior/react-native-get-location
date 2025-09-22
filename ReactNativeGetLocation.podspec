require 'json'

packageJson = JSON.parse(File.read('package.json'))
version = packageJson["version"]
repository = packageJson["repository"]["url"]
turbo_enabled = ENV['RCT_NEW_ARCH_ENABLED'] == '1'

Pod::Spec.new do |s|
	s.name           = "ReactNativeGetLocation"
	s.version        = version
	s.description    = packageJson["description"]
	s.homepage       = packageJson["homepage"]
	s.summary        = packageJson["description"]
	s.license        = packageJson["license"]
	s.authors        = packageJson["author"]
	s.source         = { :git => repository, :tag => version }
	s.platform       = :ios, "14.0"
	s.preserve_paths = 'README.md', 'package.json', '*.js'
	s.source_files   = 'ios/ReactNativeGetLocationLibrary/**/*.{h,m,mm,swift}'

	if turbo_enabled
		install_modules_dependencies(s)
	else
		s.dependency "React-Core"
	end
end
