
#[allow(duplicate_alias)]
module sui_nft::sui_nft {
    use sui::object;
    use sui::transfer;
    use sui::tx_context;
    use sui::clock::{Self, Clock};
    use std::string::{Self, String};

    /// Represents an NFT with metadata
    public struct NFT has key, store {
        id: object::UID,         // Unique identifier
        name: String,            // Name of the NFT
        description: String,     // Description of the NFT
        timestamp: u64           // When it was minted
    }

    /// Admin capability to initialize the platform
    public struct AdminCap has key { id: object::UID }

    /// Initialize the platform (called once by admin)
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