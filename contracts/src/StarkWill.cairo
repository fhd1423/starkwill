use starknet::{ContractAddress, ClassHash};

#[derive(Copy, Drop, Serde)]
struct Will {
        willCreator: ContractAddress,
        tokenAddress: ContractAddress,
        beneficiary: ContractAddress,
        nonce: felt252,
    }

#[starknet::interface]
trait IStarkWill<TContractState> {
    fn createWill(ref self: TContractState, tokenAddress: ContractAddress, recipient: ContractAddress);
    fn getWill(self: @TContractState, willCreator: ContractAddress) -> Will;
}

#[starknet::contract]
mod StarkWill{
    use core::box::BoxTrait;
    use contracts::StarkWill::Will;
    use starknet::{ContractAddress, ClassHash};
    use starknet::get_caller_address;
    use starknet::get_tx_info;

    #[storage]
    struct Storage {
     wills: LegacyMap::<ContractAddress, Will>, 
    }

    #[abi(embed_v0)]
    impl StarkWill of super::IStarkWill<ContractState> {
        fn createWill(ref self: ContractState, tokenAddress: ContractAddress, recipient: ContractAddress){
            let will = Will {willCreator: get_caller_address(), tokenAddress: tokenAddress, beneficiary: recipient, nonce: get_tx_info().unbox().nonce};
            self.wills.write(tokenAddress, will)
        }

        fn getWill(self: @ContractState, willCreator: ContractAddress) -> Will{
           self.wills.read(willCreator)
        }
    }
}