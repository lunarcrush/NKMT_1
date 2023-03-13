;; Level-I NFT Contract
;; The 1st Level NFT in LunarCrush experience
;; Written by the StrataLabs team

;; Level-I NFT
;; 24k collection total, each NFT has one of four sub-types (u1,u2,u3,u4) & is sold for 255 STX
;; Each level-I NFT has one of four different "sub-types" (u1,u2,u3,u4). A user needs one of each sub-type to qualify for a level-II NFT

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Contract Basics ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Check contract adheres to SIP-009
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait .sip-09.sip-09-trait)

;; Define level-I NFT
(define-non-fungible-token level-I uint)


;;;;;;;;;;;;;;;
;; Constants ;;
;;;;;;;;;;;;;;;

;; Collection limit (24k)
(define-constant level-I-limit u24001)

;; Collection test price (.0255 STX)
(define-constant level-I-test-price u25500000)

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
(define-constant ERR-LIST-OVERFLOW (err u114))
(define-constant ERR-ALREADY-ADMIN (err u115))
(define-constant ERR-NOT-ADMIN (err u116))
(define-constant ERR-NFT-MINT (err u117))
(define-constant ERR-NFT-MINT-MAP (err u118))
(define-constant ERR-NFT-BURN (err u119))


;; storage
(define-map market uint {price: uint, commission: principal})
(define-map sub-type uint uint)


;;;;;;;;;;;;;;;;;;;;;
;; Admin Variables ;;
;;;;;;;;;;;;;;;;;;;;;

;; Admin list for minting
(define-data-var admin-list (list 10 principal) (list tx-sender))

;; Helper principal for removing an admin
(define-data-var admin-to-remove principal tx-sender)

;; Mint price -> trying to keep parity w/ $250 USD 
(define-data-var mint-price uint u100000000)

;; level-I basics
(define-data-var metadata-frozen bool true)
(define-data-var ipfs-root (string-ascii 102) "ipfs://ipfs/QmYcrELFT5c9pjSygFFXk8jfVMHB5cBoWJDGaTvrP/")
(define-data-var level-I-index uint u1)
(define-data-var level-I-subtype-index uint u1)


;;;;;;;;;;;;;;;;;;;;;
;; Read-Only Funcs ;;
;;;;;;;;;;;;;;;;;;;;;

;; Get current admins
(define-read-only (get-admins)
  (var-get admin-list)
)

;; Get item sub-type
(define-read-only (check-subtype (level-I-id uint))
    (map-get? sub-type level-I-id)
)

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
    (try! (nft-transfer? level-I id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-ustx", id: id}))
  )
)




;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Core Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
;; Public Mints ;;
;;;;;;;;;;;;;;;;;;

;; Mint x1 Level-I
;; @desc - public mint for a single Level-I NFT
(define-public (public-mint-1-level-I)
  (let 
      ( 
        (current-level-I-index (var-get level-I-index))
        (next-level-I-index (+ u1 (var-get level-I-index)))
        (current-level-I-subtype-index (var-get level-I-subtype-index))
      )

      ;; checking for level-I-index against entire level-I collection (24k)
      (asserts! (< current-level-I-index level-I-limit) ERR-ALL-MINTED)
    
      ;; Charge the user level-I-price
      (unwrap! (stx-transfer? (var-get mint-price) tx-sender (as-contract tx-sender)) ERR-STX-TRANSFER)

      ;; Mint 1 Level-I NFT
      (unwrap! (nft-mint? level-I current-level-I-index tx-sender) ERR-NFT-MINT)

      ;; Assign the next sub-type
      (map-insert sub-type current-level-I-index current-level-I-subtype-index)

      ;; Increment the level-I-subtype-index
      (var-set level-I-index next-level-I-index)

      ;; Increment the level-I-subtype-index
      (ok (assign-next-subtype))
  )
)

;; Mint x2 Level-I
;; @desc - public mint for two Level-I NFTs
(define-public (public-mint-2-level-I)
    (begin 
        (try! (public-mint-1-level-I))
        (ok (try! (public-mint-1-level-I)))
    )
)


;;;;;;;;;;;;;;;;;
;; Admin Mints ;;
;;;;;;;;;;;;;;;;;

;; Admin Mint Public
;; @desc - admin mint for up to 250 Level-I NFTs
;; @param - mint-count (list 250 uint): empty list of up to 250 uints for minting many
(define-public (admin-mint-public (mint-count (list 250 uint))) 
    (let
        (   
            (current-level-I-index (var-get level-I-index))
            (next-level-I-index (+ u1 (var-get level-I-index)))
            (current-level-I-subtype-index (var-get level-I-subtype-index))
            (mints-remaining (- level-I-limit (var-get level-I-index))) 
        )

        ;; Assert tx-sender is in admin-list using is-some & index-of
        (asserts! (is-some (index-of (var-get admin-list) tx-sender)) ERR-NOT-AUTH)

        ;; Assert that mint-count length is greater than u0 && that mint-count length is less than or equal to mints-remaining
        (asserts! (and (> (len mint-count) u0) (< (len mint-count) mints-remaining)) ERR-ALL-MINTED)

        ;; Private helper function to mint using map
        (ok (map admin-mint-private-helper mint-count))

    )
)

