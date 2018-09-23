Pod::Spec.new do |spec|
  spec.name = 'TinyStorage'
  spec.version = '0.1.0'
  spec.license = 'MIT'
  spec.summary = 'TinyStorage provides the abstraction layer for stores.'
  spec.homepage = 'https://github.com/royhsu/tiny-storage'
  spec.authors = { 'Roy Hsu' => 'roy.hsu@tinyworld.cc' }
  spec.source = { :git => 'https://github.com/royhsu/tiny-storage.git', :tag => spec.version }
  spec.framework = 'Foundation'
  spec.dependency 'TinyCore'
  spec.source_files = 'Sources/*.swift'
  spec.ios.source_files = 'Sources/iOS/*.swift'
  spec.ios.deployment_target = '10.0'
  spec.swift_version = '4.2'
end
