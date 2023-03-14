
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';


Clarinet.test({
    name: "Mint android and Level iii URI is correct",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;

        let mintFirstBlock = chain.mineBlock([
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-2-level-I", [], wallet_1.address),
            Tx.contractCall("level-i", "public-mint-1-level-I", [], wallet_1.address),

        ]);

        let mintSecondBlock = chain.mineBlock([
            Tx.contractCall("level-ii", "mint-level-II", [types.uint(1), types.uint(2), types.uint(3), types.uint(4)], wallet_1.address),
            Tx.contractCall("level-ii", "mint-level-II", [types.uint(5), types.uint(6), types.uint(7), types.uint(8)], wallet_1.address),
            Tx.contractCall("level-ii", "mint-level-II", [types.uint(9), types.uint(10), types.uint(11), types.uint(12)], wallet_1.address),
        ]);

        let mintThirdBlock = chain.mineBlock([
            Tx.contractCall("level-iii", "mint-level-III", [types.uint(1), types.uint(2), types.uint(3)], wallet_1.address),
        ]);

        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("level-iii", "get-token-uri ", ['u0'], wallet_1.address),
        ]);

        console.log('mintBlock2', mintBlock2.receipts[0].result)
        assertEquals(mintBlock2.receipts[0].result, '(ok (some "https://nakamoto1.space/android/0.json"))');
    },
});
