.equ   MPIDR_AFFINITY_MASK, 0x3
.equ   PERIPHERAL_BASE,   0x3F000000
.equ   GPIO_BASE,         (PERIPHERAL_BASE + 0x200000)
.equ   GPFSEL1,           (GPIO_BASE + 0x04)
.equ   GPFSEL2,           (GPIO_BASE + 0x08)
.equ   GPSET0,            (GPIO_BASE + 0x1C)
.equ   GPCLR0,            (GPIO_BASE + 0x28)

.section ".text.boot"
.global _start

_start:
    mrs     x0, mpidr_el1
    and     x0, x0, #MPIDR_AFFINITY_MASK
    cbnz    x0, park_core

    ldr     x0, =_start
    mov     sp, x0

gpio_setup:
    ldr x0, =GPFSEL1
    ldr w1, [x0]
    bic w1, w1, #(7 << 21)
    orr w1, w1, #(1 << 21)
    bic w1, w1, #(7 << 24)
    orr w1, w1, #(1 << 24)
    str w1, [x0]

    ldr x0, =GPFSEL2
    ldr w1, [x0]
    bic w1, w1, #(7 << 6)
    orr w1, w1, #(1 << 6)
    bic w1, w1, #(7 << 9)
    orr w1, w1, #(1 << 9)
    str w1, [x0]

    mov w4, #0

main_loop:
    ldr     x0, =GPCLR0
    mov     w1, #0
    orr     w1, w1, #(1 << 17)
    orr     w1, w1, #(1 << 18)
    orr     w1, w1, #(1 << 22)
    orr     w1, w1, #(1 << 23)
    str     w1, [x0]

    mov     w1, w4

    and     w2, w1, #1
    lsl     w2, w2, #17

    and     w3, w1, #2
    lsr     w3, w3, #1
    lsl     w3, w3, #18

    and     w5, w1, #4
    lsr     w5, w5, #2
    lsl     w5, w5, #22

    and     w6, w1, #8
    lsr     w6, w6, #3
    lsl     w6, w6, #23

    orr     w1, w2, w3
    orr     w1, w1, w5
    orr     w1, w1, w6

    ldr     x0, =GPSET0
    str     w1, [x0]

    bl      delay

    add     w4, w4, #1
    cmp     w4, #16
    b.lt    main_loop
    mov     w4, #0
    b       main_loop

delay:
    mov     x10, #0x40000
d1:
    subs    x10, x10, #1
    b.ne    d1
    ret

park_core:
    wfe
    b       park_core
