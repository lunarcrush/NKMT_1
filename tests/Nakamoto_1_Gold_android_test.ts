
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Admin can mint a gold android",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        
        let mintFirstBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Gold_Android", "Mint_Nakamoto_1_Gold_Android", [], deployer.address),
        ]);
        chain.mineEmptyBlock(1);
        mintFirstBlock.receipts[0].result.expectOk();

        let mintFirstBlock2 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Gold_Android", "Mint_Nakamoto_1_Gold_Android", [], wallet_1.address),
        ]);
        chain.mineEmptyBlock(1);
        mintFirstBlock2.receipts[0].result.expectErr();

        console.log("maps", chain.getAssetsMaps())
        
    },
});
