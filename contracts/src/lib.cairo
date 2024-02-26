use starknet::{ContractAddress, ClassHash};


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
    fn placeBet(ref self: TContractState, tokenAddress: ContractAddress, blockNumber: u256, amount: u256, target: u256);
    fn getBettingPool(self: @TContractState, blockNumber: u256) -> BetPool;
    fn disperseFunds(self: @TContractState, blockNumber: u256);
}


#[starknet::contract]
mod StarkBet{
    use foundrycontracts::BetPool;
    use starknet::{ContractAddress, ClassHash};
    use starknet::get_caller_address;
    use starknet::get_tx_info;
    use starknet::get_block_info;
    use starknet::get_execution_info;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};

    #[storage]
    struct Storage {
     betPools: LegacyMap::<u256, BetPool>, // block => bet
     betsPlaced: LegacyMap::<(u256, u256), u256>, // block + user index => bet amount
     userToIndex: LegacyMap::<(u256, ContractAddress), u256>, // block + user address => user index
     IndexToUser: LegacyMap::<(u256, u256), ContractAddress>, // user index + block number =>  user address
    }

    #[abi(embed_v0)]
    impl StarkBet of super::IStarkBet<ContractState> {
        fn createBettingPool(ref self: ContractState, tokenAddress: ContractAddress, blockNumber: u256){
            let betPool = BetPool {tokenAddress: tokenAddress, blockNumber: blockNumber, winningPot: 0, betCount: 0 };
            self.betPools.write(blockNumber, betPool);
        }

        fn getBettingPool(self: @ContractState, blockNumber: u256) -> BetPool{
           self.betPools.read(blockNumber)
        }

        fn placeBet(ref self: ContractState, tokenAddress: ContractAddress, blockNumber: u256, amount: u256, target: u256){
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

        fn disperseFunds(self: @ContractState, blockNumber: u256){
            let bettingPool = self.getBettingPool(blockNumber);
            let totalBetsForPool = bettingPool.betCount;
            let token = (IERC20Dispatcher { contract_address: bettingPool.tokenAddress });

            let mut userIndex: u256 = 0;
            let mut max: u256 = 0;
            let mut winnerAddress: ContractAddress = self.IndexToUser.read((userIndex, blockNumber));

            loop {
                if userIndex >= totalBetsForPool {
                break;
            }
                if(self.betsPlaced.read((blockNumber, userIndex)) > max){
                    max = self.betsPlaced.read((blockNumber, userIndex));
                    winnerAddress = self.IndexToUser.read((userIndex, blockNumber));
                }
                userIndex+=1;
            };

            token.transfer(winnerAddress, bettingPool.winningPot);
        }
    }
}