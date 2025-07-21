Pod::Spec.new do |s|
  s.name = 'gr4vy-swift'
  s.version = File.read('gr4vy-swift/Version.swift').match(/static let current = "(.+)"/)[1]
  s.license = 'MIT'
  s.summary = 'Gr4vy for your iOS app'
  s.homepage = 'https://github.com/gr4vy/gr4vy-swift'
  s.authors = { 'Gr4vy' => 'mobile@gr4vy.com' }
  s.source = { :git => 'https://github.com/gr4vy/gr4vy-swift.git', :tag => s.version }
  s.documentation_url = 'https://docs.gr4vy.com'

  # Platform and version requirements
  s.ios.deployment_target = '16.0'
  s.swift_versions = ['5.7', '5.8', '5.9']
  s.source_files = 'gr4vy-swift/**/*.swift'
  
  # Build settings
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '5.7',
    'IPHONEOS_DEPLOYMENT_TARGET' => '16.0',
    'ENABLE_BITCODE' => 'NO'
  }
  
  # Frameworks
  s.frameworks = 'Foundation'
end