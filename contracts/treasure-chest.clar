;; Treasure Chest Contract
;; The Moon 1/1
;; Written by the ClarityClear team

;; Level-IV NFT
;; The level-IV NFT is a single 1/1 that'll be locked in the wallet inscribed on the rover
;; This is the final NFT required for a user to be "active" to claim the treasure stored on the moon

(use-trait nft .sip-090-trait-nft-standard.sip-090-trait)
(use-trait ft .sip-010-trait-nft-standard.sip-010-trait)

;; error messages
(define-constant ERR-NOT-AUTH (err u101))
(define-constant ERR-NOT-LISTED (err u102))
(define-constant ERR-WRONG-COMMISSION (err u103))
(define-constant ERR-UNWRAPPING (err u104))
(define-constant ERR-NOT-OWNER (err u105))
(define-constant ERR-CLAIM-EMPTY (err u106))

;;;;;;;;;;;;;;;
;; Chest Key ;;
;;;;;;;;;;;;;;;
;; @desc - public address of the winning wallet, only wallet that can unlock this treasure chest
(define-constant chest-key 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)

;;;;;;;;;;;;;;;
;; Claim STX ;;
;;;;;;;;;;;;;;;
;; @desc - function for claiming all STX currently held in treasure chest
(define-public (claim-stx (id uint))
  (begin

    ;; Check that tx-sender is chest-key
    (asserts! (is-eq tx-sender chest-key) ERR-NOT-AUTH)

    ;; Check that tx-sender is owner of level III NFT (by id)
    (asserts! (is-eq (some tx-sender) (unwrap! (contract-call? .level-III get-owner id) ERR-UNWRAPPING)) ERR-NOT-OWNER)

    ;; Check that contract stx balance is > 0
    (asserts! (> (stx-get-balance (as-contract tx-sender)) u0) ERR-CLAIM-EMPTY)

    ;; Send stx to chest-key
    (ok (try! (stx-transfer? (stx-get-balance (as-contract tx-sender)) (as-contract tx-sender) chest-key)))
  )
)

;;;;;;;;;;;;;;;
;; Claim FT ;;;
;;;;;;;;;;;;;;;
;; @desc - function for claiming any type of FT currently held in treasure chest
(define-public (claim-ft (treasure-ft <ft>) (id uint))
  (let
    (
      (ft-balance (unwrap! (contract-call? treasure-ft get-balance (as-contract tx-sender)) ERR-UNWRAPPING))
    )

    ;; Check that tx-sender is chest-key
    (asserts! (is-eq tx-sender chest-key) ERR-NOT-AUTH)

    ;; Check that tx-sender is owner of level III NFT (by id)
    (asserts! (is-eq (some tx-sender) (unwrap! (contract-call? .level-III get-owner id) ERR-UNWRAPPING)) ERR-NOT-OWNER)

    ;; Check that contract ft balance is > 0
    (asserts! (> ft-balance u0) ERR-CLAIM-EMPTY)

    ;; Send ft to chest-key
    (ok (try! (contract-call? treasure-ft transfer ft-balance (as-contract tx-sender) chest-key none)))
  )
)

;;;;;;;;;;;;;;;
;; Claim NFT ;;
;;;;;;;;;;;;;;;
;; @desc - function for claiming any type of NFT currently held in treasure chest
(define-public (claim-nft (treasure-nft <nft>) (chest-key-id uint) (nft-id uint))
  (begin

    ;; Check that tx-sender is chest-key
    (asserts! (is-eq tx-sender chest-key) ERR-NOT-AUTH)

    ;; Check that tx-sender is owner of level III NFT (by id)
    (asserts! (is-eq (some tx-sender) (unwrap! (contract-call? .level-III get-owner chest-key-id) ERR-UNWRAPPING)) ERR-NOT-OWNER)

    ;; Check that this contract is owner of nft-id
    (asserts! (is-eq (some tx-sender) (unwrap! (contract-call? treasure-nft get-owner chest-key-id) ERR-UNWRAPPING)) ERR-NOT-OWNER)

    ;; Send ft to chest-key
    (ok (try! (contract-call? treasure-nft transfer nft-id (as-contract tx-sender) chest-key)))
  )
)
