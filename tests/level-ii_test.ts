
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Mint 1 Level II",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        
        let mintFirstBlock = chain.mineBlock([
            Tx.contractCall("level-i", "public-mint-2-level-I", [], deployer.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], deployer.address)
        ]);
        chain.mineEmptyBlock(1);
        mintFirstBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.level-i.level-I'][deployer.address], 4);

        let mintSecondBlock = chain.mineBlock([
            Tx.contractCall("level-ii", "mint-level-II", [types.uint(1), types.uint(2), types.uint(3), types.uint(4)], deployer.address),
        ]);
        mintSecondBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.level-ii.level-II'][deployer.address], 1);
        
    },
});

Clarinet.test({
    name: "Level ii URI is correct",
    async fn(chain: Chain, accounts: Map<string, Account>) {


        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;

        let mintFirstBlock = chain.mineBlock([
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-1-level-I", [], wallet_1.address)
        ]);

        let mintSecondBlock = chain.mineBlock([
            Tx.contractCall("level-ii", "mint-level-II", [types.uint(1), types.uint(2), types.uint(3), types.uint(4)], wallet_1.address),
            Tx.contractCall("level-ii", "mint-level-II", [types.uint(5), types.uint(6), types.uint(7), types.uint(8)], wallet_1.address),
        ]);

        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("level-ii", "get-token-uri ", ['u1'], wallet_1.address),
        ]);
        console.log('mintBlock2', mintBlock2.receipts[0].result)
        assertEquals(mintBlock2.receipts[0].result, '(ok (some "https://nakamoto1.space/level_ii/1.json"))');
    },
});
