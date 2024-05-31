/- # set

Lean ではローカル変数の定義には `let` を使いますが，`let` だと

* ゴールやローカルコンテキストにある命題を導入した定義に基づいて書き換えてくれない
* たとえば `let y := f x` としたとき，`y = f x` という命題の証明にアクセスできない

という不満があります．

こうした不満に対応するのが `set` タクティクです． -/
import Mathlib.Tactic.Set -- `set` のために必要

-- 変数が未使用という警告を表示しない
set_option linter.unusedVariables false

abbrev ℕ := Nat

variable (X : Type) (f : ℕ → ℕ)

example (x : ℕ) (h : f x = x) : f (f x) = f x := by
  -- `let` を使用した場合
  try
    let y := f x

    -- ゴールは `⊢ f (f x) = f x` のままで，
    -- 導入した `y` を用いて書き換えてくれない
    show f (f x) = f x

    fail

  set y := f x with yh

  -- ゴールが書き換わる
  show f y = y

  -- 仮定も書き変わる
  guard_hyp h : y = x

  -- `y = f x` であるという事実に名前も付いている
  guard_hyp yh : y = f x

  rw [h] at *
  apply yh.symm
