Pod::Spec.new do |s|
  s.name         = "TezosSwift"
  s.version      = "0.0.1"
  s.summary      = "TezosSwift provides a Swift based toolchain for interacting with the Tezos blockchain"
  s.description  = <<-DESC
  TezosSwift provides utilities for interacting with the Tezos Blockchain over an RPC API.
                   DESC

  s.homepage      = "https://github.com/AckeeCZ/TezosSwift"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { 'Ackee' => 'info@ackee.cz' }
  s.source        = { :git => "https://github.com/AckeeCZ/TezosSwift.git", :tag => "0.0.1" }
  s.source_files  = "TezosSwift/**/*"
  s.swift_version = "4.2"
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"

  s.dependency "BigInt", "~> 3.1"		
  s.dependency "MnemonicKit"
  s.dependency "Sodium", "~> 0.7.0"  
  s.dependency "Result", "~> 4.0.0" 
  
  s.test_spec "Tests" do |test_spec|
    test_spec.source_files = "TezosSwiftTests/*.swift"
  end    
end
