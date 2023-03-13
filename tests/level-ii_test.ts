
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.31.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Mint 1 Level II",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        console.log(chain.getAssetsMaps())
        
        let mintFirstBlock = chain.mineBlock([
            Tx.contractCall("level-i", "public-mint-2-level-I", [], deployer.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], deployer.address)
        ]);
        console.log(chain.getAssetsMaps())
        chain.mineEmptyBlock(1);
        console.log(mintFirstBlock.receipts[0].result);
        mintFirstBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.level-i.level-I'][deployer.address], 4);

        let mintSecondBlock = chain.mineBlock([
            Tx.contractCall("level-ii", "mint-level-II", [types.uint(1), types.uint(2), types.uint(3), types.uint(4)], deployer.address),
        ]);
        console.log(chain.getAssetsMaps())
        console.log(mintSecondBlock.receipts[0].result);
        mintSecondBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.level-ii.level-II'][deployer.address], 1);
        
    },
});
