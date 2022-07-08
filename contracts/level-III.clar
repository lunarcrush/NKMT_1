;; Level-III NFT Contract
;; The 3rd Level NFT in LunarCrush experience
;; Written by the ClarityClear team

;; Level-III NFT
;; The level-III NFT has a collection limit of 2k. All 6k are derived from a tx-sender "burning" exactly 3 level-IIs of different sub-types
;; This is the final NFT required for a user to be "active" to claim the treasure stored on the moon

;;;;;;;;;;;;;;;;;;;;;
;; Contract Basics ;;
;;;;;;;;;;;;;;;;;;;;;
(impl-trait .sip-090-trait-nft-standard.sip-090-trait)
;; level-III
(define-non-fungible-token level-III uint)

;; constants
(define-constant level-III-limit u6000)
(define-constant contract-owner tx-sender)

;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))
(define-constant ERR-INCORRECT-SUBTYPES (err u105))

;; vars
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGafbHbATvrP/pm_")
(define-data-var level-III-index uint u0)

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
    (try! (transfer id owner tx-sender))
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
      (next-level-III-index (+ u1 (var-get level-III-index)))
      (nft-0-subtype (default-to u3 (contract-call? .level-II check-subtype level-II-id-1)))
      (nft-1-subtype (default-to u3 (contract-call? .level-II check-subtype level-II-id-2)))
      (nft-2-subtype (default-to u3 (contract-call? .level-II check-subtype level-II-id-3)))
      (subtype-total (fold + (list nft-0-subtype nft-1-subtype nft-2-subtype) u0))
    )
    (asserts! (< (var-get level-III-index) level-III-limit) ERR-ALL-MINTED)
    (asserts! (is-eq subtype-total u3) ERR-INCORRECT-SUBTYPES)
    (unwrap-panic (contract-call? .level-II transfer level-II-id-1 tx-sender .admin))
    (unwrap-panic (contract-call? .level-II transfer level-II-id-2 tx-sender .admin))
    (unwrap-panic (contract-call? .level-II transfer level-II-id-3 tx-sender .admin))
    (try! (nft-mint? level-III (var-get level-III-index) tx-sender))
    (ok (var-set level-III-index next-level-III-index))
  )
)
