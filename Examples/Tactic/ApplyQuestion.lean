/- # apply?

`apply?` は、カレントゴールを `apply` や [`refine`](./Refine.md) で変形することができないか、ライブラリから検索して提案してくれるタクティクです。
複数の候補が提案されたときは、どれを選ぶとゴールが何に変わるのか表示されるので、その中から好ましいものを選ぶと良いでしょう。-/
import Mathlib.Algebra.Algebra.Basic -- 群を使うのに必要
import Mathlib.Tactic.Says -- `says` を使うのに必要

set_option says.verify true

variable (G H : Type)

/-- 群順同型が積を保つという定理 -/
example [Group G] [Group H] (f : G →* H) (a b : G) :
    f (a * b) = f a * f b := by
  -- `exact MonoidHom.map_mul f a b` を提案してくれる
  apply? says exact MonoidHom.map_mul f a b

/-
## 補足

`apply?` はあくまで証明を書くときに補助として使うものです。
`sorry` と同じように、清書した証明に残してはいけません。
`sorry` と同じと言いましたが、実際 `apply?` は `sorryAx` を裏で使用します。
-/
set_option linter.unusedTactic false in --#

#guard_msgs (drop warning) in --#
theorem T (x y : Nat) (_: x ≤ y) : 8 ^ x ≤ 16 ^ y := by
  apply?

  -- `apply?` しただけで `done` が通り、示せているように見える
  done

/-- info: 'T' depends on axioms: [propext, sorryAx] -/
#guard_msgs in #print axioms T
