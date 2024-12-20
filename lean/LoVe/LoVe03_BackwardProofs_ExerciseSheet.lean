/- Copyright © 2018–2023 Anne Baanen, Alexander Bentkamp, Jasmin Blanchette,
Johannes Hölzl, and Jannis Limperg. See `LICENSE.txt`. -/

import LoVe.LoVe03_BackwardProofs_Demo


/- # LoVe Exercise 3: Backward Proofs

Replace the placeholders (e.g., `:= sorry`) with your solutions. -/


set_option autoImplicit false
set_option tactic.hygienic false

namespace LoVe

namespace BackwardProofs


/- ## Question 1: Connectives and Quantifiers

1.1. Carry out the following proofs using basic tactics.

Hint: Some strategies for carrying out such proofs are described at the end of
Section 3.3 in the Hitchhiker's Guide. -/

theorem I (a : Prop) :
  a → a :=
  by
    intro ha
    apply ha


theorem K (a b : Prop) :
  a → b → b :=
  by
    intro _ha hb
    apply hb

theorem C (a b c : Prop) :
  (a → b → c) → b → a → c :=
  by
    intro hf hb ha
    apply hf ha hb

theorem proj_fst (a : Prop) :
  a → a → a :=
  by
    intro ha _ha'
    apply ha

/- Please give a different answer than for `proj_fst`: -/

theorem proj_snd (a : Prop) :
  a → a → a :=
  by
    intro _ha ha'
    apply ha'

theorem some_nonsense (a b c : Prop) :
  (a → b → c) → a → (a → c) → b → c :=
  by
    intro _hf ha hac _hb
    exact hac ha

/- 1.2. Prove the contraposition rule using basic tactics. -/

theorem contrapositive (a b : Prop) :
  (a → b) → ¬ b → ¬ a :=
  by
    intro hab
    apply C
    intro ha
    rw [← Not]
    apply Not_Not_intro
    exact hab ha


/- 1.3. Prove the distributivity of `∀` over `∧` using basic tactics.

Hint: This exercise is tricky, especially the right-to-left direction. Some
forward reasoning, like in the proof of `and_swap_braces` in the lecture, might
be necessary. -/

theorem forall_and {α : Type} (p q : α → Prop) :
  (∀x, p x ∧ q x) ↔ (∀x, p x) ∧ (∀x, q x) :=
  by
    apply Iff.intro
    { intro hpq
      apply And.intro
      { intro x
        apply And.left
        exact hpq x
      }
      {
        intro x
        apply And.right
        exact hpq x
      }
    }
    {
      intro hpq
      intro x
      apply And.intro
      { apply And.left hpq }
      { apply And.right hpq }
    }




/- ## Question 2: Natural Numbers

2.1. Prove the following recursive equations on the first argument of the
`mul` operator defined in lecture 1. -/

#check mul

theorem mul_zero (n : ℕ) :
  mul 0 n = 0 :=
  by
    induction n with
    | zero => rfl
    | succ n' ih => simp [mul, ih]


#check add_succ
theorem mul_succ (m n : ℕ) :
  mul (Nat.succ m) n = add (mul m n) n :=
  by
    induction n with
    | zero => rfl
    | succ n' ih =>
      {
        simp [mul, ih]
        simp [add_comm, add_succ]
        rw [add]
        rw [add]
        rw [add_assoc]
        simp [add_assoc, add_comm]
      }



/- 2.2. Prove commutativity and associativity of multiplication using the
`induction` tactic. Choose the induction variable carefully. -/

theorem mul_comm (m n : ℕ) :
  mul m n = mul n m :=
  by
    induction n with
    | zero =>
      {
        rw [mul]
        rw [mul_zero]
      }
    | succ n' ih =>
      {
        rw [mul_succ]
        rw [mul]
        rw [add_comm]
        rw [ih]
      }

theorem mul_assoc (l m n : ℕ) :
  mul (mul l m) n = mul l (mul m n) :=
  by
    induction n with
    | zero => simp [mul]
    | succ n' ih =>
      {
        rw [mul_comm]
        rw [mul_succ]
        rw [mul_comm]
        rw [ih]
        apply Eq.symm
        rw [mul]
        rw [mul_add]
        rw [add_comm]
      }

