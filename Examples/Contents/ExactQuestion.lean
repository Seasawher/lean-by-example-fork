/- # exact?

`exact?` は，カレントゴールを `exact` で閉じることができないか，ライブラリから検索して提案してくれるタクティクです．閉じることができなければ，エラーになります．-/
import Mathlib.Algebra.Order.Floor -- `Nat.floor` を使うために必要
import Mathlib.Data.Rat.Floor -- `ℚ` の性質を使うために必要
import Mathlib.Tactic.Says -- `says` を使うために必要

variable (P Q R : Prop)

-- `says` のチェックを有効にする --#
set_option says.verify true --#

-- `exact?` はライブラリ検索を行う
example (x : Nat) : x < x + 1 := by
  exact? says
    exact lt_add_one x

-- ローカルコンテキストにある仮定を自動で使ってゴールを導いてくれる
example (hPQ : P → Q) (hQR : Q → R) (hQ : P) : R := by
  exact? says
    exact hQR (hPQ hQ)

/- `exact? using h` とするとローカルコンテキストにある仮定 `h` を使用してほしいと明示的に指定することができます．-/

example (h1 : P) (_h2 : P) : P := by
  -- `h1` を指定すると `h2` は使わない
  exact? using h1 says
    exact h1

example (_h1 : P) (h2 : P) : P := by
  -- `h2` を指定すると `h1` は使わない
  exact? using h2 says
    exact h2

/-!
## exact? を使用する際のコツ

これは `exact?` に限らず, Lean でライブラリ検索を行うとき常に意識した方が良いことですが，
強すぎる仮定を使用していたり表現が具体的過ぎたりすると上手くいかないことがあります.
適切な抽象化を心掛けてください．
-/

variable (n : ℕ) (a : ℚ)

example (h : ↑ n < a) : n ≤ Nat.floor a := by
  -- ここで単に `exact?` しても通らない
  fail_if_success exact?

  -- 仮定の `<` が強すぎる．
  -- 結論を成り立たせるには `≤` で十分．
  suffices ↑ n ≤ a from by
    -- そうすると `exact?` が通るようになる
    exact? says
      exact Nat.le_floor this

  -- 後は `<` から `≤` を示せばよいだけ
  show ↑n ≤ a
  exact LT.lt.le h
