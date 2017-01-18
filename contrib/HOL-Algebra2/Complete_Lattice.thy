theory Complete_Lattice
imports Lattice FuncSet
begin

subsection {* Complete Lattices *}

locale weak_complete_lattice = weak_partial_order +
  assumes sup_exists:
    "[| A \<subseteq> carrier L |] ==> EX s. least L s (Upper L A)"
    and inf_exists:
    "[| A \<subseteq> carrier L |] ==> EX i. greatest L i (Lower L A)"

sublocale weak_complete_lattice \<subseteq> weak_lattice
proof
  fix x y
  assume a: "x \<in> carrier L" "y \<in> carrier L"
  thus "\<exists>s. is_lub L s {x, y}"
    by (rule_tac sup_exists[of "{x, y}"], auto)
  from a show "\<exists>s. is_glb L s {x, y}"
    by (rule_tac inf_exists[of "{x, y}"], auto)
qed

text {* Introduction rule: the usual definition of complete lattice *}

lemma (in weak_partial_order) weak_complete_latticeI:
  assumes sup_exists:
    "!!A. [| A \<subseteq> carrier L |] ==> EX s. least L s (Upper L A)"
    and inf_exists:
    "!!A. [| A \<subseteq> carrier L |] ==> EX i. greatest L i (Lower L A)"
  shows "weak_complete_lattice L"
  by standard (auto intro: sup_exists inf_exists)

lemma (in weak_complete_lattice) dual_weak_complete_lattice:
  "weak_complete_lattice (inv_gorder L)"
proof -
  interpret dual: weak_lattice "inv_gorder L"
    by (metis dual_weak_lattice)

  show ?thesis
    apply (unfold_locales)
    apply (simp_all add:inf_exists sup_exists)
  done
qed

lemma (in weak_complete_lattice) supI:
  "[| !!l. least L l (Upper L A) ==> P l; A \<subseteq> carrier L |]
  ==> P (\<Squnion>A)"
proof (unfold asup_def)
  assume L: "A \<subseteq> carrier L"
    and P: "!!l. least L l (Upper L A) ==> P l"
  with sup_exists obtain s where "least L s (Upper L A)" by blast
  with L show "P (SOME l. least L l (Upper L A))"
  by (fast intro: someI2 weak_least_unique P)
qed

lemma (in weak_complete_lattice) sup_closed [simp]:
  "A \<subseteq> carrier L ==> \<Squnion>A \<in> carrier L"
  by (rule supI) simp_all

lemma (in weak_complete_lattice) sup_cong:
  assumes "A \<subseteq> carrier L" "B \<subseteq> carrier L" "A {.=} B"
  shows "\<Squnion> A .= \<Squnion> B"
proof -
  have "\<And> x. is_lub L x A \<longleftrightarrow> is_lub L x B"
    by (rule least_Upper_cong_r, simp_all add: assms)
  moreover have "\<Squnion> B \<in> carrier L"
    by (simp add: assms(2))
  ultimately show ?thesis
    by (simp add: asup_def)
qed

sublocale weak_complete_lattice \<subseteq> weak_bounded_lattice
  apply (unfold_locales)
  apply (metis Upper_empty empty_subsetI sup_exists)
  apply (metis Lower_empty empty_subsetI inf_exists)
done

lemma (in weak_complete_lattice) infI:
  "[| !!i. greatest L i (Lower L A) ==> P i; A \<subseteq> carrier L |]
  ==> P (\<Sqinter>A)"
proof (unfold ainf_def)
  assume L: "A \<subseteq> carrier L"
    and P: "!!l. greatest L l (Lower L A) ==> P l"
  with inf_exists obtain s where "greatest L s (Lower L A)" by blast
  with L show "P (SOME l. greatest L l (Lower L A))"
  by (fast intro: someI2 weak_greatest_unique P)
qed

lemma (in weak_complete_lattice) inf_closed [simp]:
  "A \<subseteq> carrier L ==> \<Sqinter>A \<in> carrier L"
  by (rule infI) simp_all

lemma (in weak_complete_lattice) inf_cong:
  assumes "A \<subseteq> carrier L" "B \<subseteq> carrier L" "A {.=} B"
  shows "\<Sqinter> A .= \<Sqinter> B"
proof -
  have "\<And> x. is_glb L x A \<longleftrightarrow> is_glb L x B"
    by (rule greatest_Lower_cong_r, simp_all add: assms)
  moreover have "\<Sqinter> B \<in> carrier L"
    by (simp add: assms(2))
  ultimately show ?thesis
    by (simp add: ainf_def)
qed

theorem (in weak_partial_order) weak_complete_lattice_criterion1:
  assumes top_exists: "EX g. greatest L g (carrier L)"
    and inf_exists:
      "!!A. [| A \<subseteq> carrier L; A ~= {} |] ==> EX i. greatest L i (Lower L A)"
  shows "weak_complete_lattice L"
proof (rule weak_complete_latticeI)
  from top_exists obtain top where top: "greatest L top (carrier L)" ..
  fix A
  assume L: "A \<subseteq> carrier L"
  let ?B = "Upper L A"
  from L top have "top \<in> ?B" by (fast intro!: Upper_memI intro: greatest_le)
  then have B_non_empty: "?B ~= {}" by fast
  have B_L: "?B \<subseteq> carrier L" by simp
  from inf_exists [OF B_L B_non_empty]
  obtain b where b_inf_B: "greatest L b (Lower L ?B)" ..
  have "least L b (Upper L A)"
apply (rule least_UpperI)
   apply (rule greatest_le [where A = "Lower L ?B"])
    apply (rule b_inf_B)
   apply (rule Lower_memI)
    apply (erule Upper_memD [THEN conjunct1])
     apply assumption
    apply (rule L)
   apply (fast intro: L [THEN subsetD])
  apply (erule greatest_Lower_below [OF b_inf_B])
  apply simp
 apply (rule L)
apply (rule greatest_closed [OF b_inf_B])
done
  then show "EX s. least L s (Upper L A)" ..
