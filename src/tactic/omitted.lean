/-
Copyright (c) 2019 Jesse Han. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jesse Han

Some goodies for reducing tactic goals to only data obligations with `omitted`

`omitted` tries to close a propositional goal with `exact omitted`

`omit_props` tries to close any visible goals with the `omitted` tactic

`tidy_omitted` runs `tidy` and lets it use `omitted` (and still produces proof traces).
`tidy_omitted` will always attempt to split existential statements and sigma-types in the goal, and will fill in as little data as possible.

`if it has used `omitted`, `tidy` will emit a trace urging the user to replace
the call to `tidy_omitted` with the proof trace generated by `tidy_omitted {trace_result := tt}
-/

import data.set.finite tactic.tidy ..basic

section omitted_tactics
open tactic

/-- Check if the goal is a proposition; if so, prove it using omitted.

    When called with "tidy using omitted", tidy will run as usual and fulfill all
    proof obligations using omitted, leaving it to the user to specify the data. -/
meta def tactic.interactive.omitted : tactic unit :=
  propositional_goal >> `[exact omitted] <|> tactic.fail "Goal is not a proposition and cannot be omitted"

meta def tactic.interactive.omit_props : tactic unit := `[all_goals {try {omitted}}]

meta def tactic.verbose_omitted : tactic string :=
tactic.interactive.omitted >> tactic.trace "`tidy` used `omitted`, please replace this call to `tidy_omitted` with the output of {trace_result := tt}"
                           >> return "omitted"

open tactic.tidy

meta def omitted_default_tactics : list (tactic string) :=
[ reflexivity                                 >> pure "refl", 
  `[exact dec_trivial]                        >> pure "exact dec_trivial",
  -- propositional_goal >> assumption            >> pure "assumption",
  ext1_wrapper,
  intros1                                     >>= λ ns, pure ("intros " ++ (" ".intercalate (ns.map (λ e, e.to_string)))),
  auto_cases,
  `[apply_auto_param]                         >> pure "apply_auto_param",
  -- `[dsimp at *]                               >> pure "dsimp at *",
  -- `[simp at *]                                >> pure "simp at *",
  fsplit                                      >> pure "fsplit", 
  injections_and_clear                        >> pure "injections_and_clear",
  -- propositional_goal >> (`[solve_by_elim])    >> pure "solve_by_elim",2

  `[unfold_aux]                               >> pure "unfold_aux",--
  -- tidy.run_tactics 
  tactic.verbose_omitted ]

meta structure omitted_cfg :=
(trace_result : bool            := ff)
(trace_result_prefix : string   := "/- `tidy` says -/ ")
(tactics : list (tactic string) := omitted_default_tactics)

meta def cfg_of_omitted_cfg : omitted_cfg → cfg :=
λ X, { trace_result := X.trace_result,
  trace_result_prefix := X.trace_result_prefix,
  tactics := X.tactics }

/- Calls tidy, but with `omitted` thrown into the tactic list.

  tidy {trace_result := tt}` produces a proof trace as usual.-/
meta def tactic.interactive.tidy_omitted (cfg : omitted_cfg := {}): tactic unit :=
tidy (cfg_of_omitted_cfg cfg)

end omitted_tactics

section test1

variable {α : Type*}
variable (P : α → Prop)
variable (a : α)

open vector

example : vector α 1 ≃ α :=
begin
 split, omit_props,
 from λ x, ⟨[x], dec_trivial⟩,
 from λ x, x.head
end

/- In this example, (a : α) is in context, but `tidy_omitted` refuses to use it -/
include a
example : Σ' a : α, P a := -- by {tidy_omitted, exact a}
by {/- `tidy` says -/ fsplit, work_on_goal 1 { omitted }, exact a}
end test1

section test2
private def is_even (n : ℕ) := ∃ k, 2 * k = n

private lemma test : ∃ m : ℕ, is_even m :=
begin
 tidy_omitted, exact 2
end

private lemma test'' : ∃ m, is_even m :=
by {use 2, use 1, refl}

-- #print test''

-- #print test
/-
92:1: theorem test : ∃ (m : ℕ), is_even m :=
id (Exists.intro (2 * 2) (Exists.intro 2 (eq.refl (2 * 2))))
-/

private lemma test' : ∃ m, is_even m := by omitted

-- #print test'
/-
100:1: theorem hewwo' : ∃ (m : ℕ), is_even m :=
omitted
-/

end test2
