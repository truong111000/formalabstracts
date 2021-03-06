import group_theory.basic
import data.finset group_theory.group_action

open finset fintype is_group_action is_monoid_action

universes u v

local attribute [instance, priority 0] classical.prop_decidable

variables {α : Type u} {β : Type v} {t k v : ℕ}

namespace mathieu_group
/-- 
A Steiner system $S(t,k,v)$, where $t < k < v$ are positive integers is a finite set $X$ of cardinality $v$, a collection of $k$ element subsets of $X$ (called blocks), such that each $t$ element subset of $X$ is contained in a unique block.
-/
structure steiner_system (t k v : ℕ) :=
(X : Type u) 
(blocks : finset (finset X))
(h₁ : fintype X)
(h₂ : card X = v)
(h₃ : ∀ b ∈ blocks, card b = k)
(h₄ : ∀ x : finset X, card x = t → ∃! b, b ∈ blocks ∧ x ⊂ b)

/-- The coercion from steiner systems to types. -/
instance : has_coe_to_sort (steiner_system t k v) := ⟨Type u, λ s, s.X⟩
/-- The underlying set of a steiner system is finite. -/
instance steiner_system_fintype (s : steiner_system t k v) : fintype s := s.h₁

def nonempty_steiner_system {s : steiner_system t k v} (h : v > 0) : nonempty s :=
by { rw ← fintype.card_pos_iff, rw ←s.h₂ at h, exact h }

/-- The set of all isomorphisms of between two steiner systems consists of all equivalences of the underlying sets which are block-preserving. -/
def steiner_system_isomorphism 
{t₁ k₁ v₁ : ℕ} 
{t₂ k₂ v₂ : ℕ}
(s₁ : steiner_system t₁ k₁ v₁)
(s₂ : steiner_system t₂ k₂ v₂) := {f : s₁ ≃ s₂ | ∀ b ∈ s₁.blocks, finset.image f b ∈ s₂.blocks }

/-- The automorphism set $\mathrm{Aut}(s)$ of a steiner system $s$ is the set of isomorphisms from $s$ to $s$. -/
def Aut {t k v : ℕ}(s : steiner_system t k v) := steiner_system_isomorphism s s

/-- The automorphism set of a steiner system can be equipped with a group structure with group identity the identity function, multiplication is function composition, inverses are function inverses. -/
instance {s : steiner_system t k v} : group (Aut s) := 
{ 
   one := ⟨equiv.refl s, omitted⟩  ,
   mul := fun f g, ⟨f.1.trans g.1, omitted⟩,
   inv := fun f, ⟨ equiv.symm f.1, omitted⟩, 
   one_mul := omitted,
   mul_one := omitted,
   mul_left_inv := omitted, 
   mul_assoc := omitted,
} 

/-- The Steiner system $S(5,8,24)$ exists and is unique up to isomorphism.-/
lemma is_unique_s_5_8_24 : ∃ x: steiner_system 5 8 24, ∀ y : steiner_system 5 8 24, nonempty $ steiner_system_isomorphism x y := omitted 

/-- Using the axiom of choice, we can pick a representative of the isomorphism class of $S(5,8,24)$.-/
noncomputable def s_5_8_24 : steiner_system 5 8 24 := 
classical.some is_unique_s_5_8_24


/-- The Steiner system $S(5,6,12)$ exists and is unique up to isomorphism.-/
lemma is_unique_s_5_6_12 : ∃ x : steiner_system 5 6 12, ∀ y : steiner_system 5 6 12, 
  nonempty $ steiner_system_isomorphism x y := omitted 

/-- Using the axiom of choice, we can pick a representative of the isomorphism class of $S(5,6,12)$.-/
noncomputable def s_5_6_12 : steiner_system 5 6 12 := classical.some is_unique_s_5_6_12  

/-- The automorphism group of a steiner system acts on the underlying set through the evaluation action.-/
def evaluation_action {t k v : ℕ} (s : steiner_system t k v) : Aut(s) → s → s := 
λ f x, f.1 x

/-- The evaluation action of the automorphism group satisfies the properties of a monoid action. -/
instance {t k v : ℕ} (s : steiner_system t k v) : is_group_action (evaluation_action s) := omitted 

/- *TODO(Kody) : move these to mathlib?* -/

/-- The two point stabilizer of a group is the set of all group elements which fix two distinct points of the group via the group action. -/
def two_pt_stabilizer [monoid α] (f : α → β → β) [is_monoid_action f] {x : β × β} (h : x.1 ≠ x.2) : 
  set α :=
{ y : α | f y x.1 = x.1 ∧ f y x.2 = x.2}

/-- The two point stabilizer of a group is a subgroup of the group. -/
instance is_subgroup_two_pt_stabilizer [group α] (f : α → β → β) [is_group_action f] 
  {x : β × β} (h : x.1 ≠ x.2) : is_subgroup (two_pt_stabilizer f h) := omitted

end mathieu_group