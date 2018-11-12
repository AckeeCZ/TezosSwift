use_modular_headers!
use_frameworks!
target 'TezosSwift' do
	pod "MnemonicKit", :git => 'https://github.com/keefertaylor/MnemonicKit' 
	pod "Result"
	pod "Sodium"
	pod "SipHash"
	pod "BigInt"

	target "UnitTests" do
    	inherit! :search_paths
	end

	target "IntegrationTests" do
    	inherit! :search_paths
	end
end
