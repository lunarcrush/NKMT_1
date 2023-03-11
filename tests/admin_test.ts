
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Can check user mint count tuple",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        const deployer = accounts.get("deployer")!;
        const call = chain.callReadOnlyFn("admin", "get-user-minted-tuple", [], deployer.address);
        call.result.expectTuple;

    },
});

Clarinet.test({
    name: "Cannot update level-I value unless .level-I",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        const deployer = accounts.get("deployer")!;
        let block = chain.mineBlock([
            Tx.contractCall("admin", "update-user-level-I-mint-count", [], deployer.address),
        ]);
        block.receipts[0].result.expectErr;

    },
});

Clarinet.test({
    name: "Cannot update level-I value unless .level-II",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        const deployer = accounts.get("deployer")!;
        let block = chain.mineBlock([
            Tx.contractCall("admin", "update-user-level-II-mint-count", [], deployer.address),
        ]);
        block.receipts[0].result.expectErr;

    },
});

Clarinet.test({
    name: "Cannot update level-III value unless .level-III",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        const deployer = accounts.get("deployer")!;
        let block = chain.mineBlock([
            Tx.contractCall("admin", "update-user-level-III-mint-count", [], deployer.address),
        ]);
        block.receipts[0].result.expectErr;

    },
});

Clarinet.test({
    name: "Uint-to-ascii",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        const deployer = accounts.get("deployer")!;
        const call = chain.callReadOnlyFn("admin", "uint-to-ascii", [types.uint(1)], deployer.address);
        call.result.expectOk;

    },
});
