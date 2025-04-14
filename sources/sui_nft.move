
#[allow(duplicate_alias)]
module sui_nft::sui_nft {
    use sui::object;
    use sui::transfer;
    use sui::tx_context;
    use sui::clock::{Self, Clock};
    use std::string::{Self, String};

    public struct NFT has key, store {
        id: object::UID,
        name: String,
        description: String,
        timestamp: u64
    }

    public struct AdminCap has key { id: object::UID }

    fun init(ctx: &mut tx_context::TxContext) {
        let admin_cap = AdminCap {
            id: object::new(ctx)
        };
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }

    /// Mint a new NFT
    public entry fun mint(
        name: vector<u8>,
        description: vector<u8>,
        clock: &Clock,
        ctx: &mut tx_context::TxContext
    ) {
        // Ensure inputs are not empty
        assert!(vector::length(&name) > 0, 100);
        assert!(vector::length(&description) > 0, 101);

        // Create the NFT
        let nft = NFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            timestamp: clock::timestamp_ms(clock)
        };

        // Transfer the NFT to the sender (minter)
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// View NFT details (for testing purposes)
    public fun get_nft_details(nft: &NFT): (&String, &String, u64) {
        (&nft.name, &nft.description, nft.timestamp)
    }
}