use starknet::{ContractAddress, ClassHash};


#[derive(Copy, Drop, Serde, starknet::Store)]
struct Will {
        willCreator: ContractAddress,
        tokenAddress: ContractAddress,
        beneficiary: ContractAddress,
        nonce: felt252,
        timestamp: u64,
    }

#[starknet::interface]
pub trait IStarkWill<TContractState> {
    fn createWill(ref self: TContractState, tokenAddress: ContractAddress, recipient: ContractAddress, duration: u64);
    fn getWill(self: @TContractState, willCreator: ContractAddress) -> Will;
    fn disperseFunds(self: @TContractState, willCreator: ContractAddress);
}

#[starknet::contract]
mod StarkWill{
    use foundrycontracts::Will;
    use starknet::{ContractAddress, ClassHash};
    use starknet::get_caller_address;
    use starknet::get_tx_info;
    use starknet::get_block_info;
    use starknet::get_execution_info;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};

    #[storage]
    struct Storage {
     wills: LegacyMap::<ContractAddress, Will>
    }

    #[abi(embed_v0)]
    impl StarkWill of super::IStarkWill<ContractState> {
        fn createWill(ref self: ContractState, tokenAddress: ContractAddress, recipient: ContractAddress, duration: u64){
            let token = (IERC20Dispatcher { contract_address: tokenAddress });
            let caller = get_caller_address();

            let will = Will {willCreator: caller, tokenAddress: tokenAddress, beneficiary: recipient, nonce: get_tx_info().unbox().nonce, timestamp: get_block_info().unbox().block_timestamp + duration};
            token.approve(get_execution_info().unbox().contract_address, token.balance_of(caller));
            self.wills.write(tokenAddress, will);
        }

        fn getWill(self: @ContractState, willCreator: ContractAddress) -> Will{
           self.wills.read(willCreator)
        }

        fn disperseFunds(self: @ContractState, willCreator: ContractAddress) {
            let will = self.getWill(willCreator);
            let token = (IERC20Dispatcher { contract_address: will.tokenAddress });
            if (get_block_info().unbox().block_timestamp > will.timestamp){
                // integrate storage proofs here
                token.transfer_from(willCreator, will.beneficiary, token.balance_of(willCreator));
            }
        }
    }
}