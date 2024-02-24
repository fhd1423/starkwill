use starknet::{ContractAddress, ClassHash};

#[derive(Copy, Drop)]
struct Will {
        willCreator: ContractAddress,
        tokenAddress: ContractAddress,
        beneficiary: ContractAddress,
        nonce: u256,
    }

#[starknet::interface]
trait IStarkWill<TContractState> {
    fn createWill(ref self: TContractState, tokenAddress: ContractAddress, recipient: ContractAddress);
    fn getWill(self: @TContractState, willCreator: ContractAddress) -> Will;
}

#[starknet::contract]
mod StarkWill{
    use contracts::StarkWill::Will;
    use starknet::{ContractAddress, ClassHash};


    #[storage]
    struct Storage {
     wills: LegacyMap::<ContractAddress, Will>, 
    }

    #[abi(embed_v0)]
    impl StarkWill of super::IStarkWill<ContractState> {
        fn createWill(ref self: ContractState, tokenAddress: ContractAddress, recipient: ContractAddress){
            let will = Will {willCreator: tokenAddress, tokenAddress: tokenAddress, beneficiary: recipient, nonce: 1};
            self.wills.write(tokenAddress, will)
        }

        fn getWill(self: @ContractState, willCreator: ContractAddress){
            self.wills.read(willCreator);
        }
    }
}