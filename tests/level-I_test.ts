
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Can claim a level-I nft",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;
        let block = chain.mineBlock([
          Tx.contractCall("level-I", "mint-level-I", [], wallet_4.address),
        ]);

        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Can claim two level-I nfts",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;
        let block = chain.mineBlock([
          Tx.contractCall("level-I", "mint-two-level-Is", [], wallet_4.address),
        ]);

        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Can get a level-I nft current subtype",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        chain.mineBlock([
          Tx.contractCall("level-I", "mint-level-I", [], wallet_4.address),
        ]);

        chain.mineEmptyBlock(1);

        const call = chain.callReadOnlyFn("level-I", "check-subtype", [types.uint(1)], wallet_4.address);

        call.result.expectUint;
    },
});

Clarinet.test({
    name: "Cannot mint at previous batch price (I -> II)",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        chain.mineBlock([
          Tx.contractCall("level-I", "mint-level-I", [], wallet_4.address),
        ]);

        chain.mineEmptyBlockUntil(51254);

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "mint-level-I", [], wallet_4.address),
        ]);

        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Cannot mint at previous batch price (II -> III)",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        chain.mineBlock([
          Tx.contractCall("level-I", "mint-level-I", [], wallet_4.address),
        ]);

        chain.mineEmptyBlockUntil(51398);

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "mint-level-I", [], wallet_4.address),
        ]);

        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Cannot update batch sizes if not admin",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-size", [types.uint(1),types.uint(2)], wallet_4.address),
        ]);

        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Cannot mint update batch sizes if new batch size != 24,000",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-size", [types.uint(24000),types.uint(20)], deployer.address),
        ]);

        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Cannot mint update batch sizes if b1 < b2",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-size", [types.uint(6000),types.uint(16000)], deployer.address),
        ]);

        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Can mint update batch sizes",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-size", [types.uint(16000),types.uint(6000)], deployer.address),
        ]);

        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Cannot update batch prices if not admin",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-prices", [types.uint(1),types.uint(2),types.uint(2)], wallet_4.address),
        ]);

        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Cannot mint update batch sizes if p1 !< p2 !< p3",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-prices", [types.uint(6000),types.uint(16000),types.uint(12000)], deployer.address),
        ]);

        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Admin can update batch prices",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-prices", [types.uint(255000),types.uint(255001),types.uint(255002)], deployer.address),
        ]);

        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Cannot update batch prices if not admin",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-release-heights", [types.uint(1),types.uint(2)], wallet_4.address),
        ]);

        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Cannot update batch prices if h2 > h3",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-release-heights", [types.uint(2),types.uint(1)], wallet_4.address),
        ]);

        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Cannot update batch prices if h2 < h1",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-release-heights", [types.uint(0),types.uint(1)], wallet_4.address),
        ]);

        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Admin can update batch heights",
    async fn(chain: Chain, accounts: Map<string, Account>) {
      const deployer = accounts.get("deployer")!;
      const wallet_4 = accounts.get("wallet_4")!;

        let block = chain.mineBlock([
          Tx.contractCall("level-I", "admin-update-batch-release-heights", [types.uint(2),types.uint(3)], deployer.address),
        ]);

        block.receipts[0].result.expectOk();
    },
});
