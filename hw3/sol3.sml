(* q1 and q2 *)
datatype pattern = Wildcard | Variable of string | UnitP 
                 | ConstP of int | TupleP of pattern list 
                 | ConstructorP of string * pattern

datatype valu = Const of int | Unit | Tuple of valu list
              | Constructor of string * valu


fun check_pat (p: pattern) =
  let
    fun listofvar(p) =
      case p of
           Variable v => [v]
         | ConstructorP(_, p') => listofvar(p')
         | TupleP ps => List.foldl (fn (p, ls) => (listofvar(p)) @ ls) [] ps
         | _ => []

    fun repeatedstr(xs) = 
      case xs of
           [] => true 
         | x::xs' => if (List.exists (fn x' => x = x') xs') 
                     then false
                     else repeatedstr(xs')
  in
    repeatedstr(listofvar(p))
  end
       

fun match (v: valu, p: pattern) = 
  case (v,p) of
       (_, Wildcard) => SOME []
     | (v, Variable s) => SOME [(s, v)]
     | (Unit, UnitP) => SOME []
     | (Const a, ConstP b) => if a = b then SOME [] else NONE
     | (Tuple vs, TupleP ps) => 
         let fun filter fx ls =
             let fun filter2 (ls', final) = 
               case ls' of
                 [] => SOME final
               | x::xs => case fx x of
                            NONE => NONE
                          | SOME list1 => filter2(xs, final @ list1)
               in 
                 filter2(ls,[])
             end
           in
             if List.length(vs) = List.length(ps)
             then filter match (ListPair.zip(vs,ps))
             else NONE 
         end
     | (Constructor(s2,v), ConstructorP(s1,p)) => if s1 = s2 
                                                  then match(v,p)
                                                  else NONE
     | _ => NONE


(* q3: rock paper scissors *)
type name = string

datatype RSP = 
               ROCK
             | SCISSORS
             | PAPER

datatype 'a strategy = Cons of 'a * (unit -> 'a strategy)

datatype tournament =
                      PLAYER of name * (RSP strategy ref)
                    | MATCH of tournament * tournament


fun onlyOne (one: RSP) = Cons(one, fn() => onlyOne(one))

fun alterTwo (one: RSP, two: RSP) = Cons(one, fn() => alterTwo(two, one))

fun alterThree (one:RSP, two: RSP, three: RSP) = Cons(one, fn() =>
  alterThree(two, three, one))

val r = onlyOne(ROCK)

val s = onlyOne(SCISSORS)

val p = onlyOne(PAPER)

val rp = alterTwo(ROCK, PAPER)

val sr = alterTwo(SCISSORS, ROCK)

val ps = alterTwo(PAPER, SCISSORS)

val srp = alterThree(SCISSORS, ROCK, PAPER)

fun next(strategyRef) =
  let val Cons(rsp, func) = !strategyRef 
    in
      strategyRef := func();
      rsp
  end
 

fun whosWinner(t) = 
  let
    fun aux(x, y) =
      case (x, y) of
           (PLAYER(a,b), MATCH(t1,t2)) => aux(PLAYER(a,b), aux(t1,t2))
         | (MATCH(t1,t2), PLAYER(a,b)) => aux(PLAYER(a,b), aux(t1,t2))
         | (MATCH(t1,t2), MATCH(t3,t4)) => aux(aux(t1,t2), aux(t3,t4))
         | (PLAYER(a, ref1), PLAYER(b, ref2)) => 
             let val r1 = next(ref1)
                 val r2 = next(ref2)
             in   
               if (r1 = r2) 
               then aux(PLAYER(a, ref1), PLAYER(b,ref2))
               else if ((r1 = ROCK andalso r2 = SCISSORS) orelse 
                 (r1 = SCISSORS andalso r2 = PAPER) orelse 
                 (r1 = PAPER andalso r2 = ROCK))
               then PLAYER(a, ref1)
               else PLAYER(b, ref2)
             end
  in
    case t of
         MATCH(t1, t2) => aux(t1, t2)
       | _ => t
  end
 


     
