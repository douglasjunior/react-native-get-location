require 'json'

packageJson = JSON.parse(File.read('package.json'))
version = packageJson["version"]
repository = packageJson["repository"]["url"]

Pod::Spec.new do |s|
	s.name           = "ReactNativeGetLocation"
	s.version        = version
	s.description    = packageJson["description"]
	s.homepage       = packageJson["homepage"]
	s.summary        = "Simple to use React Native library to get device location"
	s.license        = packageJson["license"]
	s.authors        = packageJson["author"]["name"]
	s.source         = { :git => repository, :tag => version }
	s.platform       = :ios, "9.0"
	s.preserve_paths = 'README.md', 'package.json', '*.js'
	s.source_files   = 'ios/ReactNativeGetLocationLibrary/**/*.{h,m}'

	s.dependency 'React'
end
