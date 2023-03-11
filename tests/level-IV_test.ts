
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Can mint a level-IV",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-IV", "mint-level-IV", [], wallet_4.address),
        ]);

        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Can mint a level-IV",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-IV", "mint-level-IV", [], deployer.address),
        ]);

        block.receipts[0].result.expectOk();
    },
});