/- 2.3. Prove the symmetric variant of `mul_add` using `rw`. To apply
commutativity at a specific position, instantiate the rule by passing some
arguments (e.g., `mul_comm _ l`). -/

theorem add_mul (l m n : ℕ) :
  mul (add l m) n = add (mul n l) (mul n m) :=
  by
    induction n with
    | zero =>
      {
        rw [mul]
        rw [mul_comm]
        rw [mul]
        rw [mul_comm]
        rw [mul]
        rw [add]
      }
    | succ n' ih =>
      {
        rw [mul_comm]
        rw [mul_succ]
        rw [mul_comm]
        rw [ih]
        rw [mul_succ]
        rw [mul_succ]
        ac_rfl
      }


/- ## Question 3 (**optional**): Intuitionistic Logic

Intuitionistic logic is extended to classical logic by assuming a classical
axiom. There are several possibilities for the choice of axiom. In this
question, we are concerned with the logical equivalence of three different
axioms: -/

def ExcludedMiddle : Prop :=
  ∀a : Prop, a ∨ ¬ a

def Peirce : Prop :=
  ∀a b : Prop, ((a → b) → a) → a

def DoubleNegation : Prop :=
  ∀a : Prop, (¬¬ a) → a

/- For the proofs below, avoid using theorems from Lean's `Classical` namespace.

3.1 (**optional**). Prove the following implication using tactics.

Hint: You will need `Or.elim` and `False.elim`. You can use
`rw [ExcludedMiddle]` to unfold the definition of `ExcludedMiddle`,
and similarly for `Peirce`. -/

theorem Peirce_of_EM :
  ExcludedMiddle → Peirce :=
  by
    rw [ExcludedMiddle]
    rw [Peirce]
    intro em a b
    intro f
    apply Or.elim
    { apply em }
    {
      intro a'
      apply a'
    }
    {
      rw [Not]
      intro af
      apply f
      intro a''
      apply False.elim
      apply af
      apply a''
    }



/- 3.2 (**optional**). Prove the following implication using tactics. -/

theorem DN_of_Peirce :
  Peirce → DoubleNegation :=
  by
    rw [Peirce, DoubleNegation]
    intro pr a nna
    apply pr a False
    intro na
    exact False.elim (nna na)


/- We leave the remaining implication for the homework: -/

namespace SorryTheorems

theorem demorgan (a b : Prop) :
  (¬ a ∨ ¬ b) → ¬(a ∧ b) :=
  by
    intro nor
    intro and
    apply Or.elim
    apply nor
    {
      intro na
      apply na
      apply And.left
      apply and
    }
    {
      intro nb
      apply nb
      apply And.right
      apply and
    }

theorem idiot_demorgan (a b : Prop) :
  (a ∧ b) → ¬(¬a ∨ ¬b) :=
  by
    intro anb
    rw [Not]
    intro arb
    apply Or.elim
    apply arb
    {
      rw [Not]
      intro na
      apply na
      apply And.left
      assumption
    }
    {
      rw [Not]
      intro nb
      apply nb
      apply And.right
      assumption
    }

theorem idiot_demorgan2 (a b : Prop) :
  a ∨ b → ¬(¬a ∧ ¬b) :=
  by
    intro ab anb
    apply Or.elim ab
    { exact anb.left }
    { exact anb.right }

theorem silly (a b : Prop) :
  ¬(¬a ∧ ¬b) → ¬¬(a ∨ b) :=
  by
    apply contrapositive
    intro nab
    apply And.intro
    {
      intro a'
      apply nab (Or.inl a')
    }
    {
      intro b'
      apply nab (Or.inr b')
    }


theorem lemma1 (a : Prop) :
  DoubleNegation -> (¬¬a ∨ ¬a) → a ∨ ¬ a :=
    by
      intro dn aorna
      apply Or.elim
      apply aorna
      {
        intro a'
        apply Or.inl
        apply dn
        assumption
      }
      {
        intro a'
        apply Or.inr
        assumption
      }


theorem EM_of_DN :
  DoubleNegation → ExcludedMiddle :=
    by
      rw [DoubleNegation, ExcludedMiddle]
      intro dn a
      apply lemma1
      exact dn
      apply dn
      apply silly
      intro nna
      exact (nna.left (nna.right))



end SorryTheorems

end BackwardProofs

end LoVe
