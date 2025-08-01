/- # rw

`rw` は rewrite（書き換え）を行うタクティクです。等式や同値関係をもとに書き換えを行います。

`hab : a = b` や `hPQ : P ↔ Q` がローカルコンテキストにあるとき、`rw` は以下のような動作をします。

* `rw [hab]` でゴールの中の `a` をすべて `b` に置き換える。
* `rw [hPQ]` でゴールの中の `P` をすべて `Q` に置き換える。

複数の仮定 `h1, h2, ...` について続けて置き換えを行いたいときは、`rw [h1, h2, ...]` のようにします。
-/

variable {a b c d e f : Nat}

-- 等式による置き換えの例
example (ha : a + 0 = a) (hb : b * b = 0) (hc : c + c = 0)
    : a + 0 + b * b = a + (c + c) := by
  -- `a + 0` を `a` に置き換える
  rw [ha]

  -- 複数ルールについて書き換え
  rw [hb, hc]

-- 同値関係に基づいて書き換えを行う例
example (P Q : Prop) (h : P ↔ P ∧ Q) : P → Q := by
  intro (hP : P)
  rw [h] at hP

  -- `P ↔ P ∧ Q` で書き換えを行ったので、
  -- `P` が `P ∧ Q` に置き換わった
  guard_hyp hP : P ∧ Q

  exact hP.right

/- ## 利用可能な構文
### 右辺を左辺に書き換える

順番は重要で、`b` を `a` に置き換えたいときなどは `rw [← hab]` のように `←` をつけます。 -/

example (h : a = b) (hb : a + 3 = 0) : b + 3 = 0 := by
  -- `rw [h]` だと `a` を `b` に置き換えるという意味になり、失敗する
  fail_if_success rw [h]

  -- `←` をつけて逆向きにすれば通る
  rw [← h]

  assumption

/- ### 書き換え場所の指定

`rw` は [at 構文](#{root}/Parser/AtLocation.md) を受け入れます。ゴールではなく、ローカルコンテキストにある `h : P` を書き換えたいときには `at` をつけて `rw [hPQ] at h` とします。すべての箇所で置き換えたいときは `rw [hPQ] at *` とします。

また、ゴールとローカルコンテキストの仮定 `h` に対して同時に書き換えたいときは `⊢` 記号を使って `rw [hPQ] at h ⊢` のようにします。-/

example (h : a + 0 = a) (_h1 : b + (a + 0) = b + a) (_h2 : a + (a + 0) = a)
    : a + 0 = 0 + a := by
  -- ローカルコンテキストとゴールのすべてに対して書き換えを行う
  rw [h] at *

  simp

example (h : a * b = c * d) (h' : e = f + 0) : a * (b * e + 0) = c * (d * f) := by
  -- ゴールとローカルコンテキストの両方に対して書き換えを行う
  rw [Nat.add_zero] at h' ⊢

  rw [h']

  -- 結合法則を使う
  rw [← Nat.mul_assoc, h]

  -- 結合法則を使う
  ac_rfl

/- ## rw の制約

### 変数束縛
`rw` は、変数束縛の下では使うことができません。代わりに [`simp`](./Simp.md) タクティクなどを使用してください。
-/

example (f g : Nat → Nat) (h : ∀ a, f (a + 0) = g a) : f = g := by
  ext x

  -- rw は失敗する
  fail_if_success rw [Nat.add_zero] at h

  -- simp は成功する
  simp only [Nat.add_zero] at h

  exact h x

/- ### nth_rw

`rw` は何も設定しないとマッチした項をすべて置き換えてしまいます。-/

example {P Q : Prop} (h : P ↔ Q) (hq : Q) : P ∧ P ∧ P ∧ P := by
  -- 単に `rw` するとすべて置き換わる
  rw [h]

  guard_target =ₛ Q ∧ Q ∧ Q ∧ Q

  simp [hq]

/- このとき `config` を適切に渡すことで、指定した `n` 番目の出現だけを書き換えることができます。 -/

example {P Q : Prop} (h : P ↔ Q) (hq : Q) : P ∧ P ∧ P ∧ P := by
  rw (config := {occs := .pos [2]}) [h]

  -- 2番目の出現だけが置き換わる
  guard_target =ₛ P ∧ Q ∧ P ∧ P

  simp [h, hq]

/- `config` を渡さなくても、[`nth_rw`](./NthRw.md) が使用できればそれによって同じことができます。 -/

/- ### ローカル変数の展開
`rw` はローカル変数の展開を行うことができません。代わりに [`dsimp`](./Dsimp.md) タクティクなどを使用してください。-/

/-- 5未満の自然数が存在する -/
example : ∃ x : Nat, x < 5 := by
  let n := 2
  have h : n < 5 := by
    -- rw はローカル変数の展開は行わない
    fail_if_success rw [n]

    -- dsimp で展開できる
    dsimp [n]

    -- あとは 2 < 5 を示せばよいだけ
    guard_target =ₛ 2 < 5
    decide

  exact ⟨n, h⟩

/- ### 一般の同値関係の書き換えはできない

`rw` で書き換えることができるのは等式と論理的な同値関係だけです。一般の同値関係による書き換えはできません。
-/


def add_equiv (c₁ c₂ : Nat) : Prop :=
  ∀ n : Nat, c₁ + n = c₂ + n

/-- `Nat`上の同値関係 -/
@[instance]
def add_setoid : Setoid Nat where
  r := add_equiv
  iseqv := by
    constructor
    · grind [add_equiv]
    · grind [add_equiv]
    · intro x y z h₁ h₂ n
      have := h₁ n
      have := h₂ n
      rw [h₁, h₂]

set_option warn.sorry false in --#
theorem add_equiv_trans {c₁ c₂ c₃ : Nat} (h₁ : c₁ ≈ c₂) (h₂ : c₂ ≈ c₃) : (c₁ ≈ c₃) := by
  -- `rw`が成功しない
  fail_if_success rw [h₁]
  sorry

/- ## rewrite

`rewrite` というタクティクもあります。`rw` とよく似ていて、違いは `rw` が書き換え後に自動的に `rfl` を実行するのに対して、`rewrite` は行わないということです。`rewrite` はユーザにとっては `rw` の下位互換なので、あまり使うことはないかもしれません。-/

example (h : a = b) : a = b := by
  -- `rw` を使用した場合は一発で証明が終わる
  rw [h]

example (h : a = b) : a = b := by
  rewrite [h]

  -- ゴールを `b = b` にするところまでしかやってくれない
  show b = b

  rfl
