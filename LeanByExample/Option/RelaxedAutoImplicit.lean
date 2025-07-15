/- # relaxedAutoImplicit

`relaxedAutoImplicit` オプションは、[`autoImplicit`](./AutoImplicit.md) オプションの派生オプションであり、自動束縛の対象を広げます。
-/
import Lean --#
-- `autoImplicit` は有効にしておく
set_option autoImplicit true

section
  -- `relaxedAutoImplicit` が無効の時
  set_option relaxedAutoImplicit false

  -- 二文字の識別子は自動束縛の対象にならないのでエラーになる
  /-⋆-//-- error: unknown identifier 'AB' -/
  #guard_msgs in --#
  def nonempty₁ : List AB → Bool
    | [] => false
    | _ :: _ => true
end

section
  -- `relaxedAutoImplicit` が有効の時
  set_option relaxedAutoImplicit true

  -- 二文字の識別子も自動束縛の対象になるのでエラーにならない
  def nonempty₂ : List AB → Bool
    | [] => false
    | _ :: _ => true
end
