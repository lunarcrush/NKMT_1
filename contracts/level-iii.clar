;; Level-III NFT Contract
;; The 3rd Level NFT in LunarCrush experience
;; Written by the ClarityClear team

;; Level-III NFT
;; The level-III NFT has a collection limit of 2k. All 6k are derived from a tx-sender "burning" exactly 3 level-IIs of different sub-types
;; This is the final NFT required for a user to be "active" to claim the treasure stored on the moon

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Contract Basics ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Check contract adheres to SIP-009
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait .sip-09.sip-09-trait)

;; Define level-I NFT
(define-non-fungible-token level-III uint)

;; constants
(define-constant level-III-limit u2001)

;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-INCORRECT-SUBTYPES (err u105))
(define-constant ERR-BURN-FIRST (err u106))
(define-constant ERR-BURN-SECOND (err u107))
(define-constant ERR-BURN-THIRD (err u108))

;; vars
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGafbHbATvrP/pm_")
(define-data-var level-III-index uint u1)

;; storage
(define-map market uint {price: uint, commission: principal})



;;;;;;;;;;;;;;;;;;;;;;
;; SIP009 Functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get level-III-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? level-III id))
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
    (nft-transfer? level-III id sender recipient)
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
      (owner (unwrap! (nft-get-owner? level-III id) false))
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
      (owner (unwrap! (nft-get-owner? level-III id) ERR-NOT-AUTH))
      (listing (unwrap! (map-get? market id) ERR-NOT-LISTED))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (nft-transfer? level-III id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)




;;;;;;;;;;;;;;;;;;;;
;; Core Functions ;;
;;;;;;;;;;;;;;;;;;;;

;; @desc core function for minting a level-III, two partial-mapps are required as burns
;; @param level-II-id-1: id of the 1/3 level-II burned, level-II-id-2: id of the 2/3 level-II burned...
(define-public (mint-level-III (level-II-id-1 uint) (level-II-id-2 uint) (level-II-id-3 uint))
  (let
    (
      (current-level-III-index (var-get level-III-index))
      (next-level-III-index (+ u1 (var-get level-III-index)))
      (nft-1-subtype (default-to u6 (contract-call? .level-ii check-subtype level-II-id-1)))
      (nft-2-subtype (default-to u6 (contract-call? .level-ii check-subtype level-II-id-2)))
      (nft-3-subtype (default-to u6 (contract-call? .level-ii check-subtype level-II-id-3)))
    )

    ;; Assert that not all level-III have been minted
    (asserts! (< (var-get level-III-index) level-III-limit) ERR-ALL-MINTED)

    ;; Assert that subtypes are correct
    ;;(asserts! (is-eq subtype-total u6) ERR-INCORRECT-SUBTYPES)
    ;; Assert that sub-types are correct using And & is-eq
    (asserts! (and (is-eq nft-1-subtype u1) (is-eq nft-2-subtype u2) (is-eq nft-3-subtype u3)) ERR-INCORRECT-SUBTYPES)

    ;; Burn level-II-id-1
    (unwrap! (contract-call? .level-ii burn level-II-id-1) ERR-BURN-FIRST)

    ;; Burn level-II-id-2
    (unwrap! (contract-call? .level-ii burn level-II-id-2) ERR-BURN-SECOND)

    ;; Burn level-II-id-3
    (unwrap! (contract-call? .level-ii burn level-II-id-3) ERR-BURN-THIRD)
    
    ;; Mint level-III
    (try! (nft-mint? level-III current-level-III-index tx-sender))

    ;; Update level-III-index
    (ok (var-set level-III-index next-level-III-index))
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