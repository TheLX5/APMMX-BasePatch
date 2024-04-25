pushpc
    org $809AF7
        padbyte $EA : pad $809B04
    org $809ADF
        padbyte $EA : pad $809AE1

    org $81852E
        nop #2
    org $818173
        nop #2
    org $849D0F
        nop #2
    org $84A475
        nop #2
    org $81A2AE
        bra $03
    org $81A4F2
        bra $03
    org $82E419
        bra $04
    org $848FD5
        bra $03
    org $84A3C7
        bra $03
    org $889854
        bra $05
pullpc