next
  fix A
  assume L: "A \<subseteq> carrier L"
  show "EX i. greatest L i (Lower L A)"
  proof (cases "A = {}")
    case True then show ?thesis
      by (simp add: top_exists)
  next
    case False with L show ?thesis
      by (rule inf_exists)
  qed
qed

(* TODO: prove dual version *)


text {* Supremum *}

declare (in partial_order) weak_sup_of_singleton [simp del]

lemma (in partial_order) sup_of_singleton [simp]:
  "x \<in> carrier L ==> \<Squnion>{x} = x"
  using weak_sup_of_singleton unfolding eq_is_equal .

lemma (in upper_semilattice) join_assoc_lemma:
  assumes L: "x \<in> carrier L"  "y \<in> carrier L"  "z \<in> carrier L"
  shows "x \<squnion> (y \<squnion> z) = \<Squnion>{x, y, z}"
  using weak.weak_join_assoc_lemma L unfolding eq_is_equal .

lemma (in upper_semilattice) join_assoc:
  assumes L: "x \<in> carrier L"  "y \<in> carrier L"  "z \<in> carrier L"
  shows "(x \<squnion> y) \<squnion> z = x \<squnion> (y \<squnion> z)"
  using weak.weak_join_assoc L unfolding eq_is_equal .

text {* Infimum *}

declare (in partial_order) weak_inf_of_singleton [simp del]

lemma (in partial_order) inf_of_singleton [simp]:
  "x \<in> carrier L ==> \<Sqinter>{x} = x"
  using weak_inf_of_singleton unfolding eq_is_equal .

text {* Condition on @{text A}: infimum exists. *}

lemma (in lower_semilattice) meet_assoc_lemma:
  assumes L: "x \<in> carrier L"  "y \<in> carrier L"  "z \<in> carrier L"
  shows "x \<sqinter> (y \<sqinter> z) = \<Sqinter>{x, y, z}"
  using weak.weak_meet_assoc_lemma L unfolding eq_is_equal .

lemma (in lower_semilattice) meet_assoc:
  assumes L: "x \<in> carrier L"  "y \<in> carrier L"  "z \<in> carrier L"
  shows "(x \<sqinter> y) \<sqinter> z = x \<sqinter> (y \<sqinter> z)"
  using weak.weak_meet_assoc L unfolding eq_is_equal .

text {* Infimum Laws *}

context weak_complete_lattice
begin

lemma inf_glb: 
  assumes "A \<subseteq> carrier L"
  shows "greatest L (\<Sqinter>A) (Lower L A)"
proof -
  obtain i where "greatest L i (Lower L A)"
    by (metis assms inf_exists)

  thus ?thesis
    apply (simp add:ainf_def)
    apply (rule someI2[of _ "i"])
    apply (auto)
  done
qed

lemma inf_lower:
  assumes "A \<subseteq> carrier L" "x \<in> A"
  shows "\<Sqinter>A \<sqsubseteq> x"
  by (metis assms greatest_Lower_below inf_glb)

lemma inf_greatest: 
  assumes "A \<subseteq> carrier L" "z \<in> carrier L" 
          "(\<And>x. x \<in> A \<Longrightarrow> z \<sqsubseteq> x)"
  shows "z \<sqsubseteq> \<Sqinter>A"
  by (metis Lower_memI assms greatest_le inf_glb)

lemma weak_inf_empty [simp]: "\<Sqinter>{} .= \<top>"
  by (metis Lower_empty empty_subsetI inf_glb top_greatest weak_greatest_unique)

lemma weak_inf_carrier [simp]: "\<Sqinter>carrier L .= \<bottom>"
  by (metis bottom_weak_eq inf_closed inf_lower subset_refl)

lemma weak_inf_insert [simp]: 
  "\<lbrakk> a \<in> carrier L; A \<subseteq> carrier L \<rbrakk> \<Longrightarrow> \<Sqinter>insert a A .= a \<sqinter> \<Sqinter>A"
  apply (rule weak_le_antisym)
  apply (force intro: weak_le_antisym meet_le inf_lower inf_greatest inf_lower inf_closed)
  apply (rule inf_greatest)
  apply (force)
  apply (force intro: inf_closed)
  apply (auto)
  apply (metis inf_closed meet_left)
  apply (force intro: le_trans inf_closed meet_right meet_left inf_lower)
done

text {* Supremum Laws *}

lemma sup_lub: 
  assumes "A \<subseteq> carrier L"
  shows "least L (\<Squnion>A) (Upper L A)"
    by (metis Upper_is_closed assms least_closed least_cong supI sup_closed sup_exists weak_least_unique)

lemma sup_upper: 
  assumes "A \<subseteq> carrier L" "x \<in> A"
  shows "x \<sqsubseteq> \<Squnion>A"
  by (metis assms least_Upper_above supI)

lemma sup_least:
  assumes "A \<subseteq> carrier L" "z \<in> carrier L" 
          "(\<And>x. x \<in> A \<Longrightarrow> x \<sqsubseteq> z)" 
  shows "\<Squnion>A \<sqsubseteq> z"
  by (metis Upper_memI assms least_le sup_lub)

lemma weak_sup_empty [simp]: "\<Squnion>{} .= \<bottom>"
  by (metis Upper_empty bottom_least empty_subsetI sup_lub weak_least_unique)

lemma weak_sup_carrier [simp]: "\<Squnion>carrier L .= \<top>"
  by (metis Lower_closed Lower_empty sup_closed sup_upper top_closed top_higher weak_le_antisym)

lemma weak_sup_insert [simp]: 
  "\<lbrakk> a \<in> carrier L; A \<subseteq> carrier L \<rbrakk> \<Longrightarrow> \<Squnion>insert a A .= a \<squnion> \<Squnion>A"
  apply (rule weak_le_antisym)
  apply (rule sup_least)
  apply (auto)
  apply (metis join_left sup_closed)
  apply (rule le_trans) defer
  apply (rule join_right)
  apply (auto)
  apply (rule join_le)
  apply (auto intro: sup_upper sup_least sup_closed)
done

text {* Least fixed points *}

