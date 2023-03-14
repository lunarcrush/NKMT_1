
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals, assertStringIncludes } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Public Mint 1 Level I",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        
        let mintBlock = chain.mineBlock([
            Tx.contractCall("level-i", "public-mint-1-level-I", [], deployer.address),
        ]);

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


        mintBlock.receipts[0].result.expectOk();
        assertEquals(chain.getAssetsMaps().assets['.level-i.level-I'][deployer.address], 2);
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
            Tx.contractCall("level-i", "add-admin", ["'" + wallet_1.address], deployer.address),
        ]);

        // newly added admin can add another admin
        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("level-i", "add-admin", ["'" + wallet_2.address], wallet_1.address),
        ]);
        let readBlock = chain.mineBlock([
            Tx.contractCall("level-i", "get-admins", [], deployer.address),
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
            Tx.contractCall("level-i", "add-admin", ["'" + wallet_1.address], deployer.address),
        ]);

        // newly added admin can add another admin
        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("level-i", "add-admin", ["'" + wallet_2.address], wallet_1.address),
        ]);

        // newly added admin can remove another admin
        let mintBlock3 = chain.mineBlock([
            Tx.contractCall("level-i", "remove-admin", ["'" + wallet_1.address], wallet_2.address),
        ]);

        let readBlock = chain.mineBlock([
            Tx.contractCall("level-i", "get-admins", [], deployer.address),
        ]);
        console.log("readBlock",readBlock)

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
            Tx.contractCall("level-i", "add-admin", ["'" + wallet_2.address], deployer.address),
        ]);
        // deployer can add admin wallets
        let mintBlock = chain.mineBlock([
            Tx.contractCall("level-i", "admin-mint-public", ['(list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0)'], wallet_2.address),
        ]);


        mintBlock.receipts[0].result.expectOk();
        // wallet_1 and wallet_2 are admins
        assertEquals(chain.getAssetsMaps().assets['.level-i.level-I'][wallet_2.address], 24);
    },
});

Clarinet.test({
    name: "New admin can admin mint",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        let deployer = accounts.get('deployer')!;
        let wallet_1 = accounts.get('wallet_1')!;
        let wallet_2 = accounts.get('wallet_2')!;
        
        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("level-i", "add-admin", ["'" + wallet_2.address], deployer.address),
        ]);
        // deployer can add admin wallets
        let mintBlock = chain.mineBlock([
            Tx.contractCall("level-i", "admin-mint-public", ['(list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0)'], wallet_2.address),
        ]);


        mintBlock.receipts[0].result.expectOk();
        // wallet_1 and wallet_2 are admins
        assertEquals(chain.getAssetsMaps().assets['.level-i.level-I'][wallet_2.address], 24);
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
            Tx.contractCall("level-i", "public-mint-1-level-I", [], deployer.address),
        ]);
        balances = chain.getAssetsMaps()
        //console.log('balances', balances, 'balances_wallet_1', balances_wallet_1)

        let mintBlock2 = chain.mineBlock([
            Tx.contractCall("level-i", "update-mint-price", ['u100000000'], deployer.address),
        ]);

        chain.mineBlock([
            Tx.contractCall("level-i", "public-mint-1-level-I", [], deployer.address),
        ]);
        balances = chain.getAssetsMaps()
        //console.log('balances', balances, 'balances_wallet_1', balances_wallet_1)
        assertEquals(chain.getAssetsMaps().assets.STX[deployer.address + '.level-i'], 350000000);
    },
});
