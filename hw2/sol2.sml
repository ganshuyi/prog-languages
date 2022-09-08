(* q1 *)
datatype expr = NUM of int 
             | PLUS of expr * expr
             | MINUS of expr * expr

datatype formula = TRUE
                 | FALSE
                 | NOT of formula
                 | ANDALSO of formula * formula
                 | ORELSE of formula * formula
                 | IMPLY of formula * formula
                 | LESS of expr * expr

fun eval (x: formula) =
        case x of
             TRUE => true
           | FALSE => false
           | NOT(a) => if eval(a) then false else true
           | ANDALSO(a, b) => if eval(a) andalso eval(b) then true else false
           | ORELSE(a, b) => if eval(a) orelse eval(b) then true else false
           | IMPLY(a, b) => if eval(NOT(a)) orelse eval(b) then true else false 
           | LESS(NUM(i), NUM(j)) => if i < j then true else false
           | LESS(PLUS(NUM(i), NUM (j)), PLUS(NUM(k), NUM(l))) => 
               if ((i + j) < (k + l)) then true else false
           | LESS(MINUS(NUM(i), NUM(j)), MINUS(NUM(k), NUM(l))) => 
               if ((i - j) < (k - l)) then true else false
           | LESS(NUM(i), PLUS(NUM(j), NUM(k))) =>
               if i < (j + k) then true else false
           | LESS(NUM(i), MINUS(NUM(j), NUM(k))) =>
               if i < (j - k) then true else false
           | LESS(PLUS(NUM(i), NUM(j)), NUM(k)) =>
               if (i + j) < k then true else false
           | LESS(MINUS(NUM(i), NUM(j)), NUM(k)) =>
               if (i - j) < k then true else false
           | LESS(PLUS(NUM(i), NUM (j)), MINUS(NUM(k), NUM(l))) => 
               if ((i + j) < (k - l)) then true else false
           | LESS(MINUS(NUM(i), NUM(j)), PLUS(NUM(k), NUM(l))) => 
               if ((i - j) < (k + l)) then true else false


(* q2 *)
type name = string

datatype metro = STATION of name
               | AREA of name * metro
               | CONNECT of metro * metro

fun checkMetro (x: metro) =
 case x of
     AREA(a, STATION b) => if a = b then true else false
   | AREA(a, AREA b) => if checkMetro(AREA b) then true else false
   | AREA(a, CONNECT(STATION b, STATION c)) => if a = b orelse a = c then true else false
   | AREA(a, CONNECT(STATION b, AREA (c, STATION d))) => if a = b andalso a = d then true else false



(* q3 *)
datatype 'a lazyList = nullList
                     | cons of 'a * (unit -> 'a lazyList)

fun seq (first: int, last: int) = cons(first, fn() => if first >= last then nullList
                                                      else seq(first + 1, last))


fun infSeq (first: int) = cons(first, fn() => infSeq(first + 1))

fun firstN(nullList, _) = []
  | firstN(_, 0) = []
  | firstN(cons(x, xs), n) = x::firstN(xs(), n - 1)

fun Nth(nullList, _) = NONE
  | Nth(cons(x, xs), 1) = SOME x
  | Nth(cons(_, xs), n) = Nth(xs(), n - 1)

fun filterMultiples (nullList, _) = nullList
  | filterMultiples (cons(x, xs), n) =
  let
    val temp = x mod n 
    in 
      if temp <> 0
      then cons(x, fn() => filterMultiples (xs(), n))
      else filterMultiples (xs(), n)
  end

fun sieve (nullList) = nullList 
  | sieve (cons(x, xs)) = cons(x, fn() => sieve(filterMultiples(cons(x,xs),x)))

fun primes () = sieve(infSeq(2))
