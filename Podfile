platform :ios, '10.0'

install! 'cocoapods'
inhibit_all_warnings!
use_frameworks!

target 'TezosSwift_Example' do
	pod "MnemonicKit", "~> 1.2.0"

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