lemma LFP_closed [intro, simp]:
  "\<mu> f \<in> carrier L"
  by (metis (lifting) LFP_def inf_closed mem_Collect_eq subsetI)

lemma LFP_lowerbound: 
  assumes "x \<in> carrier L" "f x \<sqsubseteq> x" 
  shows "\<mu> f \<sqsubseteq> x"
  by (auto intro:inf_lower assms simp add:LFP_def)

lemma LFP_greatest: 
  assumes "x \<in> carrier L" 
          "(\<And>u. \<lbrakk> u \<in> carrier L; f u \<sqsubseteq> u \<rbrakk> \<Longrightarrow> x \<sqsubseteq> u)"
  shows "x \<sqsubseteq> \<mu> f"
  by (auto simp add:LFP_def intro:inf_greatest assms)

lemma LFP_lemma2: 
  assumes "Mono f" "f \<in> carrier L \<rightarrow> carrier L"
  shows "f (\<mu> f) \<sqsubseteq> \<mu> f"
  using assms
  apply (auto simp add:Pi_def)
  apply (rule LFP_greatest)
  apply (metis LFP_closed)
  apply (metis LFP_closed LFP_lowerbound le_trans use_iso1)
done

lemma LFP_lemma3: 
  assumes "Mono f" "f \<in> carrier L \<rightarrow> carrier L"
  shows "\<mu> f \<sqsubseteq> f (\<mu> f)"
  using assms
  apply (auto simp add:Pi_def)
  apply (metis LFP_closed LFP_lemma2 LFP_lowerbound assms(2) use_iso2)
done

lemma ftype_carrier [intro]:
  "\<lbrakk> x \<in> carrier L; f \<in> carrier L \<rightarrow> carrier L \<rbrakk> \<Longrightarrow> f(x) \<in> carrier L"
  by (metis Pi_iff)

lemma LFP_weak_unfold: 
  "\<lbrakk> Mono f; f \<in> carrier L \<rightarrow> carrier L \<rbrakk> \<Longrightarrow> \<mu> f .= f (\<mu> f)"
  by (auto intro: LFP_closed LFP_lemma2 LFP_lemma3 weak_le_antisym)

lemma GFP_closed [intro, simp]:
  "\<nu> f \<in> carrier L"
  by (auto intro:sup_closed simp add:GFP_def)
  
lemma GFP_upperbound:
  assumes "x \<in> carrier L" "x \<sqsubseteq> f x"
  shows "x \<sqsubseteq> \<nu> f"
  by (auto intro:sup_upper assms simp add:GFP_def)

lemma GFP_least: 
  assumes "x \<in> carrier L" 
          "(\<And>u. \<lbrakk> u \<in> carrier L; u \<sqsubseteq> f u \<rbrakk> \<Longrightarrow> u \<sqsubseteq> x)"
  shows "\<nu> f \<sqsubseteq> x"
  by (auto simp add:GFP_def intro:sup_least assms)

lemma GFP_lemma2:
  assumes "Mono f" "f \<in> carrier L \<rightarrow> carrier L"
  shows "\<nu> f \<sqsubseteq> f (\<nu> f)"
  using assms
  apply (auto simp add:Pi_def)
  apply (rule GFP_least)
  apply (metis GFP_closed assms(2))
  apply (metis GFP_closed GFP_upperbound assms le_trans use_iso2)
done

lemma GFP_lemma3:
  assumes "Mono f" "f \<in> carrier L \<rightarrow> carrier L"
  shows "f (\<nu> f) \<sqsubseteq> \<nu> f"
  by (metis GFP_closed GFP_lemma2 GFP_upperbound assms ftype_carrier use_iso2)
  
lemma GFP_weak_unfold: 
  "\<lbrakk> Mono f; f \<in> carrier L \<rightarrow> carrier L \<rbrakk> \<Longrightarrow> \<nu> f .= f (\<nu> f)"
  by (auto intro: GFP_closed GFP_lemma2 GFP_lemma3 weak_le_antisym)

end

text {* Total orders are lattices. *}

sublocale total_order < weak: lattice
  by standard (auto intro: weak.weak.sup_of_two_exists weak.weak.inf_of_two_exists)

text {* Complete lattices *}

locale complete_lattice = partial_order +
  assumes sup_exists:
    "[| A \<subseteq> carrier L |] ==> EX s. least L s (Upper L A)"
    and inf_exists:
    "[| A \<subseteq> carrier L |] ==> EX i. greatest L i (Lower L A)"

sublocale complete_lattice \<subseteq> lattice
proof
  fix x y
  assume a: "x \<in> carrier L" "y \<in> carrier L"
  thus "\<exists>s. is_lub L s {x, y}"
    by (rule_tac sup_exists[of "{x, y}"], auto)
  from a show "\<exists>s. is_glb L s {x, y}"
    by (rule_tac inf_exists[of "{x, y}"], auto)
qed

sublocale complete_lattice < weak: weak_complete_lattice
  by standard (auto intro: sup_exists inf_exists)

text {* Introduction rule: the usual definition of complete lattice *}

lemma (in partial_order) complete_latticeI:
  assumes sup_exists:
    "!!A. [| A \<subseteq> carrier L |] ==> EX s. least L s (Upper L A)"
    and inf_exists:
    "!!A. [| A \<subseteq> carrier L |] ==> EX i. greatest L i (Lower L A)"
  shows "complete_lattice L"
  by standard (auto intro: sup_exists inf_exists)

theorem (in partial_order) complete_lattice_criterion1:
  assumes top_exists: "EX g. greatest L g (carrier L)"
    and inf_exists:
      "!!A. [| A \<subseteq> carrier L; A ~= {} |] ==> EX i. greatest L i (Lower L A)"
  shows "complete_lattice L"
proof (rule complete_latticeI)
  from top_exists obtain top where top: "greatest L top (carrier L)" ..
  fix A
  assume L: "A \<subseteq> carrier L"
  let ?B = "Upper L A"
  from L top have "top \<in> ?B" by (fast intro!: Upper_memI intro: greatest_le)
  then have B_non_empty: "?B ~= {}" by fast
  have B_L: "?B \<subseteq> carrier L" by simp
  from inf_exists [OF B_L B_non_empty]
  obtain b where b_inf_B: "greatest L b (Lower L ?B)" ..
  have "least L b (Upper L A)"
