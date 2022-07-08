
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can mint a level-II",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        chain.mineBlock([
          Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
        ]);

        chain.mineBlock([
          Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
        ]);

        chain.mineBlock([
          Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
        ]);

        chain.mineBlock([
          Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
        ]);

        chain.mineEmptyBlock(1);

        let block = chain.mineBlock([
          Tx.contractCall("level-II", "mint-level-II", [types.uint(1),types.uint(2),types.uint(3),types.uint(4)], wallet_4.address),
        ]);

        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Can mint a level-II",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        chain.mineBlock([
          Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
        ]);

        chain.mineBlock([
          Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
        ]);

        chain.mineBlock([
          Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
        ]);

        chain.mineBlock([
          Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
        ]);

        chain.mineBlock([
          Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
        ]);

        chain.mineEmptyBlock(1);

        let block = chain.mineBlock([
          Tx.contractCall("level-II", "mint-level-II", [types.uint(1),types.uint(2),types.uint(3),types.uint(5)], wallet_4.address),
        ]);

        block.receipts[0].result.expectErr;
    },
});

Clarinet.test({
    name: "Can get a level-II nft current subtype",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

      chain.mineBlock([
        Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
      ]);

      chain.mineBlock([
        Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
      ]);

      chain.mineBlock([
        Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
      ]);

      chain.mineBlock([
        Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
      ]);

      chain.mineBlock([
        Tx.contractCall("level-I", "level-I-claim", [], wallet_4.address),
      ]);

      chain.mineEmptyBlock(1);

      chain.mineBlock([
        Tx.contractCall("level-II", "mint-level-II", [types.uint(1),types.uint(2),types.uint(3),types.uint(4)], wallet_4.address),
      ]);

        chain.mineEmptyBlock(1);

        const call = chain.callReadOnlyFn("level-II", "check-subtype", [types.uint(1)], wallet_4.address);

        call.result.expectUint;
    },
});
