;; Level-II NFT Contract
;; The 2nd Level NFT in LunarCrush experience
;; Written by the ClarityClear team

;; Level-II NFT
;; The level-II NFT has a collection limit of 6k. All 6k are derived from a tx-sender "burning" exactly 4 level-Is of different sub-types
;; Each level-II NFT has a one of three different "sub-types" (u0,u1,u2). A user needs one of each sub-type to qualify for a level-III NFT

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Contract Basics ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Check contract adheres to SIP-009
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait .sip-09.sip-09-trait)

;; Define level-I NFT
(define-non-fungible-token level-II uint)

;; constants
(define-constant level-II-limit u6001)

;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-INCORRECT-SUBTYPES (err u105))
(define-constant ERR-BURN-FIRST (err u106))
(define-constant ERR-BURN-SECOND (err u107))
(define-constant ERR-BURN-THIRD (err u108))
(define-constant ERR-BURN-FOURTH (err u109))
(define-constant ERR-MINT-LEVEL-II (err u110))
(define-constant ERR-NFT-BURN (err u110))

;; vars
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGafbHbATvrP/pm_")
(define-data-var level-II-index uint u1)
(define-data-var level-II-subtype-index uint u1)

;; storage
(define-map market uint {price: uint, commission: principal})
(define-map sub-type uint uint)


;;;;;;;;;;;;;;;;;;;;;;
;; SIP009 Functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get level-II-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? level-II id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok
    (some
      (concat
        (concat
          (var-get ipfs-root)
          (uint-to-ascii token-id)
        )
        ".json"
      )
    )
  )
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTH)
    (nft-transfer? level-II id sender recipient)
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

;; @desc checks NFT owner is either tx-sender or contract caller
;; @param id; the ID of the NFT in question
(define-private (is-sender-owner (id uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? level-II id) false))
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
      (owner (unwrap! (nft-get-owner? level-II id) ERR-NOT-AUTH))
      (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (nft-transfer? level-II id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)




;;;;;;;;;;;;;;;;;;;;
;; Core Functions ;;
;;;;;;;;;;;;;;;;;;;;

;; @desc core function for minting a level-II, four lunar-fragments are required as burns
;; @param level-I-id-1: id of the 1/4 level-I burned, level-I-id-2: id of the 2/4 level-I burned, level-I-id-3: id of the 3/4 level-I burned, level-I-id-4: id of the 4/4 level-I burned
(define-public (mint-level-II (level-I-id-1 uint) (level-I-id-2 uint) (level-I-id-3 uint) (level-I-id-4 uint))
  (let
    (
      (current-level-II-index (var-get level-II-index))
      (next-level-II-index (+ u1 current-level-II-index))
      (current-level-II-subtype-index (var-get level-II-subtype-index))
      (nft-1-subtype (default-to u10 (contract-call? .level-i check-subtype level-I-id-1)))
      (nft-2-subtype (default-to u10 (contract-call? .level-i check-subtype level-I-id-2)))
      (nft-3-subtype (default-to u10 (contract-call? .level-i check-subtype level-I-id-3)))
      (nft-4-subtype (default-to u10 (contract-call? .level-i check-subtype level-I-id-4)))
    )

    ;; Assert that the level-II index is less than the limit
    (asserts! (< (var-get level-II-index) level-II-limit) ERR-ALL-MINTED)

    ;; Assert that all four level-I's have different subtypes using is-eq
    (asserts! (and (is-eq nft-1-subtype u1) (is-eq nft-2-subtype u2) (is-eq nft-3-subtype u3) (is-eq nft-4-subtype u4)) ERR-INCORRECT-SUBTYPES)

    ;; Burn level-I-id-1 NFT
    (unwrap! (contract-call? .level-i burn level-I-id-1) ERR-BURN-FIRST)

    ;; Burn level-I-id-2 NFT
    (unwrap! (contract-call? .level-i burn level-I-id-2) ERR-BURN-SECOND)

    ;; Burn level-I-id-3 NFT
    (unwrap! (contract-call? .level-i burn level-I-id-3) ERR-BURN-THIRD)

    ;; Burn level-I-id-4 NFT
    (unwrap! (contract-call? .level-i burn level-I-id-4) ERR-BURN-FOURTH)
    
    ;; Insert the new level-II sub-type into the sub-type map
    (map-insert sub-type current-level-II-index current-level-II-subtype-index)
    
    ;; Mint the level-II
    (unwrap! (nft-mint? level-II current-level-II-index tx-sender) ERR-MINT-LEVEL-II)

    ;; Update to next sub-type
    (assign-next-subtype)

    ;; Update level-II index
    (ok (var-set level-II-index next-level-II-index))
  )
)

;; @desc sub-type helper function - helps assign sub-types of type 1,2,3 when minted
(define-private (assign-next-subtype)
  (let
    (
      (current-subtype (var-get level-II-subtype-index))
    )
      (if (is-eq current-subtype u1)
          (var-set level-II-subtype-index u2)
          (if (is-eq current-subtype u2)
            (var-set level-II-subtype-index u3)
            (var-set level-II-subtype-index u0)
          )
      )
 )
)

  ;; @desc sub-type helper function - helps assign sub-types of type 0,1,2 when minted
  (define-read-only (check-subtype (level-II-id uint))
      (map-get? sub-type level-II-id)
  )

;;;;;;;;;;;;;;;;;;;
;; Burn Function ;;
;;;;;;;;;;;;;;;;;;;
;; @desc - burn function for Level-I NFTs
;; @param - id (uint): id of NFT to burn
(define-public (burn (id uint))
    (let
        (
            (owner (unwrap! (nft-get-owner? level-II id) ERR-NOT-AUTH))
        )

        ;; Assert tx-sender is owner of NFT
        (asserts! (is-eq tx-sender owner) ERR-NOT-AUTH)

        ;; Burn NFT
        (ok (unwrap! (nft-burn? level-II id tx-sender) ERR-NFT-BURN))

    )
)



;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; @desc utility function that takes in a unit & returns a string
;; @param value; the unit we're casting into a string to concatenate
;; thanks to Lnow for the guidance
(define-read-only (uint-to-ascii (value uint))
  (if (<= value u9)
    (unwrap-panic (element-at "0123456789" value))
    (get r (fold uint-to-ascii-inner
      0x000000000000000000000000000000000000000000000000000000000000000000000000000000
      {v: value, r: ""}
    ))
  )
)

(define-read-only (uint-to-ascii-inner (i (buff 1)) (d {v: uint, r: (string-ascii 39)}))
  (if (> (get v d) u0)
    {
      v: (/ (get v d) u10),
      r: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get v d) u10))) (get r d)) u39))
    }
    d
  )
)