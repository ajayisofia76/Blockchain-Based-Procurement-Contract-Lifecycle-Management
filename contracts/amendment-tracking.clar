;; Amendment Tracking
;; Tracks all amendments made to procurement contracts

;; Constants
(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_CONTRACT_NOT_FOUND (err u301))
(define-constant ERR_INVALID_AMENDMENT (err u302))

;; Data Variables
(define-data-var amendment-counter uint u0)

;; Data Maps
(define-map amendments uint {
    contract-id: uint,
    amendment-type: (string-ascii 50),
    old-value: (string-ascii 200),
    new-value: (string-ascii 200),
    reason: (string-ascii 300),
    amended-by: principal,
    amended-at: uint,
    approved: bool
})

(define-map contract-amendments uint (list 50 uint))

;; Public Functions

;; Create an amendment
(define-public (create-amendment
    (contract-id uint)
    (amendment-type (string-ascii 50))
    (old-value (string-ascii 200))
    (new-value (string-ascii 200))
    (reason (string-ascii 300)))
    (let ((amendment-id (+ (var-get amendment-counter) u1)))
        (begin
            ;; Create amendment record
            (map-set amendments amendment-id {
                contract-id: contract-id,
                amendment-type: amendment-type,
                old-value: old-value,
                new-value: new-value,
                reason: reason,
                amended-by: tx-sender,
                amended-at: block-height,
                approved: false
            })

            ;; Add to contract amendments list
            (match (map-get? contract-amendments contract-id)
                existing-amendments
                    (map-set contract-amendments contract-id
                        (unwrap! (as-max-len? (append existing-amendments amendment-id) u50) ERR_INVALID_AMENDMENT))
                (map-set contract-amendments contract-id (list amendment-id))
            )

            ;; Update counter
            (var-set amendment-counter amendment-id)
            (ok amendment-id)
        )
    )
)

;; Approve an amendment
(define-public (approve-amendment (amendment-id uint))
    (match (map-get? amendments amendment-id)
        amendment-data (begin
            (map-set amendments amendment-id (merge amendment-data { approved: true }))
            (ok true)
        )
        ERR_CONTRACT_NOT_FOUND
    )
)

;; Read-only Functions

;; Get amendment details
(define-read-only (get-amendment (amendment-id uint))
    (map-get? amendments amendment-id)
)

;; Get all amendments for a contract
(define-read-only (get-contract-amendments (contract-id uint))
    (map-get? contract-amendments contract-id)
)

;; Get amendment count
(define-read-only (get-amendment-count)
    (var-get amendment-counter)
)
