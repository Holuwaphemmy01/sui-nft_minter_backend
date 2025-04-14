#[test_only]
module sui_nft::sui_nft_tests {
    use sui_nft::sui_nft::{Self, NFT};
    use sui::test_scenario;
    use sui::clock;
    use std::string;

    #[test]
    fun test_mint_nft() {
        // Start a test scenario with a user address
        let mut scenario = test_scenario::begin(@0xA);

        // Create a mock clock object
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        clock::increment_for_testing(&mut clock, 123456789);

        // Mint an NFT
        {
            let ctx = test_scenario::ctx(&mut scenario);
            sui_nft::mint(b"MyNFT", b"A cool NFT", &clock, ctx);
        };

        // Move to the next transaction and verify the NFT
        test_scenario::next_tx(&mut scenario, @0xA);
        {
            let nft = test_scenario::take_from_sender<NFT>(&scenario);
            let (name, desc, timestamp) = sui_nft::get_nft_details(&nft);

            // Assert the NFT metadata is correct
            assert!(*name == string::utf8(b"MyNFT"), 1);
            assert!(*desc == string::utf8(b"A cool NFT"), 2);
            assert!(timestamp == 123456789, 3);

            test_scenario::return_to_sender(&scenario, nft);
        };

        // Clean up
        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 100)]
    fun test_mint_empty_name_fails() {
        // Start a test scenario
        let mut scenario = test_scenario::begin(@0xA);

        // Create a mock clock
        let clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        // Attempt to mint with an empty name (should fail)
        {
            let ctx = test_scenario::ctx(&mut scenario);
            sui_nft::mint(b"", b"Valid description", &clock, ctx);
        };

        // Clean up
        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 101)]
    fun test_mint_empty_description_fails() {
        // Start a test scenario
        let mut scenario = test_scenario::begin(@0xA);

        // Create a mock clock
        let clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        // Attempt to mint with an empty description (should fail)
        {
            let ctx = test_scenario::ctx(&mut scenario);
            sui_nft::mint(b"Valid name", b"", &clock, ctx);
        };

        // Clean up
        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_multiple_nfts() {
        // Start a test scenario with a user address
        let mut scenario = test_scenario::begin(@0xA);

        // Create a mock clock object
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        let start_time = 123456789;
        clock::increment_for_testing(&mut clock, start_time);

        // Mint the first NFT
        {
            let ctx = test_scenario::ctx(&mut scenario);
            sui_nft::mint(b"NFT1", b"First NFT", &clock, ctx);
        };

        // Advance clock for the second NFT
        let time_increment = 1000;
        clock::increment_for_testing(&mut clock, time_increment);

        // Mint the second NFT
        {
            let ctx = test_scenario::ctx(&mut scenario);
            sui_nft::mint(b"NFT2", b"Second NFT", &clock, ctx);
        };

        // Move to the next transaction and verify both NFTs
        test_scenario::next_tx(&mut scenario, @0xA);
        {
            // Take NFTs (note: order may be reversed in test_scenario)
            let nft_latest = test_scenario::take_from_sender<NFT>(&scenario);
            let nft_earlier = test_scenario::take_from_sender<NFT>(&scenario);

            // Check both NFTs (order-agnostic)
            let (name1, desc1, timestamp1) = sui_nft::get_nft_details(&nft_latest);
            let (name2, desc2, timestamp2) = sui_nft::get_nft_details(&nft_earlier);

            // Since order is unpredictable, check both possibilities
            if (*name1 == string::utf8(b"NFT2")) {
                // nft_latest is NFT2, nft_earlier is NFT1
                assert!(*name1 == string::utf8(b"NFT2"), 1);
                assert!(*desc1 == string::utf8(b"Second NFT"), 2);
                assert!(timestamp1 == start_time + time_increment, 3);

                assert!(*name2 == string::utf8(b"NFT1"), 4);
                assert!(*desc2 == string::utf8(b"First NFT"), 5);
                assert!(timestamp2 == start_time, 6);
            } else {
                // nft_latest is NFT1, nft_earlier is NFT2
                assert!(*name1 == string::utf8(b"NFT1"), 7);
                assert!(*desc1 == string::utf8(b"First NFT"), 8);
                assert!(timestamp1 == start_time, 9);

                assert!(*name2 == string::utf8(b"NFT2"), 10);
                assert!(*desc2 == string::utf8(b"Second NFT"), 11);
                assert!(timestamp2 == start_time + time_increment, 12);
            };

            // Return both NFTs
            test_scenario::return_to_sender(&scenario, nft_latest);
            test_scenario::return_to_sender(&scenario, nft_earlier);
        };

        // Clean up
        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }
}