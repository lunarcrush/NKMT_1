;; Level-I NFT Contract
;; The 1st Level NFT in LunarCrush experience
;; Written by the ClarityClear team

;; Level-I NFT
;; 1st mint consists of 13k @ 255 stx, 2nd mint consists of 9k @ 536 stx, & 3rd mint of 2k @ 677 stx
;; Each level-I NFT has one of four different "sub-types" (u0,u1,u2,u3). A user needs one of each sub-type to qualify for a level-II NFT

;;;;;;;;;;;;;;;;;;;;;
;; Contract Basics ;;
;;;;;;;;;;;;;;;;;;;;;
(impl-trait .sip-090-trait-nft-standard.sip-090-trait)

;; level-I
(define-non-fungible-token level-I uint)

;; constants
(define-constant level-I-limit u24001)
(define-constant contract-owner tx-sender)
(define-constant height-one block-height)
(define-constant admin-mint-limit u200)

;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-1ST-MINT-OUT (err u102))
(define-constant ERR-2ND-MINT-OUT (err u103))
(define-constant ERR-NOT-AUTH (err u104))
(define-constant ERR-META-FRZN (err u105))
(define-constant ERR-NOT-LISTED (err u106))
(define-constant ERR-WRONG-COMMISSION (err u107))
(define-constant ERR-STX-TRANSFER (err u108))
(define-constant ERR-TOO-MANY (err u109))
(define-constant ERR-WRONG-PRICING (err u110))
(define-constant ERR-WRONG-HEIGHT (err u111))
(define-constant ERR-LIMITS-WRNG-ORDER (err u112))
(define-constant ERR-ADMIN-LIMIT (err u113))

;; storage
(define-map market uint {price: uint, commission: principal})
(define-map sub-type uint uint)



;;;;;;;;;;;;;;;;;;;;;
;; Admin Variables ;;
;;;;;;;;;;;;;;;;;;;;;

;; level-I basics
(define-data-var metadata-frozen bool true)
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGaTvrP/")
(define-data-var level-I-index uint u1)
(define-data-var level-I-subtype-index uint u0)

;; level-I batch sizes
(define-data-var level-I-1st-limit uint u13000)
(define-data-var level-I-2nd-limit uint u9000)

;; level-I batch prices - in STX
(define-data-var level-I-1-price uint u255000)
(define-data-var level-I-2-price uint u536000)
(define-data-var level-I-3-price uint u677000)

;; level-I batch release schedule
(define-data-var mint-block-height-2 uint u51253)
(define-data-var mint-block-height-3 uint u51397)

;; admin mint count
(define-data-var admin-mint-count uint u0)


;;;;;;;;;;;;;;;;;;;;;;
;; SIP009 Functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get level-I-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? level-I id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok
    (some
      (concat
        (concat
          (var-get ipfs-root)
          (contract-call? .admin uint-to-ascii token-id)
        )
        ".json"
      )
    )
  )
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTH)
    (nft-transfer? level-I id sender recipient)
  )
)



;;;;;;;;;;;;;;;;;;;;;;;;
;; Non-Custodial Help ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc commission trait, needs to be implemented client-side
;; @param 1 func "pay" with two inputs & one response
(define-trait commission-trait
  (
    (pay (uint uint) (response bool uint))
  )
)

;; @desc gets market listing by market list ID
;; @param id; the ID of the market listing
(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id)
)

;; @desc checks NFT owner is either tx-sender or contract caller,
;; @param id; the ID of the NFT in question
(define-private (is-sender-owner (id uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? level-I id) false))
    )
      (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)

;; @desc listing function
;; @param id: the ID of the NFT in question, price: the price being listed, comm-trait: a principal that conforms to the commission-trait
(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let
    (
      (listing {price: price, commission: (contract-of comm-trait)})
    )
    (asserts! (is-sender-owner id) ERR-NOT-AUTH)
    (map-set market id listing)
    (ok (print (merge listing {a: "list-in-ustx", id: id})))
  )
)

;; @desc un-listing function
;; @param id: the ID of the NFT in question, price: the price being listed, comm-trait: a principal that conforms to the commission-trait
(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTH)
    (map-delete market id)
    (ok (print {a: "unlist-in-stx", id: id}))
  )
)

