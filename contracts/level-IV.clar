;; Level-IV NFT Contract
;; The 1/1 found in the "rover wallet" (wallet inscribed into rover)
;; Written by the ClarityClear team

;; Level-IV NFT
;; The level-IV NFT is a single 1/1 that'll be locked in the wallet inscribed on the rover
;; This is the final NFT required for a user to be "active" to claim the treasure stored on the moon

;;;;;;;;;;;;;;;;;;;;;
;; Contract Basics ;;
;;;;;;;;;;;;;;;;;;;;;
(impl-trait .sip-090-trait-nft-standard.sip-090-trait)

;; level-IV
(define-non-fungible-token level-IV uint)

;; constants
(define-constant level-IV-limit u2)
(define-constant contract-owner tx-sender)
(define-constant rover-wallet 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)

;; error messages
(define-constant ERR-ALL-MINTED (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-WRONG-COMMISSION (err u104))

;; vars
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGafbHbATvrP/pm_")
(define-data-var level-IV-index uint u1)

;; storage
(define-map market uint {price: uint, commission: principal})



;;;;;;;;;;;;;;;;;;;;;;
;; SIP009 Functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-last-token-id)
  (ok (var-get level-IV-index))
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? level-IV id))
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
    (nft-transfer? level-IV id sender recipient)
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
      (owner (unwrap! (nft-get-owner? level-IV id) false))
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
      (owner (unwrap! (nft-get-owner? level-IV id) ERR-NOT-AUTH))
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

;; @desc mint once & once only, send to rover wallet
(define-public (mint-level-IV)
  (begin

    ;; assert nft index < u2
    (asserts! (< (var-get level-IV-index) level-IV-limit) ERR-ALL-MINTED)

    ;; assert tx-sender is contract-owner
    (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTH)

    ;; directly to rover wallet/principal
    (try! (nft-mint? level-IV u1 rover-wallet))

    ;; increase collection index
    (ok (var-set level-IV-index (+ u1 (var-get level-IV-index))))

  )
)