;; Admin Mint Private Helper
;; @desc - admin mint for a single Level-I NFT
(define-private (admin-mint-private-helper (id uint))
    (let
        (
            (current-level-I-index (var-get level-I-index))
            (next-level-I-index (+ u1 current-level-I-index))
            (current-level-I-subtype-index (var-get level-I-subtype-index))
        )

        ;; Mint NFT
        (unwrap! (nft-mint? level-I current-level-I-index tx-sender) ERR-NFT-MINT-MAP)

        ;; Update level-I-index
        (var-set level-I-index next-level-I-index)

        ;; Assign sub-type
        (map-insert sub-type current-level-I-index current-level-I-subtype-index)

        ;; Update level-I-subtype-index
        (ok (assign-next-subtype))

    )
)

;;;;;;;;;;;;;;;;;;;
;; Burn Function ;;
;;;;;;;;;;;;;;;;;;;
;; @desc - burn function for Level-I NFTs
;; @param - id (uint): id of NFT to burn
(define-public (burn (id uint))
    (let
        (
            (owner (unwrap! (nft-get-owner? level-I id) ERR-NOT-AUTH))
        )

        ;; Assert tx-sender is owner of NFT
        (asserts! (is-eq tx-sender owner) ERR-NOT-AUTH)

        ;; Burn NFT
        (ok (unwrap! (nft-burn? level-I id tx-sender) ERR-NFT-BURN))

    )
)

;;;;;;;;;;;;;
;; Helpers ;;
;;;;;;;;;;;;;

;; @desc sub-type helper function - helps assign sub-types of type 1,2,3,4 when minted
(define-private (assign-next-subtype)
  (let
    (
      (current-subtype (var-get level-I-subtype-index))
    )
      (if (is-eq current-subtype u1)
          (var-set level-I-subtype-index u2)
          (if (is-eq current-subtype u2)
            (var-set level-I-subtype-index u3)
            (if (is-eq current-subtype u3)
              (var-set level-I-subtype-index u4)
              (var-set level-I-subtype-index u1)
            )
          )
      )
 )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Admin Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Update Mint Price
;; @desc - function for any of the admins to var-set the mint price
;; @param - new-mint-price (uint): new mint price
(define-public (update-mint-price (new-mint-price uint))
  (let
    (
      (current-admin-list (var-get admin-list))
    )
    ;; asserts tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; var-set new mint price
    (ok (var-set mint-price new-mint-price))
  )
)

;; Unlock Contract STX
;; @desc - function for any of the admins to transfer STX out of contract
;; @param - amount (uint): amount of STX to transfer, recipient (principal): recipient of STX
(define-public (unlock-contract-stx (amount uint) (recipient principal))
  (let
    (
      (current-admin-list (var-get admin-list))
      (current-admin tx-sender)
    )
    ;; asserts tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; transfer STX
    (ok (unwrap! (as-contract (stx-transfer? amount tx-sender recipient)) ERR-STX-TRANSFER))
  )
)

;; Add New Admin
;; @desc function for admin to add new principal to admin list
;; @param - new-admin(principal): new admin principal
(define-public (add-admin (new-admin principal))
  (let
    (
      (current-admin-list (var-get admin-list))
    )
    ;; asserts tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; asserts new admin is not already an admin
    (asserts! (is-none (index-of current-admin-list new-admin)) ERR-ALREADY-ADMIN)

    ;; update (var-set) admin list by appending current-admin-list with new-admin, using as-max-len to ensure max 10 admins
    (ok (var-set admin-list (unwrap! (as-max-len? (append current-admin-list new-admin) u10) ERR-LIST-OVERFLOW)))
  )
)

;; Remove New Admin
;; @desc function for removing an admin principal from the admin list
;; @param - new-admin(principal): new admin principal
(define-public (remove-admin (removed-admin principal))
  (let
    (
      (current-admin-list (var-get admin-list))
    )
    ;; asserts tx-sender is an admin using is-some & index-of
    (asserts! (is-some (index-of current-admin-list tx-sender)) ERR-NOT-AUTH)

    ;; asserts admin to remove is an admin
    (asserts! (is-some (index-of current-admin-list removed-admin)) ERR-NOT-ADMIN)

    ;; Var-set helper-principal to removed-admin
    (var-set admin-to-remove removed-admin)

    ;; update (var-set) admin list by filtering out admin-to-remove using filter
    (ok (var-set admin-list (filter filter-admin-principal current-admin-list)))

  )
)

;; Private helper function to filter out admin-to-remove
(define-private (filter-admin-principal (admin-principal principal))
  (if (is-eq admin-principal (var-get admin-to-remove))
    false
    true
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