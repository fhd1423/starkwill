use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use foundrycontracts::IStarkWillSafeDispatcher;
use foundrycontracts::IStarkWillSafeDispatcherTrait;
use foundrycontracts::IStarkWillDispatcher;
use foundrycontracts::IStarkWillDispatcherTrait;

#[test]
fn call_and_invoke() {
    // First declare and deploy a contract
    let contract = declare('StarkWill');
    // Alternatively we could use `deploy_syscall` here
    let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();

    // Create a Dispatcher object that will allow interacting with the deployed contract
    let _dispatcher = IStarkWillDispatcher { contract_address };

   assert(1 == 1, 'test');
}