apply (rule least_UpperI)
   apply (rule greatest_le [where A = "Lower L ?B"])
    apply (rule b_inf_B)
   apply (rule Lower_memI)
    apply (erule Upper_memD [THEN conjunct1])
     apply assumption
    apply (rule L)
   apply (fast intro: L [THEN subsetD])
  apply (erule greatest_Lower_below [OF b_inf_B])
  apply simp
 apply (rule L)
apply (rule greatest_closed [OF b_inf_B])
done
  then show "EX s. least L s (Upper L A)" ..
next
  fix A
  assume L: "A \<subseteq> carrier L"
  show "EX i. greatest L i (Lower L A)"
  proof (cases "A = {}")
    case True then show ?thesis
      by (simp add: top_exists)
  next
    case False with L show ?thesis
      by (rule inf_exists)
  qed
qed

(* TODO: prove dual version *)


context complete_lattice
begin

lemma LFP_unfold: 
  "\<lbrakk> Mono f; f \<in> carrier L \<rightarrow> carrier L \<rbrakk> \<Longrightarrow> \<mu> f = f (\<mu> f)"
  using eq_is_equal weak.LFP_weak_unfold by auto

lemma LFP_const:
  "t \<in> carrier L \<Longrightarrow> \<mu> (\<lambda> x. t) = t"
  by (simp add: local.le_antisym weak.LFP_greatest weak.LFP_lowerbound)

lemma LFP_id:
  "\<mu> id = \<bottom>"
  by (simp add: local.le_antisym weak.LFP_lowerbound weak.bottom_closed weak.bottom_lower)

lemma GFP_unfold:
  "\<lbrakk> Mono f; f \<in> carrier L \<rightarrow> carrier L \<rbrakk> \<Longrightarrow> \<nu> f = f (\<nu> f)"
  using eq_is_equal weak.GFP_weak_unfold by auto

lemma GFP_const:
  "t \<in> carrier L \<Longrightarrow> \<nu> (\<lambda> x. t) = t"
  by (simp add: local.le_antisym weak.GFP_least weak.GFP_upperbound)

lemma GFP_id:
  "\<nu> id = \<top>"
  using weak.GFP_upperbound by auto

end

lemma equivalence_subset:
  assumes "equivalence L" "A \<subseteq> carrier L"
  shows "equivalence (L\<lparr> carrier := A \<rparr>)"
proof -
  interpret L: equivalence L
    by (simp add: assms)
  show ?thesis
    by (unfold_locales, simp_all add: L.sym assms rev_subsetD, meson L.trans assms(2) contra_subsetD)
qed

lemma weak_partial_order_subset:
  assumes "weak_partial_order L" "A \<subseteq> carrier L"
  shows "weak_partial_order (L\<lparr> carrier := A \<rparr>)"
proof -
  interpret L: weak_partial_order L
    by (simp add: assms)
  interpret equivalence "(L\<lparr> carrier := A \<rparr>)"
    by (simp add: L.equivalence_axioms assms(2) equivalence_subset)
  show ?thesis
    apply (unfold_locales, simp_all)
    using assms(2) apply auto[1]
    using assms(2) apply auto[1]
    apply (meson L.le_trans assms(2) contra_subsetD)
    apply (meson L.le_cong assms(2) subsetCE)
  done
qed

context weak_complete_lattice
begin

  lemma at_least_at_most_upper [dest]:
    "x \<in> \<lbrace>a..b\<rbrace> \<Longrightarrow> x \<sqsubseteq> b"
    by (simp add: at_least_at_most_def)

  lemma at_least_at_most_lower [dest]:
    "x \<in> \<lbrace>a..b\<rbrace> \<Longrightarrow> a \<sqsubseteq> x"
    by (simp add: at_least_at_most_def)

  lemma at_least_at_most_closed: "\<lbrace>a..b\<rbrace> \<subseteq> carrier L"
    by (auto simp add: at_least_at_most_def)

  lemma at_least_at_most_member [intro]: 
    "\<lbrakk> x \<in> carrier L; a \<sqsubseteq> x; x \<sqsubseteq> b \<rbrakk> \<Longrightarrow> x \<in> \<lbrace>a..b\<rbrace>"
    by (simp add: at_least_at_most_def)

  lemma at_least_at_most_Sup:
    "\<lbrakk> a \<in> carrier L; b \<in> carrier L; a \<sqsubseteq> b \<rbrakk> \<Longrightarrow> \<Squnion> \<lbrace>a..b\<rbrace> .= b"
    apply (rule weak_le_antisym)
    apply (rule sup_least)
    apply (auto simp add: at_least_at_most_closed)
    apply (rule sup_upper)
    apply (auto simp add: at_least_at_most_closed)
  done

  lemma at_least_at_most_Inf:
    "\<lbrakk> a \<in> carrier L; b \<in> carrier L; a \<sqsubseteq> b \<rbrakk> \<Longrightarrow> \<Sqinter> \<lbrace>a..b\<rbrace> .= a"
    apply (rule weak_le_antisym)
    apply (rule inf_lower)
    apply (auto simp add: at_least_at_most_closed)
    apply (rule inf_greatest)
    apply (auto simp add: at_least_at_most_closed)
  done

end

lemma weak_complete_lattice_interval:
  assumes "weak_complete_lattice L" "a \<in> carrier L" "b \<in> carrier L" "a \<sqsubseteq>\<^bsub>L\<^esub> b"
  shows "weak_complete_lattice (L \<lparr> carrier := \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub> \<rparr>)"
