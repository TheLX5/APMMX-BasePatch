
;#########################################################################
;# SIN/COS TABLE

math round off

!n = 64
!m #= !n+(!n/4)
!i = 0

sincos:

while !i != !m
    dw sin((!i/!n)*6.28)*$100
    !i #= !i+1
endif