# for  in {0..9}
# do
#     ./output < tests/${x}_in.txt > tests/${x}_out.txt ; diff --strip-trailing-cr tests/${x}_out_win.txt tests/${x}_out.txt ; echo ${x}
# done

# tezosgen generate PairMapBoolContract Example/Contracts/pair_map_bool.json -x TezosSwift.xcodeproj -o Example/GeneratedContracts -t TezosSwift_Example
# tezosgen generate NatSetContract Example/Contracts/nat_set_abi.json -x TezosSwift.xcodeproj -o Example/GeneratedContracts -t TezosSwift_Example
# tezosgen generate PackUnpackContract Example/Contracts/packunpack_abi.json -x TezosSwift.xcodeproj -o Example/GeneratedContracts -t TezosSwift_Example
# tezosgen generate NatSetContract Example/Contracts/nat_set_abi.json -x TezosSwift.xcodeproj -o Example/GeneratedContracts -t TezosSwift_Example

for i in "UnitPairContract unit_pair_abi.json" "OptionalPairBoolContract optional_pair_bool_abi.json" "PackUnpackContract packunpack_abi.json" "NatSetContract nat_set_abi.json" "IntListContract int_list_abi.json" "TimestampContract timestamp_abi.json" "OrSwapContract or_swap_abi.json" "StringSetContract string_set_abi.json" "TestContract int_abi.json" "KeyContract key_abi.json" "BytesContract bytes_abi.json" "MutezContract mutez_abi.json" "StringOptionalContract string_optional_abi.json" "SetMemberContract set_member_abi.json" "MapContract map_abi.json" "NatContract nat_abi.json" "ParameterPairContract parameter_pair_abi.json" "KeyHashContract key_hash_abi.json" "PairMapBoolContract pair_map_bool.json" "PairContract pair_abi.json" "AddressContract address_abi.json RateContract rate_contract_abi.json"
do
    set -- $i
    echo "Generating $1 with $2"
    tezosgen generate $1 Example/Contracts/$2 -x TezosSwift.xcodeproj -o Example/GeneratedContracts -t TezosSwift_Example
done