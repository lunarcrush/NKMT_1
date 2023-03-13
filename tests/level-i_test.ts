
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.31.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Public Mint 1 Level I",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        console.log(chain.getAssetsMaps())
        
        let mintBlock = chain.mineBlock([
            Tx.contractCall("level-i", "public-mint-1-level-I", [], deployer.address),
        ]);
        console.log(chain.getAssetsMaps())

        console.log(mintBlock.receipts[0].result);
        mintBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.level-i.level-I'][deployer.address], 1);
    },
});

Clarinet.test({
    name: "Public Mint 2 Level I",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        console.log(chain.getAssetsMaps())
        
        let mintBlock = chain.mineBlock([
            Tx.contractCall("level-i", "public-mint-2-level-I", [], deployer.address),
        ]);
        console.log(chain.getAssetsMaps())

        console.log(mintBlock.receipts[0].result);
        mintBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.level-i.level-I'][deployer.address], 2);
    },
});
