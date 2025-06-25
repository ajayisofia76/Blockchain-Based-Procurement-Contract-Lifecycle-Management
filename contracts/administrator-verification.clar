;; Contract Administrator Verification
;; Manages who can create and modify procurement contracts

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_ADMIN (err u101))
(define-constant ERR_NOT_ADMIN (err u102))

;; Data Variables
(define-data-var contract-owner principal tx-sender)

;; Data Maps
(define-map administrators principal bool)
(define-map admin-details principal {
    name: (string-ascii 50),
    department: (string-ascii 50),
    added-at: uint,
    added-by: principal
})

;; Initialize contract owner as first admin
(map-set administrators tx-sender true)

;; Public Functions

;; Add a new administrator
(define-public (add-administrator (admin principal) (name (string-ascii 50)) (department (string-ascii 50)))
    (begin
        (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
        (asserts! (not (is-admin admin)) ERR_ALREADY_ADMIN)
        (map-set administrators admin true)
        (map-set admin-details admin {
            name: name,
            department: department,
            added-at: block-height,
            added-by: tx-sender
        })
        (ok true)
    )
)

;; Remove an administrator
(define-public (remove-administrator (admin principal))
    (begin
        (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
        (asserts! (is-admin admin) ERR_NOT_ADMIN)
        (asserts! (not (is-eq admin (var-get contract-owner))) ERR_UNAUTHORIZED)
        (map-delete administrators admin)
        (map-delete admin-details admin)
        (ok true)
    )
)

;; Read-only Functions

;; Check if a principal is an administrator
(define-read-only (is-admin (user principal))
    (default-to false (map-get? administrators user))
)

;; Get administrator details
(define-read-only (get-admin-details (admin principal))
    (map-get? admin-details admin)
)

;; Get contract owner
(define-read-only (get-contract-owner)
    (var-get contract-owner)
)
