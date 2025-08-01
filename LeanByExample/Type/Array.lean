/- # Array

`Array α` は配列を表す型です。特定の型 `α : Type u` の要素を一直線に並べたものです。
`#[a₁, ..., aₖ]` という記法で `Array α` の項を作ることができます。
-/

#check (#[1, 2, 3] : Array Nat)

#check (#["hello", "world"] : Array String)

/- ## 定義と実行時の性質

`Array α` は次のように連結リスト `List α` のラッパーとして定義されているように見えます。-/
--#--
/--
info: structure Array.{u} (α : Type u) : Type u
number of parameters: 1
fields:
  Array.toList : List α
constructor:
  Array.mk.{u} {α : Type u} (toList : List α) : Array α
-/
#guard_msgs in #print Array
--#--

namespace Hidden --#

structure Array.{u} (α : Type u) : Type u where
  toList : List α

end Hidden --#
/- しかしドキュメントコメントに以下のように書かれている通り、実行時には `List` とは大きく異なる動的配列(dynamic array)としての振る舞いを見せます。

{{#include ./Array/Doc.md}}

`List` のラッパーとしての定義は、証明を行おうとしたときに参照されます。-/

/- ## 基本的な操作

### インデックスアクセス

配列は [`GetElem`](#{root}/TypeClass/GetElem.md) のインスタンスであり、`i` 番目の要素を取得するために `a[i]` という記法が使用できます。`Array α` は実行時には動的配列として振る舞うので、インデックスアクセスは高速に行うことができます。
-/

#guard #[1, 2, 3][0] = 1

#guard #[1, 2, 3][3]? = none

/- ### 要素の追加

`xs : Array α` に対して `Array.push` 関数で末尾に要素を追加できます。

ドキュメントコメントに次のように書かれている通り、この操作は高速に行うことができます。

{{#include ./Array/PushDoc.md}}
-/

#guard #[1, 2, 3].push 4 = #[1, 2, 3, 4]

/- ## List と比較した特長

[`List`](#{root}/Type/List.md) も同様にインデックスアクセスをサポートしていますが、`Array` の方がより高速にアクセスすることができます。

なぜかというと、`List` は連結リストとして実装されており、`i : Nat` 番目にアクセスしようとすると最初の要素から順に辿っていく必要があるからです。一方で `Array` は動的配列として実装されているので、`i` 番目の要素に直接アクセスできます。

{{#include ./Array/IdxAccess.md}}
-/

/- ## 使用例

配列の特徴を生かしてプログラムを組んでいる例をいくつか紹介します。
-/

/- ### 特定の要素だけ末尾に移動させる

`arr : Array α` に対しては、インデックスアクセスと「指定されたインデックスにある要素の更新」が高速に行えるので、それを生かして「特定の要素だけ末尾に移動させる」操作を効率的に実装することができます。
-/
section --#

variable {α : Type} [BEq α]

/-- 配列`arr`の要素`a`が与えられたときに、
他の要素の位置関係を維持したまま、すべての`a`を配列の末尾に移動させる
-/
def Array.move (arr : Array α) (a : α) : Array α := Id.run do
  let mut arr := arr
  let mut write := 0
  -- まず `a` 以外の要素を前詰めで配置
  for x in arr do
    if x != a then
      arr := arr.set! write x
      write := write + 1
  -- 残りの部分を `a` で埋める
  for i in [write:arr.size] do
    arr := arr.set! i a
  return arr

#guard Array.move #[1, 0, 2, 0, 3] 0 == #[1, 2, 3, 0, 0] -- `0` を末尾に移動
#guard Array.move #[1, 2, 3] 0 == #[1, 2, 3] -- `0` がないので変化なし
#guard Array.move #[] 0 == #[] -- 空配列はそのまま
#guard Array.move #[0, 0, 0] 0 == #[0, 0, 0] -- `0` しかないので変化なし

end --#
/- ### スタックの実装

`arr : Array α` に対しては「末尾に要素を追加する操作」と「末尾から要素を取り出す操作」が高速に行えるので、スタックの実装に利用することができます。
-/

/-- 括弧が対応しているか判定する -/
def matchParen (c1 c2 : Char) : Bool :=
  match c1, c2 with
  | '(', ')' => true
  | '{', '}' => true
  | '[', ']' => true
  | _, _ => false

/--
文字列 `s` に含まれる括弧が正しく対応しているかどうかを判定する関数。
開き括弧と閉じ括弧が対応しており、正しい順序で閉じられている場合に `true` を返す。
-/
def validParen (s : String) : Bool := Id.run do
  -- 括弧のスタックを空で初期化
  let mut stack : Array Char := #[]

  -- 文字列の各文字に対してループ
  for c in s.toList do
    -- スタックの末尾の要素（最後に追加された開き括弧）を取得
    let last := stack.back?
    match last with
    | none =>
      -- スタックが空なら、文字をスタックに追加（開き括弧のはず）
      stack := stack.push c
    | some last =>
      -- スタックの末尾と現在の文字が対応する括弧なら、スタックから取り除く（ペアが閉じられた）
      if matchParen last c then
        stack := stack.pop
      else
        -- 対応していない場合は、新たにスタックに追加（新しい開き括弧）
        stack := stack.push c

  -- すべての括弧が正しく閉じられていればスタックは空になっている
  return stack.isEmpty

-- テストケース
#guard validParen "()"
#guard validParen "()[]{}"
#guard !validParen "(]"
#guard !validParen "([)]"
#guard validParen "{[]}"
#guard !validParen "{"
#guard !validParen "}"
#guard validParen "([{}])({}){}"
