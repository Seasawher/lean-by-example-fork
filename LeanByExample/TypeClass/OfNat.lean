/- # OfNat
`OfNat` 型クラスは、`0` や`1` などの数値リテラルを特定の型の値として解釈する方法を指定します。
-/
/-- 偶数全体 -/
inductive Even where
  | zero
  | addTwo (n : Even)

-- まだ `OfNat` のインスタンスがないので、
-- `0` という数値リテラルを `Even` 型の値として解釈することはできない
#check_failure (0 : Even)

/-- `0` という数値リテラルを `Even` の項として解釈する方法を指定 -/
instance : OfNat Even 0 where
  ofNat := Even.zero

-- エラーがなくなった
#check (0 : Even)

/- `0` や `1` などの特定の数値リテラルに対して個別に宣言するだけでなく、変数を使って一斉に `OfNat` のインスタンスを宣言することもできます。-/

/-- 有理数もどき。
約分したら等しいものは等しいというルールがないので有理数ではない -/
structure Rational where
  num : Int
  den : Nat
  inv : den ≠ 0

/-- 数値リテラル `n` を有理数として解釈する方法を指定 -/
instance (n : Nat) : OfNat Rational n where
  ofNat := { num := n, den := 1, inv := by decide }

-- 数値リテラルを `Rational` の意味で使用できる！
#check (2 : Rational)
#check (42 : Rational)

/- 特定の数値リテラルに対してだけ `OfNat` を実装しないということもできます。-/

/-- 正の自然数 -/
inductive Pos where
  | one
  | succ (n : Pos)

/-- 自然数 `n` を `n + 1` に相当する `Pos` の項に写す -/
def Pos.ofNatPlus (n : Nat) : Pos :=
  match n with
  | 0 => Pos.one
  | n + 1 => Pos.succ (Pos.ofNatPlus n)

/-- 数値リテラル `1, 2, 3, ...` に対して `Pos` の項と解釈する方法を指定 -/
instance (n : Nat) : OfNat Pos (n + 1) where
  ofNat := Pos.ofNatPlus n

-- エラーにならない
#check (1 : Pos)
#check (8 : Pos)
#check (42 : Pos)

-- `0` は除外したのでエラーになる
#check_failure (0 : Pos)

/- ## 応用例

`OfNat` の応用として、[`macro`](#{root}/Declarative/Macro.md) コマンドと組み合わせることで数値リテラル `n` を `1 + 1 + ⋯ + 1` (`n` 個の `1` の和) に分解するタクティクを自作することができます。[^expand]
-/

theorem unfoldNat (x : Nat) : OfNat.ofNat (x + 2) = OfNat.ofNat (x + 1) + 1 :=
  rfl

theorem unfoldNatZero (x : Nat) : OfNat.ofNat (0 + x) = x :=
  Nat.zero_add x

/-- 自然数を `1 + 1 + ⋯ + 1` に分解する -/
macro "expand_num" : tactic => `(tactic| simp only [unfoldNat, unfoldNatZero])

example (n : Nat) : 3 * n = 2 * n + 1 * n := by
  expand_num

  -- 数値が `1 + 1 + ⋯ + 1` に分解された
  guard_target =ₛ (1 + 1 + 1) * n = (1 + 1) * n + 1 * n

  simp only [Nat.add_mul]

/- [^expand]: このコード例は、Lean 公式 Zulip の [expand_nums tactic](https://leanprover.zulipchat.com/#narrow/channel/217875-Is-there-code-for-X.3F/topic/expand_nums.20tactic/near/504627783) トピックにおける Robin Arnez 氏の投稿を参考にしています。 -/
