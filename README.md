# NKMT_1

## level-i functions

```
(add-admin (new-admin principal))
(admin-mint-public (mint-count (list 250 uint)))
(burn (id uint))
(buy-in-ustx
    (id uint)
    (comm-trait <ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.level-i.commission-trait>))
(check-subtype (level-I-id uint))
(get-admins)
(get-last-token-id)
(get-listing-in-ustx (id uint))
(get-owner (id uint))
(get-token-uri (token-id uint))
(list-in-ustx
    (id uint)
    (price uint)
    (comm-trait <ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.level-i.commission-trait>))
(public-mint-1-level-I)
(public-mint-2-level-I)
(remove-admin (removed-admin principal))
(transfer
    (id uint)
    (sender principal)
    (recipient principal))
(uint-to-ascii (value uint))
(uint-to-ascii-inner
    (i (buff 1))
    (d (tuple (r (string-ascii 39)) (v uint))))
(unlist-in-ustx (id uint))
(unlock-contract-stx
    (amount uint)
    (recipient principal))
(update-mint-price (new-mint-price uint))
```

## level-ii functions

```
(burn (id uint))
(buy-in-ustx
    (id uint)
    (comm-trait <ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.level-ii.commission-trait>))
(check-subtype (level-II-id uint))
(get-last-token-id)
(get-listing-in-ustx (id uint))
(get-owner (id uint))
(get-token-uri (token-id uint))
(list-in-ustx
    (id uint)
    (price uint)
    (comm-trait <ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.level-ii.commission-trait>))
(mint-level-II
    (level-I-id-1 uint)
    (level-I-id-2 uint)
    (level-I-id-3 uint)
    (level-I-id-4 uint))
(transfer
    (id uint)
    (sender principal)
    (recipient principal))
(uint-to-ascii (value uint))
(uint-to-ascii-inner
    (i (buff 1))
    (d (tuple (r (string-ascii 39)) (v uint))))
(unlist-in-ustx (id uint))

```

## level-iii functions

```
(buy-in-ustx
    (id uint)
    (comm-trait <ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.level-iii.commission-trait>))
(get-last-token-id)
(get-listing-in-ustx (id uint))
(get-owner (id uint))
(get-token-uri (token-id uint))
(list-in-ustx
    (id uint)
    (price uint)
    (comm-trait <ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.level-iii.commission-trait>))
(mint-level-III
    (level-II-id-1 uint)
    (level-II-id-2 uint)
    (level-II-id-3 uint))
(transfer
    (id uint)
    (sender principal)
    (recipient principal))
(uint-to-ascii (value uint))
(uint-to-ascii-inner
    (i (buff 1))
    (d (tuple (r (string-ascii 39)) (v uint))))
(unlist-in-ustx (id uint))
```

## level-iv functions

```
(add-admin (new-admin principal))
(buy-in-ustx
    (id uint)
    (comm-trait <ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.level-iv.commission-trait>))
(get-last-token-id)
(get-listing-in-ustx (id uint))
(get-owner (id uint))
(get-token-uri (token-id uint))
(list-in-ustx
    (id uint)
    (price uint)
    (comm-trait <ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.level-iv.commission-trait>))
(mint-level-IV)
(remove-admin (removed-admin principal))
(transfer
    (id uint)
    (sender principal)
    (recipient principal))
(uint-to-ascii (value uint))
(uint-to-ascii-inner
    (i (buff 1))
    (d (tuple (r (string-ascii 39)) (v uint))))
(unlist-in-ustx (id uint))

```
