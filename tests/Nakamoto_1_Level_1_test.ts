
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals, assertStringIncludes } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Public Mint 1 Level I",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        
        let mintBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], deployer.address),
        ]);

        mintBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.Nakamoto_1_Level_1.Nakamoto_1_Level_1'][deployer.address], 1);
    },
});

Clarinet.test({
    name: "Public Mint 2 Level I",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        console.log(chain.getAssetsMaps())
        
        let mintBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], deployer.address),
        ]);


        mintBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.Nakamoto_1_Level_1.Nakamoto_1_Level_1'][deployer.address], 2);
    },
});

Clarinet.test({
    name: "Add an admin",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;
        
        // deployer can add admin wallets
        let mintBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "add-admin", ["'" + wallet_1.address], deployer.address),
        ]);

        // newly added admin can add another admin
        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "add-admin", ["'" + wallet_2.address], wallet_1.address),
        ]);
        let readBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "get-admins", [], deployer.address),
        ]);

        // wallet_1 and wallet_2 are admins
        assertStringIncludes(readBlock.receipts[0].result, wallet_1.address);
        assertStringIncludes(readBlock.receipts[0].result, wallet_2.address);
    },
});

Clarinet.test({
    name: "Remove an admin",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;
        
        // deployer can add admin wallets
        let mintBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "add-admin", ["'" + wallet_1.address], deployer.address),
        ]);

        // newly added admin can add another admin
        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "add-admin", ["'" + wallet_2.address], wallet_1.address),
        ]);

        // newly added admin can remove another admin
        let mintBlock3 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "remove-admin", ["'" + wallet_1.address], wallet_2.address),
        ]);

        let readBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "get-admins", [], deployer.address),
        ]);
        

        // wallet_1 and wallet_2 are admins
        assertEquals(readBlock.receipts[0].result, `[${deployer.address}, ${wallet_2.address}]`);
    },
});

Clarinet.test({
    name: "New admin can admin mint",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;
        
        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "add-admin", ["'" + wallet_2.address], deployer.address),
        ]);
        // deployer can add admin wallets
        let mintBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "admin-mint-public", ['(list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0)'], wallet_2.address),
        ]);


        mintBlock.receipts[0].result.expectOk();
        // wallet_1 and wallet_2 are admins
        assertEquals(chain.getAssetsMaps().assets['.Nakamoto_1_Level_1.Nakamoto_1_Level_1'][wallet_2.address], 24);
    },
});

Clarinet.test({
    name: "New admin can admin mint",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;
        
        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "add-admin", ["'" + wallet_2.address], deployer.address),
        ]);
        // deployer can add admin wallets
        let mintBlock = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "admin-mint-public", ['(list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0)'], wallet_2.address),
        ]);


        mintBlock.receipts[0].result.expectOk();
        // wallet_1 and wallet_2 are admins
        assertEquals(chain.getAssetsMaps().assets['.Nakamoto_1_Level_1.Nakamoto_1_Level_1'][wallet_2.address], 24);
    },
});

Clarinet.test({
    name: "Admin can change price in STX",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;

        let balances = chain.getAssetsMaps()
        let balances_wallet_1 = balances.assets.STX[wallet_1.address]
        //console.log('balances', balances, 'balances_wallet_1', balances_wallet_1)

        chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], deployer.address),
        ]);
        balances = chain.getAssetsMaps()
        //console.log('balances', balances, 'balances_wallet_1', balances_wallet_1)

        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "update-mint-price", ['u100000000'], deployer.address),
        ]);
        let getMintPrice = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "get-mint-price", [], deployer.address),
        ]);
        console.log('getMintPrice', getMintPrice)

        chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], deployer.address),
        ]);
        balances = chain.getAssetsMaps()
        //console.log('balances', balances, 'balances_wallet_1', balances_wallet_1)
        assertEquals(chain.getAssetsMaps().assets.STX[deployer.address + '.Nakamoto_1_Level_1'], 350000000);
    },
});

Clarinet.test({
    name: "Level i URI is correct",
    async fn(chain: Chain, accounts: Map<string, Account>) {


        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;

        chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], wallet_2.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], wallet_2.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], wallet_2.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], wallet_2.address),
            Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], wallet_2.address),
        ]);
        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("Nakamoto_1_Level_1", "get-token-uri ", ['u4'], wallet_1.address),
        ]);
        console.log('mintBlock2', mintBlock2.receipts[0].result)
        assertEquals(mintBlock2.receipts[0].result, '(ok (some "https://nakamoto1.space/level_1/4.json"))');
    },
});

// takes a long time, only use to test if needed
// Clarinet.test({
//     name: "Cannot mint more than 24000",
//     async fn(chain: Chain, accounts: Map<string, Account>) {


//         let wallet_1 = accounts.get('wallet_1')!;
//         let wallet_2 = accounts.get('wallet_2')!;

//         for(let m = 0; m < 25002; m++) {
//             if (m < 23954) {
//                 chain.mineBlock([
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_2_Nakamoto_1_Level_1", [], wallet_2.address),
//                 ]);
//                 m+=58
//             } else {
//                 console.log('m is at', m, 'minting 1')
//                 let z= chain.mineBlock([
//                     Tx.contractCall("Nakamoto_1_Level_1", "Mint_Nakamoto_1_Level_1", [], wallet_2.address),
//                 ]);
//                 console.log('call res', z.receipts)
//                 m+=1
//             }
//         }

//         let output = chain.mineBlock([
//             Tx.contractCall("Nakamoto_1_Level_1", "get-token-uri", ['u0'], wallet_1.address),
//             Tx.contractCall("Nakamoto_1_Level_1", "get-token-uri", ['u1'], wallet_1.address),
//             Tx.contractCall("Nakamoto_1_Level_1", "get-token-uri", ['u2'], wallet_1.address),
//             Tx.contractCall("Nakamoto_1_Level_1", "get-token-uri", ['u23999'], wallet_1.address),
//             Tx.contractCall("Nakamoto_1_Level_1", "get-token-uri", ['u24000'], wallet_1.address),
//             Tx.contractCall("Nakamoto_1_Level_1", "get-token-uri", ['u24001'], wallet_1.address),
//         ]);
//         console.log('output', output)
//         console.log('balances', chain.getAssetsMaps())
        
//     },
// });
