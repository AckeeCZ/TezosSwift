Pod::Spec.new do |s|
  s.name         = "TezosSwift"
  s.version      = "1.0"
  s.summary      = "TezosSwift provides a Swift based toolchain for interacting with the Tezos blockchain"
  s.description  = <<-DESC
  TezosSwift provides utilities for interacting with the Tezos Blockchain over an RPC API.
                   DESC

  s.homepage      = "https://github.com/AckeeCZ/TezosSwift"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { 'Ackee' => 'info@ackee.cz' }
  s.source        = { :git => "https://github.com/AckeeCZ/TezosSwift.git", :tag => s.version.to_s }
  s.swift_version = "5.1"
  s.ios.deployment_target = "13.0"

  s.dependency "BigInt", "~> 5.0.0"		
  s.dependency "MnemonicKit"
  s.dependency "Sodium", "~> 0.8.0"  
  
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files  = "TezosSwift/Core/**/*"
    core.exclude_files = "TezosSwift/Core/*.plist"
  end

  s.subspec 'Combine' do |combine|
    combine.dependency 'TezosSwift/Core'
    combine.source_files = 'TezosSwift/Combine/**/*'
    combine.exclude_files = "TezosSwift/Combine/*.plist"
  end
end
