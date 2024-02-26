pub type Peaks = Span<felt252>;

pub type Proof = Span<felt252>;

pub type Words64 = Span<u64>;

#[derive(Drop, Serde)]
struct ProofElement {
    index: usize,
    value: u256,
    proof: Proof,
}

#[derive(Drop, Serde)]
enum AccountField {
    StorageHash: (),
    CodeHash: (),
    Balance: (),
    Nonce: ()
}

#[derive(Drop, Serde)]
pub struct BinarySearchTree {
    mapper_id: usize,
    last_pos: usize, // last_pos in mapper's MMR
    peaks: Peaks,
    proofs: Span<ProofElement>, // Midpoint elements inclusion proofs
    left_neighbor: Option<ProofElement>, // Optional left neighbor inclusion proof
}

#[starknet::interface]
pub trait ITimestampRemappers<TContractState> {
    // Retrieves the timestamp of the L1 block closest to the given timestamp.
    fn get_closest_l1_block_number(
        self: @TContractState, tree: BinarySearchTree, timestamp: u256
    ) -> Result<Option<u256>, felt252>;

    // Getter for the last timestamp of a given mapper.
    fn get_last_mapper_timestamp(self: @TContractState, mapper_id: usize) -> u256;
}

#[starknet::interface]
pub trait IBlockHeaders<TContractState> {
    fn verify_mmr_inclusion(
        self: @TContractState,
        index: usize,
        poseidon_blockhash: felt252,
        peaks: Peaks,
        proof: Proof,
        mmr_id: usize,
    ) -> bool;
}