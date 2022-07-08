;; LunarCrush Support Contract
;; Support contract for the entire LunarCrush/Voyager experience.
;; Written by the ClarityClear team.

;; User
;; There is a map titled "user" that tracks the mint count for each of the 3 levels
;; There is 1 read-only function (get-user-minted-tuple) & 3 support functions (one for handling an increase in each level)

;; Uint-to-ascii
;; There is 1 helper read-only function that helps all three level NFT contracts when concatenating during (get-uri) funcs

;;;;;;;;;;;;;;;;;;;;;;;;
;; Contract Constants ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; error messages
(define-constant ERR-NOT-AUTH (err u101))



;;;;;;;;;;;;;;;;;;;;;
;; Utility Storage ;;
;;;;;;;;;;;;;;;;;;;;;

;; @desc map of all mints that a user made; this is *not* a live balance, it's tracker of total mints
;; @param principal; the identifier here is an individual wallet
(define-map user principal
  {
    minted-level-Is: uint,
    minted-level-IIs: uint,
    minted-level-IIIs: uint,
  }
)



;;;;;;;;;;;;;;;;;;;;;
;; Read Only Funcs ;;
;;;;;;;;;;;;;;;;;;;;;

;; @desc map that tracks all mints per user across the first 3 level NFTs - it this is *not* a live balance, it's tracker of total mints
(define-read-only (get-user-minted-tuple)
  (default-to
    {
      minted-level-Is: u0,
      minted-level-IIs: u0,
      minted-level-IIIs: u0
    }
  (map-get? user tx-sender))
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; User Mint Count Funcs ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc utility function that updates the "minted" tuple value of level-Is for the tx-sender, only callable by .level-I contract
(define-public (update-user-level-I-mint-count)
  (let
    (
      (user-minted-tuple (get-user-minted-tuple))
      (level-Is-minted (get minted-level-Is user-minted-tuple))
    )
    (asserts! (is-eq contract-caller .level-I) ERR-NOT-AUTH)
    (ok (map-set user tx-sender
      (merge user-minted-tuple {minted-level-Is: (+ u1 level-Is-minted)})
    ))
  )
)

;; @desc utility function that updates the "minted" tuple value of level-IIs for the tx-sender, only callable by .level-II contract
(define-public (update-user-level-II-mint-count)
  (let
    (
      (user-minted-tuple (get-user-minted-tuple))
      (level-IIs-minted (get minted-level-IIs user-minted-tuple))
    )
    (asserts! (is-eq contract-caller .level-II) ERR-NOT-AUTH)
    (ok (map-set user tx-sender
      (merge user-minted-tuple {minted-level-IIs: (+ u1 level-IIs-minted)})
    ))
  )
)

;; @desc utility function that updates the "minted" tuple value of level-IIIs for the tx-sender, only callable by .level-III contract
(define-public (update-user-level-III-mint-count)
  (let
    (
      (user-minted-tuple (get-user-minted-tuple))
      (level-IIIs-minted (get minted-level-IIIs user-minted-tuple))
    )
    (asserts! (is-eq contract-caller .level-III) ERR-NOT-AUTH)
    (ok (map-set user tx-sender
      (merge user-minted-tuple {minted-level-IIIs: (+ u1 level-IIIs-minted)})
    ))
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
