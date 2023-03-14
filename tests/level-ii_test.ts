
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