proof -
  interpret L: weak_complete_lattice L
    by (simp add: assms)
  interpret weak_partial_order "L \<lparr> carrier := \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub> \<rparr>"
  proof -
    have "\<lbrace>a..b\<rbrace>\<^bsub>L\<^esub> \<subseteq> carrier L"
      by (auto, simp add: at_least_at_most_def)
    thus "weak_partial_order (L\<lparr>carrier := \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>\<rparr>)"
      by (simp add: L.weak_partial_order_axioms weak_partial_order_subset)
  qed

  show ?thesis
  proof
    fix A
    assume a: "A \<subseteq> carrier (L\<lparr>carrier := \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>\<rparr>)"
    show "\<exists>s. is_lub (L\<lparr>carrier := \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>\<rparr>) s A"
    proof (cases "A = {}")
      case True
      thus ?thesis
        by (rule_tac x="a" in exI, auto simp add: least_def assms)
    next
      case False
      show ?thesis
      proof (rule_tac x="\<Squnion>\<^bsub>L\<^esub> A" in exI, rule least_UpperI, simp_all)
        show "\<And> x. x \<in> A \<Longrightarrow> x \<sqsubseteq>\<^bsub>L\<^esub> \<Squnion>\<^bsub>L\<^esub>A"
          using a by (auto intro: L.sup_upper, meson L.at_least_at_most_closed L.sup_upper subset_trans)
        show "\<And>y. y \<in> Upper (L\<lparr>carrier := \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>\<rparr>) A \<Longrightarrow> \<Squnion>\<^bsub>L\<^esub>A \<sqsubseteq>\<^bsub>L\<^esub> y"
          using a L.at_least_at_most_closed by (rule_tac L.sup_least, auto simp add: Upper_def)
        from a show "A \<subseteq> \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>"
          by (auto)
        from a show "\<Squnion>\<^bsub>L\<^esub>A \<in> \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>"
          apply (rule_tac L.at_least_at_most_member)
          apply (auto)
          apply (meson L.at_least_at_most_closed L.sup_closed subset_trans)
          apply (meson False L.at_least_at_most_closed L.le_trans L.sup_closed L.sup_upper L.weak_complete_lattice_axioms assms(2) ex_in_conv set_rev_mp subset_trans weak_complete_lattice.at_least_at_most_lower)
          apply (rule L.sup_least)
          apply (auto simp add: assms)
          using L.at_least_at_most_closed apply blast
        done
      qed
    qed
    show "\<exists>s. is_glb (L\<lparr>carrier := \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>\<rparr>) s A"
    proof (cases "A = {}")
      case True
      thus ?thesis
        by (rule_tac x="b" in exI, auto simp add: greatest_def assms)
    next
      case False
      show ?thesis
      proof (rule_tac x="\<Sqinter>\<^bsub>L\<^esub> A" in exI, rule greatest_LowerI, simp_all)
        show "\<And>x. x \<in> A \<Longrightarrow> \<Sqinter>\<^bsub>L\<^esub>A \<sqsubseteq>\<^bsub>L\<^esub> x"
          using a L.at_least_at_most_closed by (auto intro!: L.inf_lower)
        show "\<And>y. y \<in> Lower (L\<lparr>carrier := \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>\<rparr>) A \<Longrightarrow> y \<sqsubseteq>\<^bsub>L\<^esub> \<Sqinter>\<^bsub>L\<^esub>A"
           using a L.at_least_at_most_closed by (rule_tac L.inf_greatest, auto simp add: Lower_def)
        from a show "A \<subseteq> \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>"
          by (auto)
        from a show "\<Sqinter>\<^bsub>L\<^esub>A \<in> \<lbrace>a..b\<rbrace>\<^bsub>L\<^esub>"
          apply (rule_tac L.at_least_at_most_member)
          apply (auto)
          apply (meson L.at_least_at_most_closed L.inf_closed subset_trans)
          apply (meson L.at_least_at_most_closed L.at_least_at_most_lower L.inf_greatest assms(2) set_rev_mp subset_trans)
          apply (meson False L.at_least_at_most_closed L.inf_closed L.inf_lower L.le_trans L.weak_complete_lattice_axioms assms(3) ex_in_conv rev_subsetD subset_trans weak_complete_lattice.at_least_at_most_upper)          
        done
      qed
    qed
  qed
qed

text {* Fixed points of a lattice *}

definition "fps L f = {x \<in> carrier L. f x .=\<^bsub>L\<^esub> x}"

lemma fps_carrier [simp]:
  "fps L f \<subseteq> carrier L"
  by (auto simp add: fps_def)

lemma (in weak_complete_lattice) LFP_fixed_point [intro]:
  assumes "Mono f" "f \<in> carrier L \<rightarrow> carrier L"
  shows "\<mu> f \<in> fps L f"
  using assms
proof -
  have "f (\<mu> f) \<in> carrier L"
    using assms(2) by blast
  with assms show ?thesis
    by (simp add: LFP_closed LFP_weak_unfold fps_def local.sym mem_Collect_eq)
qed

lemma (in weak_complete_lattice) GFP_fixed_point [intro]:
  assumes "Mono f" "f \<in> carrier L \<rightarrow> carrier L"
  shows "\<nu> f \<in> fps L f"
  using assms
proof -
  have "f (\<nu> f) \<in> carrier L"
    using assms(2) by blast
  with assms show ?thesis
    by (simp add: GFP_closed GFP_weak_unfold fps_def local.sym mem_Collect_eq)
qed

lemma (in weak_complete_lattice) fps_sup_image: 
  assumes "f \<in> carrier L \<rightarrow> carrier L" "A \<subseteq> fps L f" 
  shows "\<Squnion> (f ` A) .= \<Squnion> A"
proof -
  from assms(2) have AL: "A \<subseteq> carrier L"
    by (auto simp add: fps_def)
  
  show ?thesis
  proof (rule sup_cong, simp_all add: AL)
    from assms(1) AL show "f ` A \<subseteq> carrier L"
      by (auto)
    from assms(2) show "f ` A {.=} A"
      apply (auto simp add: fps_def)
      apply (rule set_eqI2)
      apply blast
      apply (rename_tac b)
      apply (rule_tac x="f b" in bexI)
      apply (metis (mono_tags, lifting) Ball_Collect assms(1) ftype_carrier local.sym)
      apply (auto)
    done
  qed
