;; Level-II NFT Contract
;; The 2nd Level NFT in LunarCrush experience
;; Written by the ClarityClear team

;; Level-II NFT
;; The level-II NFT has a collection limit of 6k. All 6k are derived from a tx-sender "burning" exactly 4 level-Is of different sub-types
;; Each level-II NFT has a one of three different "sub-types" (u0,u1,u2). A user needs one of each sub-type to qualify for a level-III NFT

;;;;;;;;;;;;;;;;;;;;;
;; Contract Basics ;;
;;;;;;;;;;;;;;;;;;;;;
(impl-trait .sip-090-trait-nft-standard.sip-090-trait)
;; level-II
(define-non-fungible-token level-II uint)

;; constants
(define-constant level-II-limit u6000)
(define-constant contract-owner tx-sender)

;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-INCORRECT-SUBTYPES (err u105))

;; vars
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGafbHbATvrP/pm_")
(define-data-var level-II-index uint u0)
(define-data-var level-II-subtype-index uint u0)

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
    (try! (transfer id owner tx-sender))
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
      (next-level-II-index (+ u1 (var-get level-II-index)))
      (nft-0-subtype (default-to u6 (contract-call? .level-I check-subtype level-I-id-1)))
      (nft-1-subtype (default-to u6 (contract-call? .level-I check-subtype level-I-id-2)))
      (nft-2-subtype (default-to u6 (contract-call? .level-I check-subtype level-I-id-3)))
      (nft-3-subtype (default-to u6 (contract-call? .level-I check-subtype level-I-id-4)))
      (subtype-total (fold + (list nft-0-subtype nft-1-subtype nft-2-subtype nft-3-subtype) u0))
    )
    (asserts! (< (var-get level-II-index) level-II-limit) ERR-ALL-MINTED)
    (asserts! (is-eq subtype-total u6) ERR-INCORRECT-SUBTYPES)
    (unwrap-panic (contract-call? .level-I transfer level-I-id-1 tx-sender 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6))
    (unwrap-panic (contract-call? .level-I transfer level-I-id-2 tx-sender 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6))
    (unwrap-panic (contract-call? .level-I transfer level-I-id-3 tx-sender 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6))
    (unwrap-panic (contract-call? .level-I transfer level-I-id-4 tx-sender 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6))
    (unwrap! (some (map-insert sub-type (var-get level-II-index) (var-get level-II-subtype-index))) (err u1))
    (try! (nft-mint? level-II (var-get level-II-index) tx-sender))
    (ok (var-set level-II-index next-level-II-index))
  )
)

;; @desc sub-type helper function - helps assign sub-types of type 0,1,2 when minted
(define-private (assign-next-subtype)
  (let
    (
      (current-subtype (var-get level-II-subtype-index))
    )
      (if (is-eq current-subtype u0)
          (var-set level-II-subtype-index u1)
          (if (is-eq current-subtype u1)
            (var-set level-II-subtype-index u2)
            (var-set level-II-subtype-index u0)
          )
      )
    )
  )

  ;; @desc sub-type helper function - helps assign sub-types of type 0,1,2 when minted
  (define-read-only (check-subtype (level-II-id uint))
      (map-get? sub-type level-II-id)
  )
