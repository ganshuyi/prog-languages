(* failed
  fun merge (x: int list, y: int list) =
  if null x
  then y
  else if hd(x) < hd(y)
  then hd(x) :: merge(tl(x), y)
  else hd(y) :: merge(tl(y), x)
  *)

fun merge ([], y) = y
  | merge (a::x, b::y) = if a < b
                         then a::merge(x,b::y)
                         else b::merge(a::x,y)
(*  works
fun reverse (x: int list) =
  if null x
  then []
  else List.last(x) :: reverse(List.take(x, length(x) - 1)) 
  *)

(* better ver *)
fun reverse(xs) = 
  let fun aux(xs, acc) =
    case xs of 
        [] => acc
      | x::xs' => aux(xs', x::acc)
  in aux(xs,[])
  end 

(*fun test (x: int) = 1 + x*)

fun pi (a: int, b: int, f: int -> int) =
  if a > b
  then 1
  else f(a) * pi(a + 1, b, f)
 
fun digits (x: int) : int list =
  if x = 0
  then []
  else digits(x div 10) @ [x mod 10] 

fun additivePersistence (x: int) = 
  let fun sumList (xs: int list) = 
        if null xs
        then 0
        else hd(xs) + sumList(tl(xs))
  in
    let fun counting (x: int, count: int) =
        if x < 10
        then count 
        else counting(sumList(digits(x)), count + 1)
    in
        counting(x, 0)
    end
  end 

 
fun digitalRoot (x: int) =
  if x < 10
  then x
  else 
    let fun sumList (xs: int list) =
        if null xs
        then 0
        else hd(xs) + sumList(tl(xs))
    in
      digitalRoot(sumList(digits(x)))
    end