qed

lemma (in weak_complete_lattice) fps_idem:
  "\<lbrakk> f \<in> carrier L \<rightarrow> carrier L; idempotent (carrier L) f \<rbrakk> \<Longrightarrow> fps L f {.=} f ` carrier L"
  apply (rule set_eqI2)
  apply (auto simp add: idempotent_def fps_def)
  using local.sym apply blast
  apply (metis ftype_carrier local.refl)
done

text {* The set of fixed points of a complete lattice is itself a complete lattice *}

theorem Knaster_Tarski:
  assumes "weak_complete_lattice L" "f \<in> carrier L \<rightarrow> carrier L" "isotone L L f"
  shows "weak_complete_lattice (L\<lparr>carrier := fps L f\<rparr>)" (is "weak_complete_lattice ?L'")
proof -
  interpret L: weak_complete_lattice L
    by (simp add: assms)
  interpret weak_partial_order ?L'
  proof -
    have "{x \<in> carrier L. f x .=\<^bsub>L\<^esub> x} \<subseteq> carrier L"
      by (auto)
    thus "weak_partial_order ?L'"
      by (simp add: L.weak_partial_order_axioms weak_partial_order_subset)
  qed
  show ?thesis
  proof (unfold_locales, simp_all)
    fix A
    assume A: "A \<subseteq> fps L f"
    show "\<exists>s. is_lub (L\<lparr>carrier := fps L f\<rparr>) s A"
    proof
      from A have AL: "A \<subseteq> carrier L"
        by (meson fps_carrier subset_eq)

      let ?w = "\<Squnion>\<^bsub>L\<^esub> A"
      have w: "f (\<Squnion>\<^bsub>L\<^esub>A) \<in> carrier L"
        by (simp add: AL L.ftype_carrier assms(2))

      have pf_w: "(\<Squnion>\<^bsub>L\<^esub> A) \<sqsubseteq>\<^bsub>L\<^esub> f (\<Squnion>\<^bsub>L\<^esub> A)"
      proof (rule L.sup_least, simp_all add: AL w)
        fix x
        assume xA: "x \<in> A"
        hence "x \<in> fps L f"
          using A subsetCE by blast
        hence "f x .=\<^bsub>L\<^esub> x"
          by (auto simp add: fps_def)
        moreover have "f x \<sqsubseteq>\<^bsub>L\<^esub> f (\<Squnion>\<^bsub>L\<^esub>A)"
          by (meson AL L.sup_closed L.sup_upper assms(3) subsetCE use_iso1 xA)
        ultimately show "x \<sqsubseteq>\<^bsub>L\<^esub> f (\<Squnion>\<^bsub>L\<^esub>A)"
          by (meson AL L.ftype_carrier L.le_cong L.refl assms(2) subsetCE w xA)
      qed

      have f_top_chain: "f ` \<lbrace>?w..\<top>\<^bsub>L\<^esub>\<rbrace>\<^bsub>L\<^esub> \<subseteq> \<lbrace>?w..\<top>\<^bsub>L\<^esub>\<rbrace>\<^bsub>L\<^esub>"
      proof (auto simp add: at_least_at_most_def)
        fix x
        assume b: "x \<in> carrier L" "\<Squnion>\<^bsub>L\<^esub>A \<sqsubseteq>\<^bsub>L\<^esub> x"
        from b show fx: "f x \<in> carrier L"
          using assms(2) by blast
        show "\<Squnion>\<^bsub>L\<^esub>A \<sqsubseteq>\<^bsub>L\<^esub> f x"
        proof -
          have "?w \<sqsubseteq>\<^bsub>L\<^esub> f ?w"
          proof (rule_tac L.sup_least, simp_all add: AL w)
            fix y
            assume c: "y \<in> A" 
            with assms have "y .=\<^bsub>L\<^esub> f y"
              by (metis (no_types, lifting) A L.ftype_carrier L.sym fps_def mem_Collect_eq subset_eq)
            moreover have "y \<sqsubseteq>\<^bsub>L\<^esub> \<Squnion>\<^bsub>L\<^esub>A"
              by (simp add: AL L.sup_upper c(1))
            ultimately show "y \<sqsubseteq>\<^bsub>L\<^esub> f (\<Squnion>\<^bsub>L\<^esub>A)"
              by (meson fps_def AL L.ftype_carrier L.refl L.weak_complete_lattice_axioms assms(2) assms(3) c(1) isotone_def rev_subsetD weak_complete_lattice.sup_closed weak_partial_order.le_cong)
          qed
          thus ?thesis
            by (meson AL L.ftype_carrier L.le_trans L.sup_closed assms(2) assms(3) b(1) b(2) use_iso2)
        qed
   
        show "f x \<sqsubseteq>\<^bsub>L\<^esub> \<top>\<^bsub>L\<^esub>"
          by (simp add: fx)
      qed
  
      let ?L' = "L\<lparr> carrier := \<lbrace>?w..\<top>\<^bsub>L\<^esub>\<rbrace>\<^bsub>L\<^esub> \<rparr>"

      interpret L': weak_complete_lattice ?L'
        by (auto intro: weak_complete_lattice_interval simp add: L.weak_complete_lattice_axioms AL)

      let ?L'' = "L\<lparr> carrier := fps L f \<rparr>"

      show "is_lub ?L'' (\<mu>\<^bsub>?L'\<^esub> f) A"
      proof (rule least_UpperI, simp_all)
        fix x
        assume "x \<in> Upper ?L'' A"
        hence "\<mu>\<^bsub>?L'\<^esub> f \<sqsubseteq>\<^bsub>?L'\<^esub> x"
          apply (rule_tac L'.LFP_lowerbound)
          apply (auto simp add: Upper_def)
          apply (simp add: A AL L.at_least_at_most_member L.sup_least set_rev_mp)          
          apply (simp add: L.ftype_carrier assms(2) fps_def)
        done
        thus " \<mu>\<^bsub>?L'\<^esub> f \<sqsubseteq>\<^bsub>L\<^esub> x"
          by (simp)
      next
        fix x
        assume xA: "x \<in> A"
        show "x \<sqsubseteq>\<^bsub>L\<^esub> \<mu>\<^bsub>?L'\<^esub> f"
        proof -
          have "\<mu>\<^bsub>?L'\<^esub> f \<in> carrier ?L'"
            by blast
          thus ?thesis
            by (simp, meson AL L.at_least_at_most_closed L.at_least_at_most_lower L.le_trans L.sup_closed L.sup_upper xA subsetCE)
        qed
      next
        show "A \<subseteq> fps L f"
          by (simp add: A)
      next
        show "\<mu>\<^bsub>?L'\<^esub> f \<in> fps L f"
        proof (auto simp add: fps_def)
          have "\<mu>\<^bsub>?L'\<^esub> f \<in> carrier ?L'"
            by (rule L'.LFP_closed)
          thus c:"\<mu>\<^bsub>?L'\<^esub> f \<in> carrier L"
             by (auto simp add: at_least_at_most_def)
          have "\<mu>\<^bsub>?L'\<^esub> f .=\<^bsub>?L'\<^esub> f (\<mu>\<^bsub>?L'\<^esub> f)"
          proof (rule "L'.LFP_weak_unfold", simp_all)
            show "f \<in> \<lbrace>\<Squnion>\<^bsub>L\<^esub>A..\<top>\<^bsub>L\<^esub>\<rbrace>\<^bsub>L\<^esub> \<rightarrow> \<lbrace>\<Squnion>\<^bsub>L\<^esub>A..\<top>\<^bsub>L\<^esub>\<rbrace>\<^bsub>L\<^esub>"
              apply (auto simp add: Pi_def at_least_at_most_def)
              using assms(2) apply blast
              apply (meson AL L.ftype_carrier L.le_trans L.sup_closed assms(2) assms(3) pf_w use_iso2)
              using assms(2) apply blast
            done
            from assms(3) show "Mono\<^bsub>L\<lparr>carrier := \<lbrace>\<Squnion>\<^bsub>L\<^esub>A..\<top>\<^bsub>L\<^esub>\<rbrace>\<^bsub>L\<^esub>\<rparr>\<^esub> f"
              apply (auto simp add: isotone_def)
              using L'.weak_partial_order_axioms apply blast
              using L.at_least_at_most_closed apply blast
            done
          qed
          thus "f (\<mu>\<^bsub>?L'\<^esub> f) .=\<^bsub>L\<^esub> \<mu>\<^bsub>?L'\<^esub> f"
            by (simp add: L.equivalence_axioms L.ftype_carrier c assms(2) equivalence.sym) 
        qed
      qed
    qed
    show "\<exists>i. is_glb (L\<lparr>carrier := fps L f\<rparr>) i A"
    proof
      from A have AL: "A \<subseteq> carrier L"
        by (meson fps_carrier subset_eq)

      let ?w = "\<Sqinter>\<^bsub>L\<^esub> A"
      have w: "f (\<Sqinter>\<^bsub>L\<^esub>A) \<in> carrier L"
        by (simp add: AL L.ftype_carrier assms(2))

      have pf_w: "f (\<Sqinter>\<^bsub>L\<^esub> A) \<sqsubseteq>\<^bsub>L\<^esub> (\<Sqinter>\<^bsub>L\<^esub> A)"
      proof (rule L.inf_greatest, simp_all add: AL w)
        fix x
        assume xA: "x \<in> A"
        hence "x \<in> fps L f"
          using A subsetCE by blast
        hence "f x .=\<^bsub>L\<^esub> x"
          by (auto simp add: fps_def)
        moreover have "f (\<Sqinter>\<^bsub>L\<^esub>A) \<sqsubseteq>\<^bsub>L\<^esub> f x"
          by (meson AL L.inf_closed L.inf_lower assms(3) subsetCE use_iso2 xA)
        ultimately show "f (\<Sqinter>\<^bsub>L\<^esub>A) \<sqsubseteq>\<^bsub>L\<^esub> x"
          by (meson AL L.ftype_carrier L.le_cong L.refl assms(2) subsetCE w xA)
      qed

      have f_bot_chain: "f ` \<lbrace>\<bottom>\<^bsub>L\<^esub>..?w\<rbrace>\<^bsub>L\<^esub> \<subseteq> \<lbrace>\<bottom>\<^bsub>L\<^esub>..?w\<rbrace>\<^bsub>L\<^esub>"
      proof (auto simp add: at_least_at_most_def)
        fix x
        assume b: "x \<in> carrier L" "x \<sqsubseteq>\<^bsub>L\<^esub> \<Sqinter>\<^bsub>L\<^esub>A"
        from b show fx: "f x \<in> carrier L"
          using assms(2) by blast
        show "f x \<sqsubseteq>\<^bsub>L\<^esub> \<Sqinter>\<^bsub>L\<^esub>A"
        proof -
          have "f ?w \<sqsubseteq>\<^bsub>L\<^esub> ?w"
          proof (rule_tac L.inf_greatest, simp_all add: AL w)
            fix y
            assume c: "y \<in> A" 
            with assms have "y .=\<^bsub>L\<^esub> f y"
              by (metis (no_types, lifting) A L.ftype_carrier L.sym fps_def mem_Collect_eq subset_eq)
            moreover have "\<Sqinter>\<^bsub>L\<^esub>A \<sqsubseteq>\<^bsub>L\<^esub> y"
              by (simp add: AL L.inf_lower c)
            ultimately show "f (\<Sqinter>\<^bsub>L\<^esub>A) \<sqsubseteq>\<^bsub>L\<^esub> y"
              by (meson AL L.inf_closed L.le_trans c pf_w set_rev_mp w)
          qed
          thus ?thesis
            by (meson AL L.inf_closed L.le_trans assms(3) b(1) b(2) fx use_iso2 w)
        qed
   
        show "\<bottom>\<^bsub>L\<^esub> \<sqsubseteq>\<^bsub>L\<^esub> f x"
          by (simp add: L.bottom_lower fx)
      qed
  
      let ?L' = "L\<lparr> carrier := \<lbrace>\<bottom>\<^bsub>L\<^esub>..?w\<rbrace>\<^bsub>L\<^esub> \<rparr>"

      interpret L': weak_complete_lattice ?L'
        by (auto intro!: weak_complete_lattice_interval simp add: L.weak_complete_lattice_axioms AL L.bottom_closed L.bottom_lower)

      let ?L'' = "L\<lparr> carrier := fps L f \<rparr>"

      show "is_glb ?L'' (\<nu>\<^bsub>?L'\<^esub> f) A"
      proof (rule greatest_LowerI, simp_all)
        fix x
        assume "x \<in> Lower ?L'' A"
        hence "x \<sqsubseteq>\<^bsub>?L'\<^esub> \<nu>\<^bsub>?L'\<^esub> f"
          apply (rule_tac L'.GFP_upperbound)
          apply (auto simp add: Lower_def)
          apply (meson A AL L.at_least_at_most_member L.bottom_lower L.weak_complete_lattice_axioms fps_carrier subsetCE weak_complete_lattice.inf_greatest)
          apply (simp add: L.ftype_carrier L.sym assms(2) fps_def)          
        done
        thus "x \<sqsubseteq>\<^bsub>L\<^esub> \<nu>\<^bsub>?L'\<^esub> f"
          by (simp)
      next
        fix x
        assume xA: "x \<in> A"
        show "\<nu>\<^bsub>?L'\<^esub> f \<sqsubseteq>\<^bsub>L\<^esub> x"
        proof -
          have "\<nu>\<^bsub>?L'\<^esub> f \<in> carrier ?L'"
            by blast
          thus ?thesis
            by (simp, meson AL L.at_least_at_most_closed L.at_least_at_most_upper L.inf_closed L.inf_lower L.le_trans subsetCE xA)     
        qed
      next
        show "A \<subseteq> fps L f"
          by (simp add: A)
      next
        show "\<nu>\<^bsub>?L'\<^esub> f \<in> fps L f"
        proof (auto simp add: fps_def)
          have "\<nu>\<^bsub>?L'\<^esub> f \<in> carrier ?L'"
            by (rule L'.GFP_closed)
          thus c:"\<nu>\<^bsub>?L'\<^esub> f \<in> carrier L"
             by (auto simp add: at_least_at_most_def)
          have "\<nu>\<^bsub>?L'\<^esub> f .=\<^bsub>?L'\<^esub> f (\<nu>\<^bsub>?L'\<^esub> f)"
          proof (rule "L'.GFP_weak_unfold", simp_all)
            show "f \<in> \<lbrace>\<bottom>\<^bsub>L\<^esub>..?w\<rbrace>\<^bsub>L\<^esub> \<rightarrow> \<lbrace>\<bottom>\<^bsub>L\<^esub>..?w\<rbrace>\<^bsub>L\<^esub>"
              apply (auto simp add: Pi_def at_least_at_most_def)
              using assms(2) apply blast
              apply (simp add: L.bottom_lower L.ftype_carrier assms(2))
              apply (meson AL L.ftype_carrier L.inf_closed L.le_trans assms(2) assms(3) pf_w use_iso2)
            done
            from assms(3) show "Mono\<^bsub>L\<lparr>carrier := \<lbrace>\<bottom>\<^bsub>L\<^esub>..?w\<rbrace>\<^bsub>L\<^esub>\<rparr>\<^esub> f"
              apply (auto simp add: isotone_def)
              using L'.weak_partial_order_axioms apply blast
              using L.at_least_at_most_closed apply blast
            done
          qed
          thus "f (\<nu>\<^bsub>?L'\<^esub> f) .=\<^bsub>L\<^esub> \<nu>\<^bsub>?L'\<^esub> f"
            by (simp add: L.equivalence_axioms L.ftype_carrier c assms(2) equivalence.sym) 
        qed
      qed
    qed
  qed
qed
  
theorem Knaster_Tarski_idem:
  assumes "complete_lattice L" "f \<in> carrier L \<rightarrow> carrier L" "isotone L L f" "idempotent (carrier L) f"
  shows "complete_lattice (L\<lparr>carrier := f ` carrier L\<rparr>)"
proof -
  interpret L: complete_lattice L
    by (simp add: assms)
  have "fps L f = f ` carrier L"
    using L.weak.fps_idem[OF assms(2) assms(4)]
    by (simp add: L.set_eq_is_eq)
  then interpret L': weak_complete_lattice "(L\<lparr>carrier := f ` carrier L\<rparr>)"
    by (metis Knaster_Tarski L.weak.weak_complete_lattice_axioms assms(2) assms(3))
  show ?thesis
    using L'.sup_exists L'.inf_exists
    by (unfold_locales, auto simp add: L.eq_is_equal)
qed

subsection {* Examples *}

subsubsection {* The Powerset of a Set is a Complete Lattice *}

theorem powerset_is_complete_lattice:
  "complete_lattice (| carrier = Pow A, eq = op =, le = op \<subseteq> |)"
  (is "complete_lattice ?L")
proof (rule partial_order.complete_latticeI)
  show "partial_order ?L"
    by standard auto
next
  fix B
  assume "B \<subseteq> carrier ?L"
  then have "least ?L (\<Union> B) (Upper ?L B)"
    by (fastforce intro!: least_UpperI simp: Upper_def)
  then show "EX s. least ?L s (Upper ?L B)" ..
next
  fix B
  assume "B \<subseteq> carrier ?L"
  then have "greatest ?L (\<Inter> B \<inter> A) (Lower ?L B)"
    txt {* @{term "\<Inter> B"} is not the infimum of @{term B}:
      @{term "\<Inter> {} = UNIV"} which is in general bigger than @{term "A"}! *}
    by (fastforce intro!: greatest_LowerI simp: Lower_def)
  then show "EX i. greatest ?L i (Lower ?L B)" ..
qed

text {* An other example, that of the lattice of subgroups of a group,
  can be found in Group theory (Section~\ref{sec:subgroup-lattice}). *}

end
