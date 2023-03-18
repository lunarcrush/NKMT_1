
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Mint 1 Level II",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        
        let mintFirstBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], deployer.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], deployer.address)
        ]);
        chain.mineEmptyBlock(1);
        mintFirstBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.Nakamoto_1_Level_1.Nakamoto_1_Level_1'][deployer.address], 4);

        let mintSecondBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(1), types.uint(2), types.uint(3), types.uint(4)], deployer.address),
        ]);
        mintSecondBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['Nakamoto_1_Level_2Nakamoto_1_Level_2'][deployer.address], 1);
        
    },
});


Clarinet.test({
    name: "Cannot mint without 3 unique subtypes",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;
        
        let mintFirstBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address)
        ]);
        chain.mineEmptyBlock(1);

        let mintSecondBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(1), types.uint(2), types.uint(4), types.uint(5)], wallet_1.address),
        ]);
        mintSecondBlock.receipts[0].result.expectErr()
        assertEquals(chain.getAssetsMaps().assets['.Nakamoto_1_Level_1.Nakamoto_1_Level_1'][wallet_1.address], 4);
        assertEquals(chain.getAssetsMaps().assets['.Nakamoto_1_Level_1.Nakamoto_1_Level_1'][wallet_2.address], 6);
        
    },
});


Clarinet.test({
    name: "Level II subtypes are in order",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;
        
        let mintFirstBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
        ]);
        chain.mineEmptyBlock(1);

        let mintSecondBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(1), types.uint(2), types.uint(3), types.uint(4)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(5), types.uint(6), types.uint(7), types.uint(8)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(9), types.uint(10), types.uint(11), types.uint(12)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(13), types.uint(14), types.uint(15), types.uint(16)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(17), types.uint(18), types.uint(19), types.uint(20)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(21), types.uint(22), types.uint(23), types.uint(24)], wallet_1.address),
        ]);
        let checkTypes = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_2", "check-subtype", [types.uint(1)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "check-subtype", [types.uint(2)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "check-subtype", [types.uint(3)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "check-subtype", [types.uint(4)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "check-subtype", [types.uint(5)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "check-subtype", [types.uint(6)], wallet_1.address),
        ]);
        console.log('checkTypes', checkTypes)
        // assertEquals(chain.getAssetsMaps().assets['.Nakamoto_1_Level_1.Nakamoto_1_Level_1'][wallet_1.address], 4);
        // assertEquals(chain.getAssetsMaps().assets['.Nakamoto_1_Level_1.Nakamoto_1_Level_1'][wallet_2.address], 6);
        
    },
});


Clarinet.test({
    name: "Level ii URI is correct",
    async fn(chain: Chain, accounts: Map<string, Account>) {


        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;

        let mintFirstBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], wallet_1.address)
        ]);

        let mintSecondBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(1), types.uint(2), types.uint(3), types.uint(4)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(5), types.uint(6), types.uint(7), types.uint(8)], wallet_1.address),
        ]);

        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_2", "get-token-uri ", ['u1'], wallet_1.address),
        ]);
        console.log('mintBlock2', mintBlock2.receipts[0].result)
        assertEquals(mintBlock2.receipts[0].result, '(ok (some "https://nakamoto1.space/level_ii/1.json"))');
    },
});