;; @desc function to buy from a current listing
;; @param buy: the ID of the NFT in question, comm-trait: a principal that conforms to the commission-trait for royalty split
(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let
    (
      (owner (unwrap! (nft-get-owner? level-I id) ERR-NOT-AUTH))
      (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (transfer id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)



;;;;;;;;;;;;;;;;;;;;
;; Core Functions ;;
;;;;;;;;;;;;;;;;;;;;

;; @desc core level-I mint function - 3 batches with 3 different prices released after 2 block heights have been passed
(define-public (level-I-claim)
  (let (
        (next-level-I-index (+ u1 (var-get level-I-index)))
      )
      ;;checking for level-I-index against entire level-I collection (24k)
      (asserts! (< (var-get level-I-index) level-I-limit) ERR-ALL-MINTED)

      ;; check if caller is admin for admin mint (only 200 max allowed)
      (if (is-eq tx-sender contract-owner)

        (begin

          ;; check admin hasn't minted more than allotted 200
          (asserts! (< (var-get admin-mint-count) admin-mint-limit) ERR-ADMIN-LIMIT)

          ;; update admin-mint-count
          (var-set admin-mint-count (+ u1 (var-get admin-mint-count)))
        )

        (begin
          ;;checking current block height against 2nd scheduled mint release block height
          ;;need different stx-transfer functions since diff prices but only need 1 mint function
          (if (< block-height (var-get mint-block-height-2))

            ;; if true (block height is lower than scheduled 2nd mint)
            (begin
              (asserts! (< (var-get level-I-index) (var-get level-I-1st-limit)) ERR-1ST-MINT-OUT)
              (unwrap! (stx-transfer? (var-get level-I-1-price) tx-sender contract-owner) ERR-STX-TRANSFER)
            )

            ;; if false (block height has now surpassed 2nd mint)
            (begin
              (if (< block-height (var-get mint-block-height-3))
                (begin
                  (asserts! (< (var-get level-I-index) (var-get level-I-2nd-limit)) ERR-2ND-MINT-OUT)
                  (unwrap! (stx-transfer? (var-get level-I-2-price) tx-sender contract-owner) ERR-STX-TRANSFER)
                )
                (unwrap! (stx-transfer? (var-get level-I-3-price) tx-sender contract-owner) ERR-STX-TRANSFER)
              )
            )
          )
        )

      )
      (try! (nft-mint? level-I (var-get level-I-index) tx-sender))
      (unwrap! (some (map-insert sub-type (var-get level-I-index) (var-get level-I-subtype-index))) (err u1))
      (unwrap-panic (contract-call? .admin update-user-level-I-mint-count))
      (var-set level-I-index next-level-I-index)
      (ok (assign-next-subtype))
  )
)

;; @desc sub-type helper function - helps assign sub-types of type 0,1,2,3 when minted
(define-private (assign-next-subtype)
  (let
    (
      (current-subtype (var-get level-I-subtype-index))
    )
      (if (is-eq current-subtype u0)
          (var-set level-I-subtype-index u1)
          (if (is-eq current-subtype u1)
            (var-set level-I-subtype-index u2)
            (if (is-eq current-subtype u2)
              (var-set level-I-subtype-index u3)
              (var-set level-I-subtype-index u0)
            )
          )
      )
    )
  )

  ;; @desc sub-type helper function - helps assign sub-types of type 0,1,2,3 when minted
  (define-read-only (check-subtype (level-I-id uint))
      (map-get? sub-type level-I-id)
  )

;;;;;;;;;;;;;;;;;;;;
;; List Functions ;;
;;;;;;;;;;;;;;;;;;;;

;; @desc function to mint 2 l ms
(define-public (claim-two-level-Is)
  (begin
    (try! (level-I-claim))
    (ok (level-I-claim))
  )
)



;;;;;;;;;;;;;;;;;;;;;
;; Admin Functions ;;
;;;;;;;;;;;;;;;;;;;;;

;; @desc function for admin/emergency update to batch sizes
;; @param limit-one: updated batch 1 size, limit-two: updated batch 2 size
(define-public (admin-update-batch-size (limit-one uint) (limit-two uint))
  (begin

    ;; asserts only admin can call
    (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTH)

    ;; asserts new total < 23,999
    (asserts! (< (+ limit-one limit-two) level-I-limit) ERR-TOO-MANY)

    ;; asserts limit-one > limit-two > limit-three
    (asserts! (and (> limit-one limit-two) (and (> limit-two (- level-I-limit (+ limit-one limit-two))))) ERR-LIMITS-WRNG-ORDER)

    ;; update (var-set) both batch limits
    (ok (and (var-set level-I-1st-limit limit-one) (var-set level-I-2nd-limit limit-two)))
  )
)

;; @desc function for admin/emergency update to batch prices
;; @param price-one: updated batch 1 price, price-two: updated batch 2 price, price-three: updated batch 3 price
(define-public (admin-update-batch-prices (price-one uint) (price-two uint) (price-three uint))
  (begin

    ;; asserts only admin can call
    (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTH)

    ;; asserts price-one < price-two < price-three
    (asserts! (and (< price-one price-two) (< price-two price-three)) ERR-WRONG-PRICING)

    ;; update (var-set) all three prices
    (ok (and (var-set level-I-1-price price-one) (var-set level-I-2-price price-two) (var-set level-I-3-price price-three)))
   )
)

;; @desc function for admin/emergency update to batch release block heights
;; @param height-one: updated batch 2 release block height, height-two: updated batch 3 release block height
(define-public (admin-update-batch-release-heights (height-two uint) (height-three uint))
  (begin

    ;; asserts only admin can call
    (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTH)

    ;; asserts that 2nd block-height is at least later after height-one
    (asserts! (> height-two height-one) ERR-WRONG-HEIGHT)

    ;; asserts that height-three is after height-two
    (asserts! (< height-two height-three) ERR-WRONG-HEIGHT)

    ;; update (var-set) both release heights
    (ok (and (var-set mint-block-height-2 height-two) (var-set mint-block-height-3 height-three)))
  )
)
