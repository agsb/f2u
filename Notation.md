# Notation

## 1. FORTH comments as in braces, useally shows stack as described : (github.com/phf/forth/blob/master/arm/armforth.S)

          pre      post
          vvvvv    vvv
    WORD (a b c -- d e)
              ^      ^
            top    top

WORD expects c on top, then b below c, then a below b
WORD leaves e on top, then d below e

## 2. To translate forth names to assembler names, I prefer use prefix or sufix as:
    
    use LE for <=
    use GE for >=
    use NE for <>
    use LT for <
    use GT for >
    use EQ for =

    use MUL for *
    use DIV for /
    use PLUS for +
    use MINUS for -

    use BY for /
    use QM for ?
    use AT for @
    use TO for !
    use TK for '
    use CM for ,
    !use DT for .

    use NIL for 0
    use ONE for 1
    use TWO for 2
    use OCT for 8
    use TEN for 10
    use HEX for 16

    

