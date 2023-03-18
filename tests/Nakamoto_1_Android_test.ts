
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';


Clarinet.test({
    name: "Mint android  URI is correct",
    async fn(chain: Chain, accounts: Map<string, Account>) {

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
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], wallet_1.address),
        ]);

        let mintSecondBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(1), types.uint(2), types.uint(3), types.uint(4)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(5), types.uint(6), types.uint(7), types.uint(8)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(9), types.uint(10), types.uint(11), types.uint(12)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(13), types.uint(14), types.uint(15), types.uint(16)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(17), types.uint(18), types.uint(19), types.uint(20)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Level_2", "Mint_Nakamoto_1_Level_2", [types.uint(21), types.uint(22), types.uint(23), types.uint(24)], wallet_1.address),
        ]);

        let mintThirdBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Android", "Mint_Nakamoto_1_Level_3", [types.uint(1), types.uint(2), types.uint(3)], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Android", "Mint_Nakamoto_1_Level_3", [types.uint(4), types.uint(5), types.uint(6)], wallet_1.address),
        ]);

        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Android", "get-token-uri ", ['u0'], wallet_1.address),
            Tx.contractCall("Nakamoto_1_Android", "get-token-uri ", ['u1'], wallet_1.address),
        ]);

        console.log('mintBlock2', mintBlock2.receipts[0].result)
        assertEquals(mintBlock2.receipts[1].result, '(ok (some "https://nakamoto1.space/android/1.json"))');
    },
});
