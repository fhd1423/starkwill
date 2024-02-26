use starknet::{ContractAddress, ClassHash};
use foundrycontracts::internal::herodotus::{ IBlockHeadersDispatcher, Peaks, Proof, Words64};

#[derive(Copy, Drop, Debug, Serde, PartialEq, starknet::Store)]
pub struct BetPool {
        pub tokenAddress: ContractAddress,
        pub blockNumber: u256,
        pub winningPot: u256,
        pub betCount: u256,
    }

#[starknet::interface]
pub trait IStarkBet<TContractState> {
    fn createBettingPool(ref self: TContractState, tokenAddress: ContractAddress, blockNumber: u256);
    fn placeBet(ref self: TContractState, tokenAddress: ContractAddress, blockNumber: u256, amount: u256, target: u64);
    fn getBettingPool(self: @TContractState, blockNumber: u256) -> BetPool;
    fn set_headerstore_address(ref self: TContractState, address: ContractAddress);
    fn disperseFunds(self: @TContractState, blockNumber: u256, index: usize,
        block_header: Words64,
        peaks: Peaks,
        proof: Proof,
        mmr_id: usize);
}

#[starknet::contract]
mod StarkBet{
    use foundrycontracts::internal::strkbet::BetPool;
    use starknet::{ContractAddress, ClassHash};
    use starknet::get_caller_address;
    use starknet::get_tx_info;
    use starknet::get_block_info;
    use starknet::get_execution_info;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use foundrycontracts::internal::herodotus::{IBlockHeadersDispatcher, IBlockHeadersDispatcherTrait, Peaks, Proof, Words64};
    use cairo_lib::hashing::poseidon::hash_words64;
    use cairo_lib::encoding::rlp::{RLPItem, rlp_decode_list_lazy};
    use cairo_lib::utils::types::words64::{reverse_endianness_u64, bytes_used_u64};


    #[storage]
    struct Storage {
     betPools: LegacyMap::<u256, BetPool>, // block => bet
     betsPlaced: LegacyMap::<(u256, u256), u64>, // block + user index => bet amount
     userToIndex: LegacyMap::<(u256, ContractAddress), u256>, // block + user address => user index
     IndexToUser: LegacyMap::<(u256, u256), ContractAddress>, // user index + block number =>  user address
     headerstore_address: ContractAddress,
    }

    #[abi(embed_v0)]
    impl StarkBet of super::IStarkBet<ContractState> {

        fn set_headerstore_address(ref self: ContractState, address: ContractAddress){
            self.headerstore_address.write(address);
        }
        fn createBettingPool(ref self: ContractState, tokenAddress: ContractAddress, blockNumber: u256){
            let betPool = BetPool {tokenAddress: tokenAddress, blockNumber: blockNumber, winningPot: 0, betCount: 0 };
            self.betPools.write(blockNumber, betPool);
        }

        fn getBettingPool(self: @ContractState, blockNumber: u256) -> BetPool{
           self.betPools.read(blockNumber)
        }

        fn placeBet(ref self: ContractState, tokenAddress: ContractAddress, blockNumber: u256, amount: u256, target: u64){
            let token = (IERC20Dispatcher { contract_address: tokenAddress });
            let caller = get_caller_address();
            let contract_address = get_execution_info().unbox().contract_address;

            let mut currentBettingPool = self.getBettingPool(blockNumber);

            // retrieve current bet index
            let currentIndex = currentBettingPool.betCount;

            // map current bet index to new user
            self.userToIndex.write((blockNumber, caller), currentIndex);
            self.IndexToUser.write((currentIndex, blockNumber), caller);

            // add bet to betsPlaced
            self.betsPlaced.write((blockNumber, currentIndex), target);
            
            // increment betting pool user count
            currentBettingPool.betCount = currentIndex +1;
            self.betPools.write(blockNumber, currentBettingPool);
            
            // send money to contract
            // token.approve(contract_address, amount);
            token.transfer_from(caller, contract_address, amount);
        }

        fn disperseFunds(self: @ContractState, blockNumber: u256,
        index: usize,
        block_header: Words64,
        peaks: Peaks,
        proof: Proof,
        mmr_id: usize){
            let bettingPool = self.getBettingPool(blockNumber);
            let totalBetsForPool = bettingPool.betCount;
            let token = (IERC20Dispatcher { contract_address: bettingPool.tokenAddress });

            let mut userIndex: u256 = 0;
            let mut winnerAddress: ContractAddress = self.IndexToUser.read((userIndex, blockNumber));

            let poseidon_hash: felt252 = hash_words64(block_header);

            let l1_blockheaders_dispatcher = IBlockHeadersDispatcher {
                contract_address: self.headerstore_address.read()
            };

            let is_blockheader_valid = l1_blockheaders_dispatcher.verify_mmr_inclusion(index, poseidon_hash, peaks, proof, mmr_id);
            assert(is_blockheader_valid, 'blockheader not valid');

            let (decoded_rlp, _) = rlp_decode_list_lazy(
                block_header,
                array![15, 15].span()
            )
                .unwrap();

            let ((base_gasfee_le, base_gasfee_le_len), (base_gasfeee, base_gasfeee_len)) =
                match decoded_rlp {
                RLPItem::Bytes(_) => panic!("Invalid header rlp"),
                RLPItem::List(l) => {
                    (*l.at(0), *l.at(1))
                },
            };
            let basegas_fee: u64 =
                reverse_endianness_u64(*base_gasfee_le.at(0), Option::Some(base_gasfee_le_len)).into();
        
            loop {
                if userIndex >= totalBetsForPool {
                break;
            }
                if(self.betsPlaced.read((blockNumber, userIndex)) == basegas_fee){
                    winnerAddress = self.IndexToUser.read((userIndex, blockNumber));
                }
                userIndex+=1;
            };

            token.transfer(winnerAddress, bettingPool.winningPot);
        }
    }
}