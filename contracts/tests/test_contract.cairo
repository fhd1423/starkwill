use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use contracts::Will;
use contracts::IStarkWill;
use contracts::StarkWill;


fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::new()).unwrap()
}
