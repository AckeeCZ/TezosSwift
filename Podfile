platform :ios, '10.0'

install! 'cocoapods', :disable_input_output_paths => true, :deterministic_uuids => false
inhibit_all_warnings!
use_frameworks!

target 'TezosSwift_Example' do
	pod "BigInt", "~> 3.1"
	pod "MnemonicKit", "~> 1.2.0"
	pod "Sodium", "~> 0.7.0"
	pod "Result", "~> 4.0.0"

	target "TezosSwift" do
    	inherit! :complete
	end

	target "UnitTests" do
    	inherit! :complete
	end

	target "IntegrationTests" do
    	inherit! :complete
	end
end
