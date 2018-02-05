section {* Designs *}

theory utp_designs
imports
  "../utp/utp"
begin

text {* In UTP, in order to explicitly record the termination of a program,
a subset of alphabetized relations is introduced. These relations are called
designs and their alphabet should contain the special boolean observational variable ok.
It is used to record the start and termination of a program. *}

subsection {* Definitions *}

named_theorems ndes and ndes_simp
  
text {* In the following, the definitions of designs alphabets, designs and
healthiness (well-formedness) conditions are given. The healthiness conditions of
designs are defined by $H1$, $H2$, $H3$ and $H4$.*}

alphabet des_vars =
  ok :: bool

declare des_vars.defs [lens_defs]
  
text {*
  The two locale interpretations below are a technicality to improve automatic
  proof support via the predicate and relational tactics. This is to enable the
  (re-)interpretation of state spaces to remove any occurrences of lens types
  after the proof tactics @{method pred_simp} and @{method rel_simp}, or any
  of their derivatives have been applied. Eventually, it would be desirable to
  automate both interpretations as part of a custom outer command for defining
  alphabets.
*}

interpretation des_vars: lens_interp "\<lambda>r. (ok\<^sub>v r, more r)"
apply (unfold_locales)
apply (rule injI)
apply (clarsimp)
done

interpretation des_vars_rel:
  lens_interp "\<lambda>(r, r'). (ok\<^sub>v r, ok\<^sub>v r', more r, more r')"
apply (unfold_locales)
apply (rule injI)
apply (clarsimp)
done

lemma ok_ord [usubst]:
  "$ok \<prec>\<^sub>v $ok\<acute>"
  by (simp add: var_name_ord_def)

type_synonym '\<alpha> des  = "'\<alpha> des_vars_scheme"
type_synonym ('\<alpha>, '\<beta>) rel_des = "('\<alpha> des, '\<beta> des) rel"
type_synonym '\<alpha> hrel_des = "('\<alpha> des) hrel"

translations
  (type) "'\<alpha> des" <= (type) "'\<alpha> des_vars_scheme"
  (type) "'\<alpha> des" <= (type) "'\<alpha> des_vars_ext"
  (type) "('\<alpha>, '\<beta>) rel_des" <= (type) "('\<alpha> des, '\<beta> des) rel"
  (type) "'\<alpha> hrel_des" <= (type) "'\<alpha> des hrel"
  
notation des_vars_child_lens ("\<Sigma>\<^sub>D")

lemma ok_des_bij_lens: "bij_lens (ok +\<^sub>L \<Sigma>\<^sub>D)"
  by (unfold_locales, simp_all add: ok_def des_vars_child_lens_def lens_plus_def prod.case_eq_if)

text {* Define the lens functor for designs *}
  
definition lmap_des_vars :: "('\<alpha> \<Longrightarrow> '\<beta>) \<Rightarrow> ('\<alpha> des_vars_scheme \<Longrightarrow> '\<beta> des_vars_scheme)" ("lmap\<^sub>D")
where [lens_defs]: "lmap_des_vars = lmap[des_vars]"

lemma lmap_des_vars: "vwb_lens f \<Longrightarrow> vwb_lens (lmap_des_vars f)"
  by (unfold_locales, auto simp add: lens_defs des_vars.defs)

lemma lmap_id: "lmap\<^sub>D 1\<^sub>L = 1\<^sub>L"
  by (simp add: lens_defs des_vars.defs fun_eq_iff)

lemma lmap_comp: "lmap\<^sub>D (f ;\<^sub>L g) = lmap\<^sub>D f ;\<^sub>L lmap\<^sub>D g"
  by (simp add: lens_defs des_vars.defs fun_eq_iff)

text {* The following notations define liftings from non-design predicates into design
  predicates using alphabet extensions. *}

abbreviation lift_desr ("\<lceil>_\<rceil>\<^sub>D")
where "\<lceil>P\<rceil>\<^sub>D \<equiv> P \<oplus>\<^sub>p (\<Sigma>\<^sub>D \<times>\<^sub>L \<Sigma>\<^sub>D)"

abbreviation lift_pre_desr ("\<lceil>_\<rceil>\<^sub>D\<^sub><")
where "\<lceil>p\<rceil>\<^sub>D\<^sub>< \<equiv> \<lceil>\<lceil>p\<rceil>\<^sub><\<rceil>\<^sub>D"

abbreviation lift_post_desr ("\<lceil>_\<rceil>\<^sub>D\<^sub>>")
where "\<lceil>p\<rceil>\<^sub>D\<^sub>> \<equiv> \<lceil>\<lceil>p\<rceil>\<^sub>>\<rceil>\<^sub>D"

abbreviation drop_desr ("\<lfloor>_\<rfloor>\<^sub>D")
where "\<lfloor>P\<rfloor>\<^sub>D \<equiv> P \<restriction>\<^sub>e (\<Sigma>\<^sub>D \<times>\<^sub>L \<Sigma>\<^sub>D)"

abbreviation dcond :: "('\<alpha>, '\<beta>) rel_des \<Rightarrow> '\<alpha> upred \<Rightarrow> ('\<alpha>, '\<beta>) rel_des \<Rightarrow> ('\<alpha>, '\<beta>) rel_des" 
  ("(3_ \<triangleleft> _ \<triangleright>\<^sub>D/ _)" [52,0,53] 52)
where "P \<triangleleft> b \<triangleright>\<^sub>D Q \<equiv> P \<triangleleft> \<lceil>b\<rceil>\<^sub>D\<^sub>< \<triangleright> Q"
  
definition design::"('\<alpha>, '\<beta>) rel_des \<Rightarrow> ('\<alpha>, '\<beta>) rel_des \<Rightarrow> ('\<alpha>, '\<beta>) rel_des" (infixl "\<turnstile>" 60)
where "P \<turnstile> Q = ($ok \<and> P \<Rightarrow> $ok\<acute> \<and> Q)"

text {* An rdesign is a design that uses the Isabelle type system to prevent reference to ok in the
        assumption and commitment. *}

definition rdesign::"('\<alpha>, '\<beta>) rel \<Rightarrow> ('\<alpha>, '\<beta>) rel \<Rightarrow> ('\<alpha>, '\<beta>) rel_des" (infixl "\<turnstile>\<^sub>r" 60)
where "(P \<turnstile>\<^sub>r Q) = \<lceil>P\<rceil>\<^sub>D \<turnstile> \<lceil>Q\<rceil>\<^sub>D"
  
text {* An ndesign is a normal design, i.e. where the assumption is a condition *}

definition ndesign::"'\<alpha> cond \<Rightarrow> ('\<alpha>, '\<beta>) rel \<Rightarrow> ('\<alpha>, '\<beta>) rel_des" (infixl "\<turnstile>\<^sub>n" 60)
where "(p \<turnstile>\<^sub>n Q) = (\<lceil>p\<rceil>\<^sub>< \<turnstile>\<^sub>r Q)"

definition skip_d :: "'\<alpha> hrel_des" ("II\<^sub>D")
where "II\<^sub>D \<equiv> (true \<turnstile>\<^sub>r II)"

definition assigns_d :: "'\<alpha> usubst \<Rightarrow> '\<alpha> hrel_des" ("\<langle>_\<rangle>\<^sub>D")
where "assigns_d \<sigma> = (true \<turnstile>\<^sub>r assigns_r \<sigma>)"

syntax
  "_assignmentd" :: "svids \<Rightarrow> uexprs \<Rightarrow> logic"  (infixr ":=\<^sub>D" 72)

translations
  "_assignmentd xs vs" => "CONST assigns_d (_mk_usubst (CONST id) xs vs)"
  "_assignmentd x v" <= "CONST assigns_d (CONST subst_upd (CONST id) x v)"
  "_assignmentd x v" <= "_assignmentd (_spvar x) v"
  "x,y :=\<^sub>D u,v" <= "CONST assigns_d (CONST subst_upd (CONST subst_upd (CONST id) (CONST svar x) u) (CONST svar y) v)"
  
definition J :: "'\<alpha> hrel_des"
where "J = (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)"

definition "H1 (P)  \<equiv>  $ok \<Rightarrow> P"

definition "H2 (P)  \<equiv>  P ;; J"

definition "H3 (P)  \<equiv>  P ;; II\<^sub>D"

definition "H4 (P)  \<equiv> ((P;;true) \<Rightarrow> P)"

syntax
  "_ok_f"  :: "logic \<Rightarrow> logic" ("_\<^sup>f" [1000] 1000)
  "_ok_t"  :: "logic \<Rightarrow> logic" ("_\<^sup>t" [1000] 1000)
  "_top_d" :: "logic" ("\<top>\<^sub>D")

translations
  "P\<^sup>f" \<rightleftharpoons> "CONST usubst (CONST subst_upd CONST id (CONST ovar CONST ok) false) P"
  "P\<^sup>t" \<rightleftharpoons> "CONST usubst (CONST subst_upd CONST id (CONST ovar CONST ok) true) P"
  "\<top>\<^sub>D" => "CONST not_upred (CONST utp_expr.var (CONST ivar CONST ok))"

definition bot_d :: "('\<alpha>, '\<beta>) rel_des" ("\<bottom>\<^sub>D") where
[upred_defs]: "\<bottom>\<^sub>D = (false \<turnstile> false)"
  
definition pre_design :: "('\<alpha>, '\<beta>) rel_des \<Rightarrow> ('\<alpha>, '\<beta>) rel" ("pre\<^sub>D") where
"pre\<^sub>D(P) = \<lfloor>\<not> P\<lbrakk>true,false/$ok,$ok\<acute>\<rbrakk>\<rfloor>\<^sub>D"

definition post_design :: "('\<alpha>, '\<beta>) rel_des \<Rightarrow> ('\<alpha>, '\<beta>) rel" ("post\<^sub>D") where
"post\<^sub>D(P) = \<lfloor>P\<lbrakk>true,true/$ok,$ok\<acute>\<rbrakk>\<rfloor>\<^sub>D"

definition wp_design :: "('\<alpha>, '\<beta>) rel_des \<Rightarrow> '\<beta> cond \<Rightarrow> '\<alpha> cond" (infix "wp\<^sub>D" 60) where
"Q wp\<^sub>D r = (\<lfloor>pre\<^sub>D(Q) ;; true :: ('\<alpha>, '\<beta>) rel\<rfloor>\<^sub>< \<and> (post\<^sub>D(Q) wp r))"

declare design_def [upred_defs]
declare rdesign_def [upred_defs]
declare ndesign_def [upred_defs]
declare skip_d_def [upred_defs]
declare J_def [upred_defs]
declare pre_design_def [upred_defs]
declare post_design_def [upred_defs]
declare wp_design_def [upred_defs]
declare assigns_d_def [upred_defs]

declare H1_def [upred_defs]
declare H2_def [upred_defs]
declare H3_def [upred_defs]
declare H4_def [upred_defs]

lemma drop_desr_inv [simp]: "\<lfloor>\<lceil>P\<rceil>\<^sub>D\<rfloor>\<^sub>D = P"
  by (simp add: arestr_aext prod_mwb_lens)

lemma lift_desr_inv:
  fixes P :: "('\<alpha>, '\<beta>) rel_des"
  assumes "$ok \<sharp> P" "$ok\<acute> \<sharp> P"
  shows "\<lceil>\<lfloor>P\<rfloor>\<^sub>D\<rceil>\<^sub>D = P"
proof -
  have "bij_lens (\<Sigma>\<^sub>D \<times>\<^sub>L \<Sigma>\<^sub>D +\<^sub>L (in_var ok +\<^sub>L out_var ok) :: (_, '\<alpha> des_vars_scheme \<times> '\<beta> des_vars_scheme) lens)"
    (is "bij_lens (?P)")
  proof -
    have "?P \<approx>\<^sub>L (ok +\<^sub>L \<Sigma>\<^sub>D) \<times>\<^sub>L (ok +\<^sub>L \<Sigma>\<^sub>D)" (is "?P \<approx>\<^sub>L ?Q")
      apply (simp add: in_var_def out_var_def prod_as_plus)
      apply (simp add: prod_as_plus[THEN sym])
      apply (meson lens_equiv_sym lens_equiv_trans lens_indep_prod lens_plus_comm lens_plus_prod_exchange des_vars_indeps(1))
    done
    moreover have "bij_lens ?Q"
      by (simp add: ok_des_bij_lens prod_bij_lens)
    ultimately show ?thesis
      by (metis bij_lens_equiv lens_equiv_sym)
  qed

  with assms show ?thesis
    apply (rule_tac aext_arestr[of _ "in_var ok +\<^sub>L out_var ok"])
    apply (simp add: prod_mwb_lens)
    apply (simp)
    apply (metis alpha_in_var lens_indep_prod lens_indep_sym des_vars_indeps(1) out_var_def prod_as_plus)
    using unrest_var_comp apply blast
  done
qed

subsection {* Design laws *}

lemma unrest_out_des_lift [unrest]: "out\<alpha> \<sharp> p \<Longrightarrow> out\<alpha> \<sharp> \<lceil>p\<rceil>\<^sub>D"
  by (pred_simp)

lemma lift_dist_seq [simp]:
  "\<lceil>P ;; Q\<rceil>\<^sub>D = (\<lceil>P\<rceil>\<^sub>D ;; \<lceil>Q\<rceil>\<^sub>D)"
  by (rel_auto)

lemma lift_des_skip_dr_unit_unrest: "$ok\<acute> \<sharp> P \<Longrightarrow> (P ;; \<lceil>II\<rceil>\<^sub>D) = P"
  by (rel_auto)
    
lemma true_is_design:
  "(false \<turnstile> true) = true"
  by (rel_auto)

lemma true_is_rdesign:
  "(false \<turnstile>\<^sub>r true) = true"
  by (rel_auto)
    
lemma bot_d_true:
  "\<bottom>\<^sub>D = true"
  by (rel_auto)  
  
lemma bot_d_ndes_def [ndes_simp]:
  "\<bottom>\<^sub>D = (false \<turnstile>\<^sub>n true)"
  by (rel_auto)

lemma design_false_pre:
  "(false \<turnstile> P) = true"
  by (rel_auto)

lemma rdesign_false_pre:
  "(false \<turnstile>\<^sub>r P) = true"
  by (rel_auto)

lemma ndesign_false_pre:
  "(false \<turnstile>\<^sub>n P) = true"
  by (rel_auto)

lemma ndesign_miracle:
  "(true \<turnstile>\<^sub>n false) = \<top>\<^sub>D"
  by (rel_auto)
    
lemma state_subst_design [usubst]:
  "\<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rceil>\<^sub>s \<dagger> (P \<turnstile>\<^sub>r Q) = (\<lceil>\<sigma>\<rceil>\<^sub>s \<dagger> P) \<turnstile>\<^sub>r (\<lceil>\<sigma>\<rceil>\<^sub>s \<dagger> Q)"
  by (rel_auto)
    
lemma ndesign_eq_intro:
  assumes "p\<^sub>1 = q\<^sub>1" "P\<^sub>2 = Q\<^sub>2"
  shows "p\<^sub>1 \<turnstile>\<^sub>n P\<^sub>2 = q\<^sub>1 \<turnstile>\<^sub>n Q\<^sub>2"
  by (simp add: assms)
    
theorem design_refinement:
  assumes
    "$ok \<sharp> P1" "$ok\<acute> \<sharp> P1" "$ok \<sharp> P2" "$ok\<acute> \<sharp> P2"
    "$ok \<sharp> Q1" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2" "$ok\<acute> \<sharp> Q2"
  shows "(P1 \<turnstile> Q1 \<sqsubseteq> P2 \<turnstile> Q2) \<longleftrightarrow> (`P1 \<Rightarrow> P2` \<and> `P1 \<and> Q2 \<Rightarrow> Q1`)"
proof -
  have "(P1 \<turnstile> Q1) \<sqsubseteq> (P2 \<turnstile> Q2) \<longleftrightarrow> `($ok \<and> P2 \<Rightarrow> $ok\<acute> \<and> Q2) \<Rightarrow> ($ok \<and> P1 \<Rightarrow> $ok\<acute> \<and> Q1)`"
    by (pred_auto)
  also with assms have "... = `(P2 \<Rightarrow> $ok\<acute> \<and> Q2) \<Rightarrow> (P1 \<Rightarrow> $ok\<acute> \<and> Q1)`"
    by (subst subst_bool_split[of "in_var ok"], simp_all, subst_tac)
  also with assms have "... = `(\<not> P2 \<Rightarrow> \<not> P1) \<and> ((P2 \<Rightarrow> Q2) \<Rightarrow> P1 \<Rightarrow> Q1)`"
    by (subst subst_bool_split[of "out_var ok"], simp_all, subst_tac)
  also have "... \<longleftrightarrow> `(P1 \<Rightarrow> P2)` \<and> `P1 \<and> Q2 \<Rightarrow> Q1`"
    by (pred_auto)
  finally show ?thesis .
qed

theorem rdesign_refinement:
  "(P1 \<turnstile>\<^sub>r Q1 \<sqsubseteq> P2 \<turnstile>\<^sub>r Q2) \<longleftrightarrow> (`P1 \<Rightarrow> P2` \<and> `P1 \<and> Q2 \<Rightarrow> Q1`)"
  by (rel_auto)

lemma design_refine_intro:
  assumes "`P1 \<Rightarrow> P2`" "`P1 \<and> Q2 \<Rightarrow> Q1`"
  shows "P1 \<turnstile> Q1 \<sqsubseteq> P2 \<turnstile> Q2"
  using assms unfolding upred_defs
  by (pred_auto)

lemma design_refine_intro':
  assumes "P\<^sub>2 \<sqsubseteq> P\<^sub>1" "Q\<^sub>1 \<sqsubseteq> (P\<^sub>1 \<and> Q\<^sub>2)"
  shows "P\<^sub>1 \<turnstile> Q\<^sub>1 \<sqsubseteq> P\<^sub>2 \<turnstile> Q\<^sub>2"
  using assms design_refine_intro[of P\<^sub>1 P\<^sub>2 Q\<^sub>2 Q\<^sub>1] by (simp add: refBy_order)

lemma rdesign_refine_intro:
  assumes "`P1 \<Rightarrow> P2`" "`P1 \<and> Q2 \<Rightarrow> Q1`"
  shows "P1 \<turnstile>\<^sub>r Q1 \<sqsubseteq> P2 \<turnstile>\<^sub>r Q2"
  using assms unfolding upred_defs
  by (pred_auto)

lemma rdesign_refine_intro':
  assumes "P2 \<sqsubseteq> P1" "Q1 \<sqsubseteq> (P1 \<and> Q2)"
  shows "P1 \<turnstile>\<^sub>r Q1 \<sqsubseteq> P2 \<turnstile>\<^sub>r Q2"
  using assms unfolding upred_defs
  by (pred_auto)

lemma ndesign_refine_intro:
  assumes "`p1 \<Rightarrow> p2`" "`\<lceil>p1\<rceil>\<^sub>< \<and> Q2 \<Rightarrow> Q1`"
  shows "p1 \<turnstile>\<^sub>n Q1 \<sqsubseteq> p2 \<turnstile>\<^sub>n Q2"
  using assms unfolding upred_defs
  by (pred_auto)

lemma design_subst [usubst]:
  "\<lbrakk> $ok \<sharp> \<sigma>; $ok\<acute> \<sharp> \<sigma> \<rbrakk> \<Longrightarrow> \<sigma> \<dagger> (P \<turnstile> Q) = (\<sigma> \<dagger> P) \<turnstile> (\<sigma> \<dagger> Q)"
  by (simp add: design_def usubst)

lemma design_msubst [usubst]:
  "(P(x) \<turnstile> Q(x))\<lbrakk>x\<rightarrow>v\<rbrakk> = (P(x)\<lbrakk>x\<rightarrow>v\<rbrakk> \<turnstile> Q(x)\<lbrakk>x\<rightarrow>v\<rbrakk>)"
  by (rel_auto)
    
theorem design_ok_false [usubst]: "(P \<turnstile> Q)\<lbrakk>false/$ok\<rbrakk> = true"
  by (simp add: design_def usubst)

theorem design_npre:
  "(P \<turnstile> Q)\<^sup>f = (\<not> $ok \<or> \<not> P\<^sup>f)"
  by (rel_auto)

theorem design_pre:
  "\<not> (P \<turnstile> Q)\<^sup>f = ($ok \<and> P\<^sup>f)"
  by (simp add: design_def, subst_tac)
     (metis (no_types, hide_lams) not_conj_deMorgans true_not_false(2) utp_pred_laws.compl_top_eq
            utp_pred_laws.sup.idem utp_pred_laws.sup_compl_top)

theorem design_post:
  "(P \<turnstile> Q)\<^sup>t = (($ok \<and> P\<^sup>t) \<Rightarrow> Q\<^sup>t)"
  by (rel_auto)

theorem rdesign_pre [simp]: "pre\<^sub>D(P \<turnstile>\<^sub>r Q) = P"
  by (pred_auto)

theorem rdesign_post [simp]: "post\<^sub>D(P \<turnstile>\<^sub>r Q) = (P \<Rightarrow> Q)"
  by (pred_auto)

theorem ndesign_pre [simp]: "pre\<^sub>D(p \<turnstile>\<^sub>n Q) = \<lceil>p\<rceil>\<^sub><"
  by (pred_auto)

theorem ndesign_post [simp]: "post\<^sub>D(p \<turnstile>\<^sub>n Q) = (\<lceil>p\<rceil>\<^sub>< \<Rightarrow> Q)"
  by (pred_auto)

theorem design_true_left_zero: "(true ;; (P \<turnstile> Q)) = true"
proof -
  have "(true ;; (P \<turnstile> Q)) = (\<^bold>\<exists> ok\<^sub>0 \<bullet> true\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (P \<turnstile> Q)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>)"
    by (subst seqr_middle[of ok], simp_all)
  also have "... = ((true\<lbrakk>false/$ok\<acute>\<rbrakk> ;; (P \<turnstile> Q)\<lbrakk>false/$ok\<rbrakk>) \<or> (true\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (P \<turnstile> Q)\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: disj_comm false_alt_def true_alt_def)
  also have "... = ((true\<lbrakk>false/$ok\<acute>\<rbrakk> ;; true\<^sub>h) \<or> (true ;; ((P \<turnstile> Q)\<lbrakk>true/$ok\<rbrakk>)))"
    by (subst_tac, rel_auto)
  also have "... = true"
    by (subst_tac, simp add: precond_right_unit unrest)
  finally show ?thesis .
qed

theorem design_top_left_zero: "(\<top>\<^sub>D ;; (P \<turnstile> Q)) = \<top>\<^sub>D"
  by (rel_auto)
    
theorem des_top_ndes_def [ndes_simp]: 
  "\<top>\<^sub>D = true \<turnstile>\<^sub>n false"
  by (rel_auto)

theorem design_choice:
  "(P\<^sub>1 \<turnstile> P\<^sub>2) \<sqinter> (Q\<^sub>1 \<turnstile> Q\<^sub>2) = ((P\<^sub>1 \<and> Q\<^sub>1) \<turnstile> (P\<^sub>2 \<or> Q\<^sub>2))"
  by (rel_auto)

theorem rdesign_choice:
  "(P\<^sub>1 \<turnstile>\<^sub>r P\<^sub>2) \<sqinter> (Q\<^sub>1 \<turnstile>\<^sub>r Q\<^sub>2) = ((P\<^sub>1 \<and> Q\<^sub>1) \<turnstile>\<^sub>r (P\<^sub>2 \<or> Q\<^sub>2))"
  by (rel_auto)

theorem ndesign_choice [ndes_simp]:
  "(p\<^sub>1 \<turnstile>\<^sub>n P\<^sub>2) \<sqinter> (q\<^sub>1 \<turnstile>\<^sub>n Q\<^sub>2) = ((p\<^sub>1 \<and> q\<^sub>1) \<turnstile>\<^sub>n (P\<^sub>2 \<or> Q\<^sub>2))"
  by (rel_auto)

theorem ndesign_choice' [ndes_simp]:
  "((p\<^sub>1 \<turnstile>\<^sub>n P\<^sub>2) \<or> (q\<^sub>1 \<turnstile>\<^sub>n Q\<^sub>2)) = ((p\<^sub>1 \<and> q\<^sub>1) \<turnstile>\<^sub>n (P\<^sub>2 \<or> Q\<^sub>2))"
  by (rel_auto)

theorem design_inf:
  "(P\<^sub>1 \<turnstile> P\<^sub>2) \<squnion> (Q\<^sub>1 \<turnstile> Q\<^sub>2) = ((P\<^sub>1 \<or> Q\<^sub>1) \<turnstile> ((P\<^sub>1 \<Rightarrow> P\<^sub>2) \<and> (Q\<^sub>1 \<Rightarrow> Q\<^sub>2)))"
  by (rel_auto)

theorem rdesign_inf:
  "(P\<^sub>1 \<turnstile>\<^sub>r P\<^sub>2) \<squnion> (Q\<^sub>1 \<turnstile>\<^sub>r Q\<^sub>2) = ((P\<^sub>1 \<or> Q\<^sub>1) \<turnstile>\<^sub>r ((P\<^sub>1 \<Rightarrow> P\<^sub>2) \<and> (Q\<^sub>1 \<Rightarrow> Q\<^sub>2)))"
  by (rel_auto)

theorem ndesign_inf [ndes_simp]:
  "(p\<^sub>1 \<turnstile>\<^sub>n P\<^sub>2) \<squnion> (q\<^sub>1 \<turnstile>\<^sub>n Q\<^sub>2) = ((p\<^sub>1 \<or> q\<^sub>1) \<turnstile>\<^sub>n ((\<lceil>p\<^sub>1\<rceil>\<^sub>< \<Rightarrow> P\<^sub>2) \<and> (\<lceil>q\<^sub>1\<rceil>\<^sub>< \<Rightarrow> Q\<^sub>2)))"
  by (rel_auto)
    
theorem design_condr:
  "((P\<^sub>1 \<turnstile> P\<^sub>2) \<triangleleft> b \<triangleright> (Q\<^sub>1 \<turnstile> Q\<^sub>2)) = ((P\<^sub>1 \<triangleleft> b \<triangleright> Q\<^sub>1) \<turnstile> (P\<^sub>2 \<triangleleft> b \<triangleright> Q\<^sub>2))"
  by (rel_auto)

theorem ndesign_dcond [ndes_simp]:
  "((p\<^sub>1 \<turnstile>\<^sub>n P\<^sub>2) \<triangleleft> b \<triangleright>\<^sub>D (q\<^sub>1 \<turnstile>\<^sub>n Q\<^sub>2)) = ((p\<^sub>1 \<triangleleft> b \<triangleright> q\<^sub>1) \<turnstile>\<^sub>n (P\<^sub>2 \<triangleleft> b \<triangleright>\<^sub>r Q\<^sub>2))"
  by (rel_auto)
    
lemma design_top:
  "(P \<turnstile> Q) \<sqsubseteq> \<top>\<^sub>D"
  by (rel_auto)

lemma design_bottom:
  "\<bottom>\<^sub>D \<sqsubseteq> (P \<turnstile> Q)"
  by (rel_auto)

lemma design_UINF_mem:
  assumes "A \<noteq> {}"
  shows "(\<Sqinter> i \<in> A \<bullet> P(i) \<turnstile> Q(i)) = (\<Squnion> i \<in> A \<bullet> P(i)) \<turnstile> (\<Sqinter> i \<in> A \<bullet> Q(i))"
  using assms by (rel_auto)

lemma ndesign_UINF_mem [ndes_simp]:
  assumes "A \<noteq> {}"
  shows "(\<Sqinter> i \<in> A \<bullet> p(i) \<turnstile>\<^sub>n Q(i)) = (\<Squnion> i \<in> A \<bullet> p(i)) \<turnstile>\<^sub>n (\<Sqinter> i \<in> A \<bullet> Q(i))"
  using assms by (rel_auto)

lemma ndesign_UINF_ind [ndes_simp]:
  "(\<Sqinter> i \<bullet> p(i) \<turnstile>\<^sub>n Q(i)) = (\<Squnion> i \<bullet> p(i)) \<turnstile>\<^sub>n (\<Sqinter> i \<bullet> Q(i))"
  by (rel_auto)
    
lemma design_USUP_mem:
  "(\<Squnion> i \<in> A \<bullet> P(i) \<turnstile> Q(i)) = (\<Sqinter> i \<in> A \<bullet> P(i)) \<turnstile> (\<Squnion> i \<in> A \<bullet> P(i) \<Rightarrow> Q(i))"
  by (rel_auto)

lemma ndesign_USUP_mem [ndes_simp]:
  "(\<Squnion> i \<in> A \<bullet> p(i) \<turnstile>\<^sub>n Q(i)) = (\<Sqinter> i \<in> A \<bullet> p(i)) \<turnstile>\<^sub>n (\<Squnion> i \<in> A \<bullet> \<lceil>p(i)\<rceil>\<^sub>< \<Rightarrow> Q(i))"
  by (rel_auto)

lemma ndesign_USUP_ind [ndes_simp]:
  "(\<Squnion> i \<bullet> p(i) \<turnstile>\<^sub>n Q(i)) = (\<Sqinter> i \<bullet> p(i)) \<turnstile>\<^sub>n (\<Squnion> i \<bullet> \<lceil>p(i)\<rceil>\<^sub>< \<Rightarrow> Q(i))"
  by (rel_auto)
    
theorem design_composition_subst:
  assumes
    "$ok\<acute> \<sharp> P1" "$ok \<sharp> P2"
  shows "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) =
         (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (\<not> P2))) \<turnstile> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; Q2\<lbrakk>true/$ok\<rbrakk>))"
proof -
  have "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = (\<^bold>\<exists> ok\<^sub>0 \<bullet> ((P1 \<turnstile> Q1)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (P2 \<turnstile> Q2)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>))"
    by (rule seqr_middle, simp)
  also have " ...
        = (((P1 \<turnstile> Q1)\<lbrakk>false/$ok\<acute>\<rbrakk> ;; (P2 \<turnstile> Q2)\<lbrakk>false/$ok\<rbrakk>)
            \<or> ((P1 \<turnstile> Q1)\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (P2 \<turnstile> Q2)\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: true_alt_def false_alt_def, pred_auto)
  also from assms
  have "... = ((($ok \<and> P1 \<Rightarrow> Q1\<lbrakk>true/$ok\<acute>\<rbrakk>) ;; (P2 \<Rightarrow> $ok\<acute> \<and> Q2\<lbrakk>true/$ok\<rbrakk>)) \<or> ((\<not> ($ok \<and> P1)) ;; true))"
    by (simp add: design_def usubst unrest, pred_auto)
  also have "... = ((\<not>$ok ;; true\<^sub>h) \<or> ((\<not>P1) ;; true) \<or> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (\<not>P2)) \<or> ($ok\<acute> \<and> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; Q2\<lbrakk>true/$ok\<rbrakk>)))"
    by (rel_auto)
  also have "... = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (\<not> P2))) \<turnstile> (Q1\<lbrakk>true/$ok\<acute>\<rbrakk> ;; Q2\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: precond_right_unit design_def unrest, rel_auto)
  finally show ?thesis .
qed

lemma design_export_ok:
  "P \<turnstile> Q = (P \<turnstile> ($ok \<and> Q))"
  by (rel_auto)

lemma design_export_ok':
  "P \<turnstile> Q = (P \<turnstile> ($ok\<acute> \<and> Q))"
  by (rel_auto)

lemma design_export_pre: "P \<turnstile> (P \<and> Q) = P \<turnstile> Q"
  by (rel_auto)

lemma design_export_spec: "P \<turnstile> (P \<Rightarrow> Q) = P \<turnstile> Q"
  by (rel_auto)

lemma design_ok_pre_conj: "($ok \<and> P) \<turnstile> Q = P \<turnstile> Q"
  by (rel_auto)

theorem design_composition:
  assumes
    "$ok\<acute> \<sharp> P1" "$ok \<sharp> P2" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2"
  shows "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile> (Q1 ;; Q2))"
  using assms by (simp add: design_composition_subst usubst)

lemma runrest_ident_var:
  assumes "x \<sharp>\<sharp> P"
  shows "($x \<and> P) = (P \<and> $x\<acute>)"
proof -
  have "P = ($x\<acute> =\<^sub>u $x \<and> P)"
    by (metis RID_def assms Healthy_def unrest_relation_def utp_pred_laws.inf.cobounded2 utp_pred_laws.inf_absorb2)
  moreover have "($x\<acute> =\<^sub>u $x \<and> ($x \<and> P)) = ($x\<acute> =\<^sub>u $x \<and> (P \<and> $x\<acute>))"
    by (rel_auto)
  ultimately show ?thesis
    by (metis utp_pred_laws.inf.assoc utp_pred_laws.inf_left_commute)
qed

theorem design_composition_runrest:
  assumes
    "$ok\<acute> \<sharp> P1" "$ok \<sharp> P2" "ok \<sharp>\<sharp> Q1" "ok \<sharp>\<sharp> Q2"
  shows "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1\<^sup>t ;; (\<not> P2))) \<turnstile> (Q1 ;; Q2))"
proof -
  have "($ok \<and> $ok\<acute> \<and> (Q1\<^sup>t ;; Q2\<lbrakk>true/$ok\<rbrakk>)) = ($ok \<and> $ok\<acute> \<and> (Q1 ;; Q2))"
  proof -
    have "($ok \<and> $ok\<acute> \<and> (Q1 ;; Q2)) = (($ok \<and> Q1) ;; (Q2 \<and> $ok\<acute>))"
      by (metis (no_types, lifting) conj_comm seqr_post_var_out seqr_pre_var_out)
    also have "... = ((Q1 \<and> $ok\<acute>) ;; ($ok \<and> Q2))"
      by (simp add: assms(3) assms(4) runrest_ident_var)
    also have "... = (Q1\<^sup>t ;; Q2\<lbrakk>true/$ok\<rbrakk>)"
      by (metis ok_vwb_lens seqr_pre_transfer seqr_right_one_point true_alt_def uovar_convr upred_eq_true utp_pred_laws.inf.left_idem utp_rel.unrest_ouvar vwb_lens_mwb)
    finally show ?thesis
      by (metis utp_pred_laws.inf.left_commute utp_pred_laws.inf_left_idem)
  qed
  moreover have "(\<not> (\<not> P1 ;; true) \<and> \<not> (Q1\<^sup>t ;; (\<not> P2))) \<turnstile> (Q1\<^sup>t ;; Q2\<lbrakk>true/$ok\<rbrakk>) =
                 (\<not> (\<not> P1 ;; true) \<and> \<not> (Q1\<^sup>t ;; (\<not> P2))) \<turnstile> ($ok \<and> $ok\<acute> \<and> (Q1\<^sup>t ;; Q2\<lbrakk>true/$ok\<rbrakk>))"
    by (metis design_export_ok design_export_ok')
  ultimately show ?thesis using assms
    by (simp add: design_composition_subst usubst, metis design_export_ok design_export_ok')
qed

theorem rdesign_composition:
  "((P1 \<turnstile>\<^sub>r Q1) ;; (P2 \<turnstile>\<^sub>r Q2)) = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile>\<^sub>r (Q1 ;; Q2))"
  by (simp add: rdesign_def design_composition unrest alpha)

lemma skip_d_alt_def: "II\<^sub>D = true \<turnstile> II"
  by (rel_auto)

lemma skip_d_ndes_def [ndes_simp]: "II\<^sub>D = true \<turnstile>\<^sub>n II"
  by (rel_auto)
    
theorem design_skip_idem [simp]:
  "(II\<^sub>D ;; II\<^sub>D) = II\<^sub>D"
  by (rel_auto)

theorem design_composition_cond:
  assumes
    "out\<alpha> \<sharp> p1" "$ok \<sharp> P2" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2"
  shows "((p1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = ((p1 \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile> (Q1 ;; Q2))"
  using assms
  by (simp add: design_composition unrest precond_right_unit)

theorem rdesign_composition_cond:
  assumes "out\<alpha> \<sharp> p1"
  shows "((p1 \<turnstile>\<^sub>r Q1) ;; (P2 \<turnstile>\<^sub>r Q2)) = ((p1 \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile>\<^sub>r (Q1 ;; Q2))"
  using assms
  by (simp add: rdesign_def design_composition_cond unrest alpha)

theorem design_composition_wp:
  assumes
    "ok \<sharp> p1" "ok \<sharp> p2"
    "$ok \<sharp> Q1" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2" "$ok\<acute> \<sharp> Q2"
  shows "((\<lceil>p1\<rceil>\<^sub>< \<turnstile> Q1) ;; (\<lceil>p2\<rceil>\<^sub>< \<turnstile> Q2)) = ((\<lceil>p1 \<and> Q1 wp p2\<rceil>\<^sub><) \<turnstile> (Q1 ;; Q2))"
  using assms by (rel_blast)

theorem rdesign_composition_wp:
  "((\<lceil>p1\<rceil>\<^sub>< \<turnstile>\<^sub>r Q1) ;; (\<lceil>p2\<rceil>\<^sub>< \<turnstile>\<^sub>r Q2)) = ((\<lceil>p1 \<and> Q1 wp p2\<rceil>\<^sub><) \<turnstile>\<^sub>r (Q1 ;; Q2))"
  by (rel_blast)

theorem ndesign_composition_wp [ndes_simp]:
  "((p1 \<turnstile>\<^sub>n Q1) ;; (p2 \<turnstile>\<^sub>n Q2)) = ((p1 \<and> Q1 wp p2) \<turnstile>\<^sub>n (Q1 ;; Q2))"
  by (rel_blast)

lemma wp_USUP_pre [wp]: "P wp (\<Squnion>i\<in>{0..n} \<bullet> Q(i)) = (\<Squnion>i\<in>{0..n} \<bullet> P wp Q(i))"
  by (rel_auto)

lemma USUP_where_false [simp]: "(\<Squnion> i | false \<bullet> P(i)) = true"
  by (pred_auto)
    
theorem ndesign_iteration_wp [ndes_simp]:
  "(p \<turnstile>\<^sub>n Q) ;; (p \<turnstile>\<^sub>n Q) \<^bold>^ n = ((\<And> i\<in>{0..n} \<bullet> (Q \<^bold>^ i) wp p) \<turnstile>\<^sub>n Q \<^bold>^ Suc n)"
proof (induct n)
  case 0
  then show ?case by (rel_auto)
next
  case (Suc n) note hyp = this
  have "(p \<turnstile>\<^sub>n Q) ;; (p \<turnstile>\<^sub>n Q) \<^bold>^ Suc n = (p \<turnstile>\<^sub>n Q) ;; (p \<turnstile>\<^sub>n Q) ;; (p \<turnstile>\<^sub>n Q) \<^bold>^ n"
    by (simp)
  also have "... = (p \<turnstile>\<^sub>n Q) ;; ((\<Squnion> i \<in> {0..n} \<bullet> Q \<^bold>^ i wp p) \<turnstile>\<^sub>n Q \<^bold>^ Suc n)"
    by (simp add: hyp)
  also have "... = (p \<and> Q wp (\<Squnion> i \<in> {0..n} \<bullet> Q \<^bold>^ i wp p)) \<turnstile>\<^sub>n (Q ;; Q) ;; Q \<^bold>^ n"
    by (simp add: ndesign_composition_wp seqr_assoc)
  also have "... = (p \<and> (\<Squnion> i \<in> {0..n} \<bullet> Q \<^bold>^ Suc i wp p)) \<turnstile>\<^sub>n (Q ;; Q) ;; Q \<^bold>^ n"
    by (simp add: wp)
  also have "... = (p \<and> (\<Squnion> i \<in> {0..n}. Q \<^bold>^ Suc i wp p)) \<turnstile>\<^sub>n (Q ;; Q) ;; Q \<^bold>^ n"
    by (simp add: USUP_as_Inf_image)
  also have "... = (p \<and> (\<Squnion> i \<in> {1..Suc n}. Q \<^bold>^ i wp p)) \<turnstile>\<^sub>n (Q ;; Q) ;; Q \<^bold>^ n"
    by (metis (no_types, lifting) One_nat_def image_Suc_atLeastAtMost image_cong image_image)  
  also have "... = (Q \<^bold>^ 0 wp p \<and> (\<Squnion> i \<in> {1..Suc n}. Q \<^bold>^ i wp p)) \<turnstile>\<^sub>n (Q ;; Q) ;; Q \<^bold>^ n"
    by (simp add: wp)
  also have "... = ((\<Squnion> i \<in> {0..Suc n}. Q \<^bold>^ i wp p)) \<turnstile>\<^sub>n (Q ;; Q) ;; Q \<^bold>^ n"
    by (simp add: Iic_Suc_eq_insert_0 atLeast0AtMost conj_upred_def image_Suc_atMost)      
  also have "... = (\<Squnion> i \<in> {0..Suc n} \<bullet> Q \<^bold>^ i wp p) \<turnstile>\<^sub>n Q \<^bold>^ Suc (Suc n)"
    by (simp add: USUP_as_Inf_image upred_semiring.mult_assoc)
  finally show ?case .
qed
    
theorem rdesign_wp [wp]:
  "(\<lceil>p\<rceil>\<^sub>< \<turnstile>\<^sub>r Q) wp\<^sub>D r = (p \<and> Q wp r)"
  by (rel_auto)

theorem ndesign_wp [wp]:
  "(p \<turnstile>\<^sub>n Q) wp\<^sub>D r = (p \<and> Q wp r)"
  by (simp add: ndesign_def rdesign_wp)

theorem wpd_seq_r:
  fixes Q1 Q2 :: "'\<alpha> hrel"
  shows "((\<lceil>p1\<rceil>\<^sub>< \<turnstile>\<^sub>r Q1) ;; (\<lceil>p2\<rceil>\<^sub>< \<turnstile>\<^sub>r Q2)) wp\<^sub>D r = (\<lceil>p1\<rceil>\<^sub>< \<turnstile>\<^sub>r Q1) wp\<^sub>D ((\<lceil>p2\<rceil>\<^sub>< \<turnstile>\<^sub>r Q2) wp\<^sub>D r)"
  apply (simp add: wp)
  apply (subst rdesign_composition_wp)
  apply (simp only: wp)
  apply (rel_auto)
done

theorem wpnd_seq_r [wp]:
  fixes Q1 Q2 :: "'\<alpha> hrel"
  shows "((p1 \<turnstile>\<^sub>n Q1) ;; (p2 \<turnstile>\<^sub>n Q2)) wp\<^sub>D r = (p1 \<turnstile>\<^sub>n Q1) wp\<^sub>D ((p2 \<turnstile>\<^sub>n Q2) wp\<^sub>D r)"
  by (simp add: ndesign_def wpd_seq_r)

lemma design_subst_ok:
  "(P\<lbrakk>true/$ok\<rbrakk> \<turnstile> Q\<lbrakk>true/$ok\<rbrakk>) = (P \<turnstile> Q)"
  by (rel_auto)

lemma design_subst_ok_ok':
  "(P\<lbrakk>true/$ok\<rbrakk> \<turnstile> Q\<lbrakk>true,true/$ok,$ok\<acute>\<rbrakk>) = (P \<turnstile> Q)"
proof -
  have "(P \<turnstile> Q) = (($ok \<and> P) \<turnstile> ($ok \<and> $ok\<acute> \<and> Q))"
    by (pred_auto)
  also have "... = (($ok \<and> P\<lbrakk>true/$ok\<rbrakk>) \<turnstile> ($ok \<and> ($ok\<acute> \<and> Q\<lbrakk>true/$ok\<acute>\<rbrakk>)\<lbrakk>true/$ok\<rbrakk>))"
    by (metis conj_eq_out_var_subst conj_pos_var_subst upred_eq_true utp_pred_laws.inf_commute ok_vwb_lens)
  also have "... = (($ok \<and> P\<lbrakk>true/$ok\<rbrakk>) \<turnstile> ($ok \<and> $ok\<acute> \<and> Q\<lbrakk>true,true/$ok,$ok\<acute>\<rbrakk>))"
    by (simp add: usubst)
  also have "... = (P\<lbrakk>true/$ok\<rbrakk> \<turnstile> Q\<lbrakk>true,true/$ok,$ok\<acute>\<rbrakk>)"
    by (pred_auto)
  finally show ?thesis ..
qed

lemma design_subst_ok':
  "(P \<turnstile> Q\<lbrakk>true/$ok\<acute>\<rbrakk>) = (P \<turnstile> Q)"
proof -
  have "(P \<turnstile> Q) = (P \<turnstile> ($ok\<acute> \<and> Q))"
    by (pred_auto)
  also have "... = (P \<turnstile> ($ok\<acute> \<and> Q\<lbrakk>true/$ok\<acute>\<rbrakk>))"
    by (metis conj_eq_out_var_subst upred_eq_true utp_pred_laws.inf_commute ok_vwb_lens)
  also have "... = (P \<turnstile> Q\<lbrakk>true/$ok\<acute>\<rbrakk>)"
    by (pred_auto)
  finally show ?thesis ..
qed

theorem design_left_unit_hom:
  fixes P Q :: "'\<alpha> hrel_des"
  shows "(II\<^sub>D ;; (P \<turnstile>\<^sub>r Q)) = (P \<turnstile>\<^sub>r Q)"
proof -
  have "(II\<^sub>D ;; (P \<turnstile>\<^sub>r Q)) = ((true \<turnstile>\<^sub>r II) ;; (P \<turnstile>\<^sub>r Q))"
    by (simp add: skip_d_def)
  also have "... = (true \<and> \<not> (II ;; (\<not> P))) \<turnstile>\<^sub>r (II ;; Q)"
  proof -
    have "out\<alpha> \<sharp> true"
      by unrest_tac
    thus ?thesis
      using rdesign_composition_cond by blast
  qed
  also have "... = (\<not> (\<not> P)) \<turnstile>\<^sub>r Q"
    by simp
  finally show ?thesis by simp
qed

theorem design_left_unit [simp]:
  "II\<^sub>D ;; (P \<turnstile>\<^sub>r Q) = (P \<turnstile>\<^sub>r Q)"
  by (rel_auto)

theorem design_right_semi_unit:
  "(P \<turnstile>\<^sub>r Q) ;; II\<^sub>D = ((\<not> (\<not> P) ;; true) \<turnstile>\<^sub>r Q)"
  by (simp add: skip_d_def rdesign_composition)

theorem design_right_cond_unit [simp]:
  assumes "out\<alpha> \<sharp> p"
  shows "(p \<turnstile>\<^sub>r Q) ;; II\<^sub>D = (p \<turnstile>\<^sub>r Q)"
  using assms
  by (simp add: skip_d_def rdesign_composition_cond)

lemma lift_des_skip_dr_unit [simp]:
  "(\<lceil>P\<rceil>\<^sub>D ;; \<lceil>II\<rceil>\<^sub>D) = \<lceil>P\<rceil>\<^sub>D"
  "(\<lceil>II\<rceil>\<^sub>D ;; \<lceil>P\<rceil>\<^sub>D) = \<lceil>P\<rceil>\<^sub>D"
  by (rel_auto)+

lemma assigns_d_ndes_def [ndes_simp]:
  "\<langle>\<sigma>\<rangle>\<^sub>D = (true \<turnstile>\<^sub>n \<langle>\<sigma>\<rangle>\<^sub>a)"
  by (rel_auto)
    
lemma assigns_d_id [simp]: "\<langle>id\<rangle>\<^sub>D = II\<^sub>D"
  by (rel_auto)

lemma assign_d_left_comp:
  "(\<langle>f\<rangle>\<^sub>D ;; (P \<turnstile>\<^sub>r Q)) = (\<lceil>f\<rceil>\<^sub>s \<dagger> P \<turnstile>\<^sub>r \<lceil>f\<rceil>\<^sub>s \<dagger> Q)"
  by (simp add: assigns_d_def rdesign_composition assigns_r_comp subst_not)

lemma assign_d_right_comp:
  "((P \<turnstile>\<^sub>r Q) ;; \<langle>f\<rangle>\<^sub>D) = ((\<not> ((\<not> P) ;; true)) \<turnstile>\<^sub>r (Q ;; \<langle>f\<rangle>\<^sub>a))"
  by (simp add: assigns_d_def rdesign_composition)

lemma assigns_d_comp:
  "(\<langle>f\<rangle>\<^sub>D ;; \<langle>g\<rangle>\<^sub>D) = \<langle>g \<circ> f\<rangle>\<^sub>D"
  by (simp add: assigns_d_def rdesign_composition assigns_comp)

subsection {* Design preconditions *}

lemma design_pre_choice [simp]:
  "pre\<^sub>D(P \<sqinter> Q) = (pre\<^sub>D(P) \<and> pre\<^sub>D(Q))"
  by (rel_auto)

lemma design_post_choice [simp]:
  "post\<^sub>D(P \<sqinter> Q) = (post\<^sub>D(P) \<or> post\<^sub>D(Q))"
  by (rel_auto)

lemma design_pre_condr [simp]:
  "pre\<^sub>D(P \<triangleleft> \<lceil>b\<rceil>\<^sub>D \<triangleright> Q) = (pre\<^sub>D(P) \<triangleleft> b \<triangleright> pre\<^sub>D(Q))"
  by (rel_auto)

lemma design_post_condr [simp]:
  "post\<^sub>D(P \<triangleleft> \<lceil>b\<rceil>\<^sub>D \<triangleright> Q) = (post\<^sub>D(P) \<triangleleft> b \<triangleright> post\<^sub>D(Q))"
  by (rel_auto)

subsection {* H1: No observation is allowed before initiation *}

lemma H1_idem:
  "H1 (H1 P) = H1(P)"
  by (pred_auto)

lemma H1_monotone:
  "P \<sqsubseteq> Q \<Longrightarrow> H1(P) \<sqsubseteq> H1(Q)"
  by (pred_auto)

lemma H1_Continuous: "Continuous H1"
  by (rel_auto)

lemma H1_below_top:
  "H1(P) \<sqsubseteq> \<top>\<^sub>D"
  by (pred_auto)

lemma H1_design_skip:
  "H1(II) = II\<^sub>D"
  by (rel_auto)

lemma H1_cond: "H1(P \<triangleleft> b \<triangleright> Q) = H1(P) \<triangleleft> b \<triangleright> H1(Q)"
  by (rel_auto)

lemma H1_conj: "H1(P \<and> Q) = (H1(P) \<and> H1(Q))"
  by (rel_auto)

lemma H1_disj: "H1(P \<or> Q) = (H1(P) \<or> H1(Q))"
  by (rel_auto)

lemma design_export_H1: "(P \<turnstile> Q) = (P \<turnstile> H1(Q))"
  by (rel_auto)

text {* The H1 algebraic laws are valid only when $\alpha(R)$ is homogeneous. This should maybe be
        generalised. *}

theorem H1_algebraic_intro:
  assumes
    "(true\<^sub>h ;; R) = true\<^sub>h"
    "(II\<^sub>D ;; R) = R"
  shows "R is H1"
proof -
  have "R = (II\<^sub>D ;; R)" by (simp add: assms(2))
  also have "... = (H1(II) ;; R)"
    by (simp add: H1_design_skip)
  also have "... = (($ok \<Rightarrow> II) ;; R)"
    by (simp add: H1_def)
  also have "... = (((\<not> $ok) ;; R) \<or> R)"
    by (simp add: impl_alt_def seqr_or_distl)
  also have "... = ((((\<not> $ok) ;; true\<^sub>h) ;; R) \<or> R)"
    by (simp add: precond_right_unit unrest)
  also have "... = (((\<not> $ok) ;; true\<^sub>h) \<or> R)"
    by (metis assms(1) seqr_assoc)
  also have "... = ($ok \<Rightarrow> R)"
    by (simp add: impl_alt_def precond_right_unit unrest)
  finally show ?thesis by (metis H1_def Healthy_def')
qed

lemma nok_not_false:
  "(\<not> $ok) \<noteq> false"
  by (pred_auto)

theorem H1_left_zero:
  assumes "P is H1"
  shows "(true ;; P) = true"
proof -
  from assms have "(true ;; P) = (true ;; ($ok \<Rightarrow> P))"
    by (simp add: H1_def Healthy_def')
  (* The next step ensures we get the right alphabet for true by copying it *)
  also from assms have "... = (true ;; (\<not> $ok \<or> P))" (is "_ = (?true ;; _)")
    by (simp add: impl_alt_def)
  also from assms have "... = ((?true ;; (\<not> $ok)) \<or> (?true ;; P))"
    using seqr_or_distr by blast
  also from assms have "... = (true \<or> (true ;; P))"
    by (simp add: nok_not_false precond_left_zero unrest)
  finally show ?thesis
    by (simp add: upred_defs urel_defs)
qed

theorem H1_left_unit:
  fixes P :: "'\<alpha> hrel_des"
  assumes "P is H1"
  shows "(II\<^sub>D ;; P) = P"
proof -
  have "(II\<^sub>D ;; P) = (($ok \<Rightarrow> II) ;; P)"
    by (metis H1_def H1_design_skip)
  also have "... = (((\<not> $ok) ;; P) \<or> P)"
    by (simp add: impl_alt_def seqr_or_distl)
  also from assms have "... = ((((\<not> $ok) ;; true\<^sub>h) ;; P) \<or> P)"
    by (simp add: precond_right_unit unrest)
  also have "... = (((\<not> $ok) ;; (true\<^sub>h ;; P)) \<or> P)"
    by (simp add: seqr_assoc)
  also from assms have "... = ($ok \<Rightarrow> P)"
    by (simp add: H1_left_zero impl_alt_def precond_right_unit unrest)
  finally show ?thesis using assms
    by (simp add: H1_def Healthy_def')
qed

theorem H1_algebraic:
  "P is H1 \<longleftrightarrow> (true\<^sub>h ;; P) = true\<^sub>h \<and> (II\<^sub>D ;; P) = P"
  using H1_algebraic_intro H1_left_unit H1_left_zero by blast

theorem H1_nok_left_zero:
  fixes P :: "'\<alpha> hrel_des"
  assumes "P is H1"
  shows "((\<not> $ok) ;; P) = (\<not> $ok)"
proof -
  have "((\<not> $ok) ;; P) = (((\<not> $ok) ;; true\<^sub>h) ;; P)"
    by (simp add: precond_right_unit unrest)
  also have "... = ((\<not> $ok) ;; true\<^sub>h)"
    by (metis H1_left_zero assms seqr_assoc)
  also have "... = (\<not> $ok)"
    by (simp add: precond_right_unit unrest)
  finally show ?thesis .
qed

lemma H1_design:
  "H1(P \<turnstile> Q) = (P \<turnstile> Q)"
  by (rel_auto)

lemma H1_rdesign:
  "H1(P \<turnstile>\<^sub>r Q) = (P \<turnstile>\<^sub>r Q)"
  by (rel_auto)

lemma H1_choice_closed [closure]:
  "\<lbrakk> P is H1; Q is H1 \<rbrakk> \<Longrightarrow> P \<sqinter> Q is H1"
  by (simp add: H1_def Healthy_def' disj_upred_def impl_alt_def semilattice_sup_class.sup_left_commute)

lemma H1_inf_closed [closure]:
  "\<lbrakk> P is H1; Q is H1 \<rbrakk> \<Longrightarrow> P \<squnion> Q is H1"
  by (rel_blast)

lemma H1_UINF:
  assumes "A \<noteq> {}"
  shows "H1(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> H1(P(i)))"
  using assms by (rel_auto)

lemma H1_Sup:
  assumes "A \<noteq> {}" "\<forall> P \<in> A. P is H1"
  shows "(\<Sqinter> A) is H1"
proof -
  from assms(2) have "H1 ` A = A"
    by (auto simp add: Healthy_def rev_image_eqI)
  with H1_UINF[of A id, OF assms(1)] show ?thesis
    by (simp add: UINF_as_Sup_image Healthy_def, presburger)
qed

lemma H1_USUP:
  shows "H1(\<Squnion> i \<in> A \<bullet> P(i)) = (\<Squnion> i \<in> A \<bullet> H1(P(i)))"
  by (rel_auto)

lemma H1_Inf [closure]:
  assumes "\<forall> P \<in> A. P is H1"
  shows "(\<Squnion> A) is H1"
proof -
  from assms have "H1 ` A = A"
    by (auto simp add: Healthy_def rev_image_eqI)
  with H1_USUP[of A id] show ?thesis
    by (simp add: USUP_as_Inf_image Healthy_def, presburger)
qed

subsection {* H2: A specification cannot require non-termination *}

lemma J_split:
  shows "(P ;; J) = (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))"
proof -
  have "(P ;; J) = (P ;; (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D))"
    by (simp add: H2_def J_def design_def)
  also have "... = (P ;; (($ok \<Rightarrow> $ok \<and> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D))"
    by (rel_auto)
  also have "... = ((P ;; (\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D)) \<or> (P ;; ($ok \<and> (\<lceil>II\<rceil>\<^sub>D \<and> $ok\<acute>))))"
    by (rel_auto)
  also have "... = (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))"
  proof -
    have "(P ;; (\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D)) = P\<^sup>f"
    proof -
      have "(P ;; (\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D)) = ((P \<and> \<not> $ok\<acute>) ;; \<lceil>II\<rceil>\<^sub>D)"
        by (rel_auto)
      also have "... = (\<exists> $ok\<acute> \<bullet> P \<and> $ok\<acute> =\<^sub>u false)"
        by (rel_auto)
      also have "... = P\<^sup>f"
        by (metis C1 one_point out_var_uvar unrest_as_exists ok_vwb_lens vwb_lens_mwb)
     finally show ?thesis .
    qed
    moreover have "(P ;; ($ok \<and> (\<lceil>II\<rceil>\<^sub>D \<and> $ok\<acute>))) = (P\<^sup>t \<and> $ok\<acute>)"
    proof -
      have "(P ;; ($ok \<and> (\<lceil>II\<rceil>\<^sub>D \<and> $ok\<acute>))) = (P ;; ($ok \<and> II))"
        by (rel_auto)
      also have "... = (P\<^sup>t \<and> $ok\<acute>)"
        by (rel_auto)
      finally show ?thesis .
    qed
    ultimately show ?thesis
      by simp
  qed
  finally show ?thesis .
qed

lemma H2_split:
  shows "H2(P) = (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))"
  by (simp add: H2_def J_split)

theorem H2_equivalence:
  "P is H2 \<longleftrightarrow> `P\<^sup>f \<Rightarrow> P\<^sup>t`"
proof -
  have "`P \<Leftrightarrow> (P ;; J)` \<longleftrightarrow> `P \<Leftrightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))`"
    by (simp add: J_split)
  also have "... \<longleftrightarrow> `(P \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t \<and> $ok\<acute>)\<^sup>f \<and> (P \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t \<and> $ok\<acute>)\<^sup>t`"
    by (simp add: subst_bool_split)
  also have "... = `(P\<^sup>f \<Leftrightarrow> P\<^sup>f) \<and> (P\<^sup>t \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t)`"
    by subst_tac
  also have "... = `P\<^sup>t \<Leftrightarrow> (P\<^sup>f \<or> P\<^sup>t)`"
    by (pred_auto robust)
  also have "... = `(P\<^sup>f \<Rightarrow> P\<^sup>t)`"
    by (pred_auto)
  finally show ?thesis
    by (metis H2_def Healthy_def' taut_iff_eq)
qed

lemma H2_equiv:
  "P is H2 \<longleftrightarrow> P\<^sup>t \<sqsubseteq> P\<^sup>f"
  using H2_equivalence refBy_order by blast

lemma H2_design:
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q"
  shows "H2(P \<turnstile> Q) = P \<turnstile> Q"
  using assms
  by (simp add: H2_split design_def usubst unrest, pred_auto)

lemma H2_rdesign:
  "H2(P \<turnstile>\<^sub>r Q) = P \<turnstile>\<^sub>r Q"
  by (simp add: H2_design unrest rdesign_def)

theorem J_idem:
  "(J ;; J) = J"
  by (rel_auto)

theorem H2_idem:
  "H2(H2(P)) = H2(P)"
  by (metis H2_def J_idem seqr_assoc)

theorem H2_Continuous: "Continuous H2"
  by (rel_auto)

theorem H2_not_okay: "H2 (\<not> $ok) = (\<not> $ok)"
proof -
  have "H2 (\<not> $ok) = ((\<not> $ok)\<^sup>f \<or> ((\<not> $ok)\<^sup>t \<and> $ok\<acute>))"
    by (simp add: H2_split)
  also have "... = (\<not> $ok \<or> (\<not> $ok) \<and> $ok\<acute>)"
    by (subst_tac)
  also have "... = (\<not> $ok)"
    by (pred_auto)
  finally show ?thesis .
qed

lemma H2_true: "H2(true) = true"
  by (rel_auto)

lemma H2_choice_closed [closure]:
  "\<lbrakk> P is H2; Q is H2 \<rbrakk> \<Longrightarrow> P \<sqinter> Q is H2"
  by (metis H2_def Healthy_def' disj_upred_def seqr_or_distl)

lemma H2_inf_closed [closure]:
  assumes "P is H2" "Q is H2"
  shows "P \<squnion> Q is H2"
proof -
  have "P \<squnion> Q = (P\<^sup>f \<or> P\<^sup>t \<and> $ok\<acute>) \<squnion> (Q\<^sup>f \<or> Q\<^sup>t \<and> $ok\<acute>)"
    by (metis H2_def Healthy_def J_split assms(1) assms(2))
  moreover have "H2(...) = ..."
    by (simp add: H2_split usubst, pred_auto)
  ultimately show ?thesis
    by (simp add: Healthy_def)
qed

lemma H2_USUP:
  shows "H2(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> H2(P(i)))"
  by (rel_auto)

theorem H1_H2_commute:
  "H1 (H2 P) = H2 (H1 P)"
proof -
  have "H2 (H1 P) = (($ok \<Rightarrow> P) ;; J)"
    by (simp add: H1_def H2_def)
  also have "... = ((\<not> $ok \<or> P) ;; J)"
    by (rel_auto)
  also have "... = (((\<not> $ok) ;; J) \<or> (P ;; J))"
    using seqr_or_distl by blast
  also have "... =  ((H2 (\<not> $ok)) \<or> H2(P))"
    by (simp add: H2_def)
  also have "... =  ((\<not> $ok) \<or> H2(P))"
    by (simp add: H2_not_okay)
  also have "... = H1(H2(P))"
    by (rel_auto)
  finally show ?thesis by simp
qed

lemma ok_pre: "($ok \<and> \<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D) = ($ok \<and> (\<not> P\<^sup>f))"
  by (pred_auto robust)

lemma ok_post: "($ok \<and> \<lceil>post\<^sub>D(P)\<rceil>\<^sub>D) = ($ok \<and> (P\<^sup>t))"
  by (pred_auto robust)

abbreviation "H1_H2 P \<equiv> H1 (H2 P)"

notation H1_H2 ("\<^bold>H")

lemma H1_H2_comp: "\<^bold>H = H1 \<circ> H2"
  by (auto)

theorem H1_H2_eq_design:
  "\<^bold>H(P) = (\<not> P\<^sup>f) \<turnstile> P\<^sup>t"
proof -
  have "\<^bold>H(P) = ($ok \<Rightarrow> H2(P))"
    by (simp add: H1_def)
  also have "... = ($ok \<Rightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>)))"
    by (metis H2_split)
  also have "... = ($ok \<and> (\<not> P\<^sup>f) \<Rightarrow> $ok\<acute> \<and> $ok \<and> P\<^sup>t)"
    by (rel_auto)
  also have "... = (\<not> P\<^sup>f) \<turnstile> P\<^sup>t"
    by (rel_auto)
  finally show ?thesis .
qed

theorem H1_H2_is_design:
  assumes "P is H1" "P is H2"
  shows "P = (\<not> P\<^sup>f) \<turnstile> P\<^sup>t"
  using assms by (metis H1_H2_eq_design Healthy_def)

theorem H1_H2_eq_rdesign:
  "\<^bold>H(P) = pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
proof -
  have "\<^bold>H(P) = ($ok \<Rightarrow> H2(P))"
    by (simp add: H1_def Healthy_def')
  also have "... = ($ok \<Rightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>)))"
    by (metis H2_split)
  also have "... = ($ok \<and> (\<not> P\<^sup>f) \<Rightarrow> $ok\<acute> \<and> P\<^sup>t)"
    by (pred_auto)
  also have "... = ($ok \<and> (\<not> P\<^sup>f) \<Rightarrow> $ok\<acute> \<and> $ok \<and> P\<^sup>t)"
    by (pred_auto)
  also have "... = ($ok \<and> \<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D \<Rightarrow> $ok\<acute> \<and> $ok \<and> \<lceil>post\<^sub>D(P)\<rceil>\<^sub>D)"
    by (simp add: ok_post ok_pre)
  also have "... = ($ok \<and> \<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D \<Rightarrow> $ok\<acute> \<and> \<lceil>post\<^sub>D(P)\<rceil>\<^sub>D)"
    by (pred_auto)
  also have "... =  pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
    by (simp add: rdesign_def design_def)
  finally show ?thesis .
qed

theorem H1_H2_is_rdesign:
  assumes "P is H1" "P is H2"
  shows "P = pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
  by (metis H1_H2_eq_rdesign Healthy_def assms(1) assms(2))

lemma H1_H2_refinement:
  assumes "P is \<^bold>H" "Q is \<^bold>H"
  shows "P \<sqsubseteq> Q \<longleftrightarrow> (`pre\<^sub>D(P) \<Rightarrow> pre\<^sub>D(Q)` \<and> `pre\<^sub>D(P) \<and> post\<^sub>D(Q) \<Rightarrow> post\<^sub>D(P)`)"
  by (metis H1_H2_eq_rdesign Healthy_if assms rdesign_refinement)

lemma H1_H2_refines:
  assumes "P is \<^bold>H" "Q is \<^bold>H" "P \<sqsubseteq> Q"
  shows "pre\<^sub>D(Q) \<sqsubseteq> pre\<^sub>D(P)" "post\<^sub>D(P) \<sqsubseteq> (pre\<^sub>D(P) \<and> post\<^sub>D(Q))"
  using H1_H2_refinement assms refBy_order by auto

lemma H1_H2_idempotent: "\<^bold>H (\<^bold>H P) = \<^bold>H P"
  by (simp add: H1_H2_commute H1_idem H2_idem)

lemma H1_H2_Idempotent [closure]: "Idempotent \<^bold>H"
  by (simp add: Idempotent_def H1_H2_idempotent)

lemma H1_H2_monotonic [closure]: "Monotonic \<^bold>H"
  by (simp add: H1_monotone H2_def mono_def seqr_mono)

lemma H1_H2_Continuous [closure]: "Continuous \<^bold>H"
  by (simp add: Continuous_comp H1_Continuous H1_H2_comp H2_Continuous)

lemma design_is_H1_H2 [closure]:
  "\<lbrakk> $ok\<acute> \<sharp> P; $ok\<acute> \<sharp> Q \<rbrakk> \<Longrightarrow> (P \<turnstile> Q) is \<^bold>H"
  by (simp add: H1_design H2_design Healthy_def')

lemma rdesign_is_H1_H2 [closure]:
  "(P \<turnstile>\<^sub>r Q) is \<^bold>H"
  by (simp add: Healthy_def H1_rdesign H2_rdesign)

lemma assigns_d_is_H1_H2 [closure]:
  "\<langle>\<sigma>\<rangle>\<^sub>D is \<^bold>H"
  by (simp add: assigns_d_def rdesign_is_H1_H2)

lemma state_subst_H1_H2_closed [closure]: 
  "P is \<^bold>H \<Longrightarrow> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rceil>\<^sub>s \<dagger> P is \<^bold>H"
  by (metis H1_H2_eq_rdesign Healthy_if rdesign_is_H1_H2 state_subst_design)
    
lemma seq_r_H1_H2_closed [closure]:
  assumes "P is \<^bold>H" "Q is \<^bold>H"
  shows "(P ;; Q) is \<^bold>H"
proof -
  obtain P\<^sub>1 P\<^sub>2 where "P = P\<^sub>1 \<turnstile>\<^sub>r P\<^sub>2"
    by (metis H1_H2_commute H1_H2_is_rdesign H2_idem Healthy_def assms(1))
  moreover obtain Q\<^sub>1 Q\<^sub>2 where "Q = Q\<^sub>1 \<turnstile>\<^sub>r Q\<^sub>2"
   by (metis H1_H2_commute H1_H2_is_rdesign H2_idem Healthy_def assms(2))
  moreover have "((P\<^sub>1 \<turnstile>\<^sub>r P\<^sub>2) ;; (Q\<^sub>1 \<turnstile>\<^sub>r Q\<^sub>2)) is \<^bold>H"
    by (simp add: rdesign_composition rdesign_is_H1_H2)
  ultimately show ?thesis by simp
qed

lemma assigns_d_comp_ext:
  fixes P :: "'\<alpha> hrel_des"
  assumes "P is \<^bold>H"
  shows "(\<langle>\<sigma>\<rangle>\<^sub>D ;; P) = \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rceil>\<^sub>s \<dagger> P"
proof -
  have "\<langle>\<sigma>\<rangle>\<^sub>D ;; P = \<langle>\<sigma>\<rangle>\<^sub>D ;; (pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P))"
    by (metis H1_H2_commute H1_H2_is_rdesign H2_idem Healthy_def' assms)
  also have "... = \<lceil>\<sigma>\<rceil>\<^sub>s \<dagger> pre\<^sub>D(P) \<turnstile>\<^sub>r \<lceil>\<sigma>\<rceil>\<^sub>s \<dagger> post\<^sub>D(P)"
    by (simp add: assign_d_left_comp)
  also have "... = \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rceil>\<^sub>s \<dagger> (pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P))"
    by (rel_auto)
  also have "... = \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rceil>\<^sub>s \<dagger> P"
    by (metis H1_H2_commute H1_H2_is_rdesign H2_idem Healthy_def' assms)
  finally show ?thesis .
qed

lemma UINF_H1_H2_closed [closure]:
  assumes "A \<noteq> {}" "\<forall> P \<in> A. P is \<^bold>H"
  shows "(\<Sqinter> A) is H1_H2"
proof -
  from assms have A: "A = H1_H2 ` A"
    by (auto simp add: Healthy_def rev_image_eqI)
  also have "(\<Sqinter> ...) = (\<Sqinter> P \<in> A \<bullet> H1_H2(P))"
    by (simp add: UINF_as_Sup_collect)
  also have "... = (\<Sqinter> P \<in> A \<bullet> (\<not> P\<^sup>f) \<turnstile> P\<^sup>t)"
    by (meson H1_H2_eq_design)
  also have "... = (\<Squnion> P \<in> A \<bullet> \<not> P\<^sup>f) \<turnstile> (\<Sqinter> P \<in> A \<bullet> P\<^sup>t)"
    by (simp add: design_UINF_mem assms)
  also have "... is H1_H2"
    by (simp add: design_is_H1_H2 unrest)
  finally show ?thesis .
qed

definition design_sup :: "('\<alpha>, '\<beta>) rel_des set \<Rightarrow> ('\<alpha>, '\<beta>) rel_des" ("\<Sqinter>\<^sub>D_" [900] 900) where
"\<Sqinter>\<^sub>D A = (if (A = {}) then \<top>\<^sub>D else \<Sqinter> A)"

lemma design_inf_H1_H2_closed:
  assumes "\<forall> P \<in> A. P is \<^bold>H"
  shows "(\<Sqinter>\<^sub>D A) is \<^bold>H"
  apply (auto simp add: design_sup_def)
  apply (simp add: H1_def H2_not_okay Healthy_def impl_alt_def)
  using UINF_H1_H2_closed assms apply blast
done

lemma design_sup_empty [simp]: "\<Sqinter>\<^sub>D {} = \<top>\<^sub>D"
  by (simp add: design_sup_def)

lemma design_sup_non_empty [simp]: "A \<noteq> {} \<Longrightarrow> \<Sqinter>\<^sub>D A = \<Sqinter> A"
  by (simp add: design_sup_def)

lemma USUP_mem_H1_H2_closed:
  assumes "\<And> i. i \<in> A \<Longrightarrow> P i is \<^bold>H"
  shows "(\<Squnion> i\<in>A \<bullet> P i) is \<^bold>H"
proof -
  from assms have "(\<Squnion> i\<in>A \<bullet> P i) = (\<Squnion> i\<in>A \<bullet> \<^bold>H(P i))"
    by (auto intro: USUP_cong simp add: Healthy_def)
  also have "... = (\<Squnion> i\<in>A \<bullet> (\<not> (P i)\<^sup>f) \<turnstile> (P i)\<^sup>t)"
    by (meson H1_H2_eq_design)
  also have "... = (\<Sqinter> i\<in>A \<bullet> \<not> (P i)\<^sup>f) \<turnstile> (\<Squnion> i\<in>A \<bullet> \<not> (P i)\<^sup>f \<Rightarrow> (P i)\<^sup>t)"    
    by (simp add: design_USUP_mem)  
  also have "... is \<^bold>H"
    by (simp add: design_is_H1_H2 unrest)
  finally show ?thesis .
qed

lemma USUP_ind_H1_H2_closed:
  assumes "\<And> i. P i is \<^bold>H"
  shows "(\<Squnion> i \<bullet> P i) is \<^bold>H"
  using assms USUP_mem_H1_H2_closed[of UNIV P] by simp
  
lemma Inf_H1_H2_closed:
  assumes "\<forall> P \<in> A. P is \<^bold>H"
  shows "(\<Squnion> A) is \<^bold>H"
proof -
  from assms have A: "A = \<^bold>H ` A"
    by (auto simp add: Healthy_def rev_image_eqI)
  also have "(\<Squnion> ...) = (\<Squnion> P \<in> A \<bullet> \<^bold>H(P))"
    by (simp add: USUP_as_Inf_collect)
  also have "... = (\<Squnion> P \<in> A \<bullet> (\<not> P\<^sup>f) \<turnstile> P\<^sup>t)"
    by (meson H1_H2_eq_design)
  also have "... = (\<Sqinter> P \<in> A \<bullet> \<not> P\<^sup>f) \<turnstile> (\<Squnion> P \<in> A \<bullet> \<not> P\<^sup>f \<Rightarrow> P\<^sup>t)"
    by (simp add: design_USUP_mem)
  also have "... is \<^bold>H"
    by (simp add: design_is_H1_H2 unrest)
  finally show ?thesis .
qed

abbreviation design_inf :: "('\<alpha>, '\<beta>) rel_des set \<Rightarrow> ('\<alpha>, '\<beta>) rel_des" ("\<Squnion>\<^sub>D_" [900] 900) where
"\<Squnion>\<^sub>D A \<equiv> \<Squnion> A"

lemma rdesign_ref_monos:
  assumes "P is \<^bold>H" "Q is \<^bold>H" "P \<sqsubseteq> Q"
  shows "pre\<^sub>D(Q) \<sqsubseteq> pre\<^sub>D(P)" "post\<^sub>D(P) \<sqsubseteq> (pre\<^sub>D(P) \<and> post\<^sub>D(Q))"
proof -
  have r: "P \<sqsubseteq> Q \<longleftrightarrow> (`pre\<^sub>D(P) \<Rightarrow> pre\<^sub>D(Q)` \<and> `pre\<^sub>D(P) \<and> post\<^sub>D(Q) \<Rightarrow> post\<^sub>D(P)`)"
    by (metis H1_H2_eq_rdesign Healthy_if assms(1) assms(2) rdesign_refinement)
  from r assms show "pre\<^sub>D(Q) \<sqsubseteq> pre\<^sub>D(P)"
    by (auto simp add: refBy_order)
  from r assms show "post\<^sub>D(P) \<sqsubseteq> (pre\<^sub>D(P) \<and> post\<^sub>D(Q))"
    by (auto simp add: refBy_order)
qed

subsection {* H3: The design assumption is a precondition *}

theorem H3_idem:
  "H3(H3(P)) = H3(P)"
  by (metis H3_def design_skip_idem seqr_assoc)

theorem H3_mono:
  "P \<sqsubseteq> Q \<Longrightarrow> H3(P) \<sqsubseteq> H3(Q)"
  by (simp add: H3_def seqr_mono)

theorem H3_Monotonic:
  "Monotonic H3"
  by (simp add: H3_mono mono_def)

theorem H3_Continuous: "Continuous H3"
  by (rel_auto)

theorem design_condition_is_H3:
  assumes "out\<alpha> \<sharp> p"
  shows "(p \<turnstile> Q) is H3"
proof -
  have "((p \<turnstile> Q) ;; II\<^sub>D) = (\<not> ((\<not> p) ;; true)) \<turnstile> (Q\<^sup>t ;; II\<lbrakk>true/$ok\<rbrakk>)"
    by (simp add: skip_d_alt_def design_composition_subst unrest assms)
  also have "... = p \<turnstile> (Q\<^sup>t ;; II\<lbrakk>true/$ok\<rbrakk>)"
    using assms precond_equiv seqr_true_lemma by force
  also have "... = p \<turnstile> Q"
    by (rel_auto)
  finally show ?thesis
    by (simp add: H3_def Healthy_def')
qed

theorem rdesign_H3_iff_pre:
  "P \<turnstile>\<^sub>r Q is H3 \<longleftrightarrow> P = (P ;; true)"
proof -
  have "(P \<turnstile>\<^sub>r Q) ;; II\<^sub>D = (P \<turnstile>\<^sub>r Q) ;; (true \<turnstile>\<^sub>r II)"
    by (simp add: skip_d_def)
  also have "... = (\<not> ((\<not> P) ;; true) \<and> \<not> (Q ;; (\<not> true))) \<turnstile>\<^sub>r (Q ;; II)"
    by (simp add: rdesign_composition)
  also have "... = (\<not> ((\<not> P) ;; true) \<and> \<not> (Q ;; (\<not> true))) \<turnstile>\<^sub>r Q"
    by simp
  also have "... = (\<not> ((\<not> P) ;; true)) \<turnstile>\<^sub>r Q"
    by (pred_auto)
  finally have "P \<turnstile>\<^sub>r Q is H3 \<longleftrightarrow> P \<turnstile>\<^sub>r Q = (\<not> ((\<not> P) ;; true)) \<turnstile>\<^sub>r Q"
    by (metis H3_def Healthy_def')
  also have "... \<longleftrightarrow> P = (\<not> ((\<not> P) ;; true))"
    by (metis rdesign_pre)
      thm seqr_true_lemma
  also have "... \<longleftrightarrow> P = (P ;; true)"
    by (simp add: seqr_true_lemma)
  finally show ?thesis .
qed

theorem design_H3_iff_pre:
  assumes "$ok \<sharp> P" "$ok\<acute> \<sharp> P" "$ok \<sharp> Q" "$ok\<acute> \<sharp> Q"
  shows "P \<turnstile> Q is H3 \<longleftrightarrow> P = (P ;; true)"
proof -
  have "P \<turnstile> Q = \<lfloor>P\<rfloor>\<^sub>D \<turnstile>\<^sub>r \<lfloor>Q\<rfloor>\<^sub>D"
    by (simp add: assms lift_desr_inv rdesign_def)
  moreover hence "\<lfloor>P\<rfloor>\<^sub>D \<turnstile>\<^sub>r \<lfloor>Q\<rfloor>\<^sub>D is H3 \<longleftrightarrow> \<lfloor>P\<rfloor>\<^sub>D = (\<lfloor>P\<rfloor>\<^sub>D ;; true)"
    using rdesign_H3_iff_pre by blast
  ultimately show ?thesis
    by (metis assms(1,2) drop_desr_inv lift_desr_inv lift_dist_seq aext_true)
qed

theorem H1_H3_commute:
  "H1 (H3 P) = H3 (H1 P)"
  by (rel_auto)

lemma skip_d_absorb_J_1:
  "(II\<^sub>D ;; J) = II\<^sub>D"
  by (metis H2_def H2_rdesign skip_d_def)

lemma skip_d_absorb_J_2:
  "(J ;; II\<^sub>D) = II\<^sub>D"
proof -
  have "(J ;; II\<^sub>D) = (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D) ;; (true \<turnstile> II)"
    by (simp add: J_def skip_d_alt_def)
  also have "... = (\<^bold>\<exists> ok\<^sub>0 \<bullet> (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (true \<turnstile> II)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>)"
    by (subst seqr_middle[of ok], simp_all)
  also have "... = (((($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>false/$ok\<acute>\<rbrakk> ;; (true \<turnstile> II)\<lbrakk>false/$ok\<rbrakk>)
                  \<or> ((($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (true \<turnstile> II)\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: disj_comm false_alt_def true_alt_def)
  also have "... = ((\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D ;; true) \<or> (\<lceil>II\<rceil>\<^sub>D ;; $ok\<acute> \<and> \<lceil>II\<rceil>\<^sub>D))"
    by (rel_auto)
  also have "... = II\<^sub>D"
    by (rel_auto)
  finally show ?thesis .
qed

lemma H2_H3_absorb:
  "H2 (H3 P) = H3 P"
  by (metis H2_def H3_def seqr_assoc skip_d_absorb_J_1)

lemma H3_H2_absorb:
  "H3 (H2 P) = H3 P"
  by (metis H2_def H3_def seqr_assoc skip_d_absorb_J_2)

theorem H2_H3_commute:
  "H2 (H3 P) = H3 (H2 P)"
  by (simp add: H2_H3_absorb H3_H2_absorb)

theorem H3_design_pre:
  assumes "$ok \<sharp> p" "out\<alpha> \<sharp> p" "$ok \<sharp> Q" "$ok\<acute> \<sharp> Q"
  shows "H3(p \<turnstile> Q) = p \<turnstile> Q"
  using assms
  by (metis Healthy_def' design_H3_iff_pre precond_right_unit unrest_out\<alpha>_var ok_vwb_lens vwb_lens_mwb)

theorem H3_rdesign_pre:
  assumes "out\<alpha> \<sharp> p"
  shows "H3(p \<turnstile>\<^sub>r Q) = p \<turnstile>\<^sub>r Q"
  using assms
  by (simp add: H3_def)

theorem H3_ndesign:
  "H3(p \<turnstile>\<^sub>n Q) = (p \<turnstile>\<^sub>n Q)"
  by (simp add: H3_def ndesign_def unrest_pre_out\<alpha>)

theorem H1_H3_is_design:
  assumes "P is H1" "P is H3"
  shows "P = (\<not> P\<^sup>f) \<turnstile> P\<^sup>t"
  by (metis H1_H2_eq_design H2_H3_absorb Healthy_def' assms(1) assms(2))

theorem H1_H3_is_rdesign:
  assumes "P is H1" "P is H3"
  shows "P = pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
  by (metis H1_H2_is_rdesign H2_H3_absorb Healthy_def' assms)

theorem H1_H3_is_normal_design:
  assumes "P is H1" "P is H3"
  shows "P = \<lfloor>pre\<^sub>D(P)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P)"
  by (metis H1_H3_is_rdesign assms drop_pre_inv ndesign_def precond_equiv rdesign_H3_iff_pre)

abbreviation "H1_H3 p \<equiv> H1 (H3 p)"

notation H1_H3 ("\<^bold>N")

lemma H1_H3_comp: "H1_H3 = H1 \<circ> H3"
  by (auto)

lemma H1_H3_idempotent: "\<^bold>N (\<^bold>N P) = \<^bold>N P"
  by (simp add: H1_H3_commute H1_idem H3_idem)

lemma H1_H3_Idempotent [closure]: "Idempotent \<^bold>N"
  by (simp add: Idempotent_def H1_H3_idempotent)

lemma H1_H3_monotonic [closure]: "Monotonic \<^bold>N"
  by (simp add: H1_monotone H3_mono mono_def)

lemma H1_H3_Continuous [closure]: "Continuous \<^bold>N"
  by (simp add: Continuous_comp H1_Continuous H1_H3_comp H3_Continuous)

lemma H1_H3_intro:
  assumes "P is \<^bold>H" "out\<alpha> \<sharp> pre\<^sub>D(P)"
  shows "P is \<^bold>N"
  by (metis H1_H2_eq_rdesign H1_rdesign H3_rdesign_pre Healthy_def' assms)
    
lemma H1_H3_impl_H2 [closure]: "P is H1_H3 \<Longrightarrow> P is H1_H2"
  by (metis H1_H2_commute H1_idem H2_H3_absorb Healthy_def')

lemma H1_H3_eq_design_d_comp: "H1 (H3 P) = ((\<not> P\<^sup>f) \<turnstile> P\<^sup>t) ;; II\<^sub>D"
  by (metis H1_H2_eq_design H1_H3_commute H3_H2_absorb H3_def)

lemma H1_H3_eq_design: "H1 (H3 P) = (\<not> (P\<^sup>f ;; true)) \<turnstile> P\<^sup>t"
  apply (simp add: H1_H3_eq_design_d_comp skip_d_alt_def)
  apply (subst design_composition_subst)
  apply (simp_all add: usubst unrest)
  apply (rel_auto)
done

lemma H3_unrest_out_alpha_nok [unrest]:
  assumes "P is H1_H3"
  shows "out\<alpha> \<sharp> P\<^sup>f"
proof -
  have "P = (\<not> (P\<^sup>f ;; true)) \<turnstile> P\<^sup>t"
    by (metis H1_H3_eq_design Healthy_def assms)
  also have "out\<alpha> \<sharp> (...\<^sup>f)"
    by (simp add: design_def usubst unrest, rel_auto)
  finally show ?thesis .
qed

lemma H3_unrest_out_alpha [unrest]: "P is H1_H3 \<Longrightarrow> out\<alpha> \<sharp> pre\<^sub>D(P)"
  by (metis H1_H3_commute H1_H3_is_rdesign H1_idem Healthy_def' precond_equiv rdesign_H3_iff_pre)

lemma ndesign_H1_H3 [closure]: "p \<turnstile>\<^sub>n Q is \<^bold>N"
  by (simp add: H1_rdesign H3_def Healthy_def' ndesign_def unrest_pre_out\<alpha>)

lemma ndesign_form: "P is \<^bold>N \<Longrightarrow> (\<lfloor>pre\<^sub>D(P)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P)) = P"
  by (metis H1_H2_eq_rdesign H1_H3_impl_H2 H3_unrest_out_alpha Healthy_def drop_pre_inv ndesign_def)

lemma des_bot_H1_H3 [closure]: "\<bottom>\<^sub>D is \<^bold>N"
  by (metis H1_design H3_def Healthy_def' design_false_pre design_true_left_zero skip_d_alt_def bot_d_def)

lemma assigns_d_H1_H3 [closure]: "\<langle>\<sigma>\<rangle>\<^sub>D is \<^bold>N"
  by (metis H1_rdesign H3_ndesign Healthy_def' aext_true assigns_d_def ndesign_def)

lemma des_top_is_H1_H3 [closure]: "\<top>\<^sub>D is \<^bold>N"
  by (metis ndesign_H1_H3 ndesign_miracle) 
    
lemma skip_d_is_H1_H3 [closure]: "II\<^sub>D is \<^bold>N"
  by (metis assigns_d_H1_H3 assigns_d_id)
    
lemma seq_r_H1_H3_closed [closure]:
  assumes "P is \<^bold>N" "Q is \<^bold>N"
  shows "(P ;; Q) is \<^bold>N"
  by (metis (no_types) H1_H2_eq_design H1_H3_eq_design_d_comp H1_H3_impl_H2 Healthy_def assms(1) assms(2) seq_r_H1_H2_closed seqr_assoc)
  
lemma dcond_H1_H2_closed [closure]:
  assumes "P is \<^bold>N" "Q is \<^bold>N"
  shows "(P \<triangleleft> b \<triangleright>\<^sub>D Q) is \<^bold>N"
  by (metis assms ndesign_H1_H3 ndesign_dcond ndesign_form)

lemma inf_H1_H2_closed [closure]:
  assumes "P is \<^bold>N" "Q is \<^bold>N"
  shows "(P \<sqinter> Q) is \<^bold>N"
  by (metis assms ndesign_H1_H3 ndesign_choice ndesign_form)

lemma sup_H1_H2_closed [closure]:
  assumes "P is \<^bold>N" "Q is \<^bold>N"
  shows "(P \<squnion> Q) is \<^bold>N"
  by (metis assms ndesign_H1_H3 ndesign_inf ndesign_form)
    
lemma ndes_seqr_miracle:
  assumes "P is \<^bold>N"
  shows "P ;; \<top>\<^sub>D = \<lfloor>pre\<^sub>D P\<rfloor>\<^sub>< \<turnstile>\<^sub>n false"
proof -
  have "P ;; \<top>\<^sub>D = (\<lfloor>pre\<^sub>D(P)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P)) ;; (true \<turnstile>\<^sub>n false)"
    by (simp add: assms ndesign_form ndesign_miracle)
  also have "... = \<lfloor>pre\<^sub>D P\<rfloor>\<^sub>< \<turnstile>\<^sub>n false"
    by (simp add: ndesign_composition_wp wp alpha)
  finally show ?thesis .
qed
    
lemma ndes_seqr_abort: 
  assumes "P is \<^bold>N"
  shows "P ;; \<bottom>\<^sub>D = (\<lfloor>pre\<^sub>D P\<rfloor>\<^sub>< \<and> post\<^sub>D P wp false) \<turnstile>\<^sub>n false"
proof -
  have "P ;; \<bottom>\<^sub>D = (\<lfloor>pre\<^sub>D(P)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P)) ;; (false \<turnstile>\<^sub>n false)"
    by (simp add: assms bot_d_true ndesign_false_pre ndesign_form)
  also have "... = (\<lfloor>pre\<^sub>D P\<rfloor>\<^sub>< \<and> post\<^sub>D P wp false) \<turnstile>\<^sub>n false"
    by (simp add: ndesign_composition_wp alpha)
  finally show ?thesis .
qed
      
lemma wp_assigns_d [wp]: "\<langle>\<sigma>\<rangle>\<^sub>D wp\<^sub>D r = \<sigma> \<dagger> r"
  by (rel_auto)

theorem wpd_seq_r_H1_H3 [wp]:
  fixes P Q :: "'\<alpha> hrel_des"
  assumes "P is \<^bold>N" "Q is \<^bold>N"
  shows "(P ;; Q) wp\<^sub>D r = P wp\<^sub>D (Q wp\<^sub>D r)"
  by (metis H1_H3_commute H1_H3_is_normal_design H1_idem Healthy_def' assms(1) assms(2) wpnd_seq_r)

lemma preD_USUP_mem: "pre\<^sub>D (\<Squnion> i\<in>A \<bullet> P i) = (\<Sqinter> i\<in>A \<bullet> pre\<^sub>D(P i))"
  by (rel_auto)
  
lemma preD_USUP_ind: "pre\<^sub>D (\<Squnion> i \<bullet> P i) = (\<Sqinter> i \<bullet> pre\<^sub>D(P i))"
  by (rel_auto)

lemma USUP_ind_H1_H3_closed [closure]:
  "\<lbrakk> \<And> i. P i is \<^bold>N \<rbrakk> \<Longrightarrow> (\<Squnion> i \<bullet> P i) is \<^bold>N"
  by (rule H1_H3_intro, simp_all add: H1_H3_impl_H2 USUP_ind_H1_H2_closed preD_USUP_ind unrest)
    
lemma state_subst_H1_H3_closed [closure]: 
  "P is \<^bold>N \<Longrightarrow> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rceil>\<^sub>s \<dagger> P is \<^bold>N"
  by (metis H1_H2_eq_rdesign H1_H3_impl_H2 Healthy_if assign_d_left_comp assigns_d_H1_H3 seq_r_H1_H3_closed state_subst_design)
    
text {* If two normal designs have the same weakest precondition for any given postcondition, then
  the two designs are equivalent. *}

theorem wpd_eq_intro: "\<lbrakk> \<And> r. (p\<^sub>1 \<turnstile>\<^sub>n Q\<^sub>1) wp\<^sub>D r = (p\<^sub>2 \<turnstile>\<^sub>n Q\<^sub>2) wp\<^sub>D r \<rbrakk> \<Longrightarrow> (p\<^sub>1 \<turnstile>\<^sub>n Q\<^sub>1) = (p\<^sub>2 \<turnstile>\<^sub>n Q\<^sub>2)"
apply (rel_simp robust; metis curry_conv)
done

theorem wpd_H3_eq_intro: "\<lbrakk> P is H1_H3; Q is H1_H3; \<And> r. P wp\<^sub>D r = Q wp\<^sub>D r \<rbrakk> \<Longrightarrow> P = Q"
  by (metis H1_H3_commute H1_H3_is_normal_design H3_idem Healthy_def' wpd_eq_intro)

subsection {* H4: Feasibility *}

theorem H4_idem:
  "H4(H4(P)) = H4(P)"
  by (pred_auto)

lemma is_H4_alt_def:
  "P is H4 \<longleftrightarrow> (P ;; true) = true"
  by (rel_auto)

lemma H4_assigns_d: "\<langle>\<sigma>\<rangle>\<^sub>D is H4"
proof -
  have "(\<langle>\<sigma>\<rangle>\<^sub>D ;; (false \<turnstile>\<^sub>r true\<^sub>h)) = (false \<turnstile>\<^sub>r true)"
    by (simp add: assigns_d_def rdesign_composition assigns_r_feasible)
  moreover have "... = true"
    by (rel_auto)
  ultimately show ?thesis
    using is_H4_alt_def by auto
qed

subsection {* UTP theories *}

typedecl DES
typedecl NDES

abbreviation "DES \<equiv> UTHY(DES, '\<alpha> des)"
abbreviation "NDES \<equiv> UTHY(NDES, '\<alpha> des)"

overloading
  des_hcond == "utp_hcond :: (DES, '\<alpha> des) uthy \<Rightarrow> ('\<alpha> des \<times> '\<alpha> des) health"
  des_unit == "utp_unit :: (DES, '\<alpha> des) uthy \<Rightarrow> '\<alpha> hrel_des" (unchecked)

  ndes_hcond == "utp_hcond :: (NDES, '\<alpha> des) uthy \<Rightarrow> ('\<alpha> des \<times> '\<alpha> des) health"
  ndes_unit == "utp_unit :: (NDES, '\<alpha> des) uthy \<Rightarrow> '\<alpha> hrel_des" (unchecked)

begin
  definition des_hcond :: "(DES, '\<alpha> des) uthy \<Rightarrow> ('\<alpha> des \<times> '\<alpha> des) health" where
  [upred_defs]: "des_hcond t = H1_H2"

  definition des_unit :: "(DES, '\<alpha> des) uthy \<Rightarrow> '\<alpha> hrel_des" where
  [upred_defs]: "des_unit t = II\<^sub>D"

  definition ndes_hcond :: "(NDES, '\<alpha> des) uthy \<Rightarrow> ('\<alpha> des \<times> '\<alpha> des) health" where
  [upred_defs]: "ndes_hcond t = H1_H3"

  definition ndes_unit :: "(NDES, '\<alpha> des) uthy \<Rightarrow> '\<alpha> hrel_des" where
  [upred_defs]: "ndes_unit t = II\<^sub>D"

end

interpretation des_utp_theory: utp_theory DES
  by (simp add: H1_H2_commute H1_idem H2_idem des_hcond_def utp_theory_def)

interpretation ndes_utp_theory: utp_theory NDES
  by (simp add: H1_H3_commute H1_idem H3_idem ndes_hcond_def utp_theory.intro)

interpretation des_left_unital: utp_theory_left_unital DES
  apply (unfold_locales)
  apply (simp_all add: des_hcond_def des_unit_def)
  using seq_r_H1_H2_closed apply blast
  apply (simp add: rdesign_is_H1_H2 skip_d_def)
  apply (metis H1_idem H1_left_unit Healthy_def')
done

interpretation ndes_unital: utp_theory_unital NDES
  apply (unfold_locales, simp_all add: ndes_hcond_def ndes_unit_def)
  using seq_r_H1_H3_closed apply blast
  apply (metis H1_rdesign H3_def Healthy_def' design_skip_idem skip_d_def)
  apply (metis H1_idem H1_left_unit Healthy_def')
  apply (metis H1_H3_commute H3_def H3_idem Healthy_def')
done

interpretation design_theory_continuous: utp_theory_continuous DES
  rewrites "\<And> P. P \<in> carrier (uthy_order DES) \<longleftrightarrow> P is \<^bold>H"
  and "carrier (uthy_order DES) \<rightarrow> carrier (uthy_order DES) \<equiv> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H"
  and "\<lbrakk>\<H>\<^bsub>DES\<^esub>\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<H>\<^bsub>DES\<^esub>\<rbrakk>\<^sub>H \<equiv> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H"
  and "le (uthy_order DES) = op \<sqsubseteq>"
  and "eq (uthy_order DES) = op ="
  by (unfold_locales, simp_all add: des_hcond_def H1_H2_Continuous utp_order_def)
                                                            
interpretation normal_design_theory_continuous: utp_theory_continuous NDES
  rewrites "\<And> P. P \<in> carrier (uthy_order NDES) \<longleftrightarrow> P is \<^bold>N"
  and "carrier (uthy_order NDES) \<rightarrow> carrier (uthy_order NDES) \<equiv> \<lbrakk>\<^bold>N\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>N\<rbrakk>\<^sub>H"
  and "\<lbrakk>\<H>\<^bsub>NDES\<^esub>\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<H>\<^bsub>NDES\<^esub>\<rbrakk>\<^sub>H \<equiv> \<lbrakk>\<^bold>N\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>N\<rbrakk>\<^sub>H"
  and "le (uthy_order NDES) = op \<sqsubseteq>"
  and "A \<subseteq> carrier (uthy_order NDES) \<longleftrightarrow> A \<subseteq> \<lbrakk>\<^bold>N\<rbrakk>\<^sub>H"  
  and "eq (uthy_order NDES) = op ="  
  by (unfold_locales, simp_all add: ndes_hcond_def H1_H3_Continuous utp_order_def)

thm design_theory_continuous.healthy_top

lemma design_lat_top: "\<^bold>\<top>\<^bsub>DES\<^esub> = \<^bold>H(false)"
  by (simp add: design_theory_continuous.healthy_top, simp add: des_hcond_def)

lemma design_lat_bottom: "\<^bold>\<bottom>\<^bsub>DES\<^esub> = \<^bold>H(true)"
  by (simp add: design_theory_continuous.healthy_bottom, simp add: des_hcond_def)

lemma ndesign_lat_top: "\<^bold>\<top>\<^bsub>NDES\<^esub> = \<^bold>N(false)"
  by (metis ndes_hcond_def normal_design_theory_continuous.healthy_top)

lemma ndesign_lat_bottom: "\<^bold>\<bottom>\<^bsub>NDES\<^esub> = \<^bold>N(true)"
  by (metis ndes_hcond_def normal_design_theory_continuous.healthy_bottom)
    
abbreviation design_lfp :: "('\<alpha> hrel_des \<Rightarrow> '\<alpha> hrel_des) \<Rightarrow> '\<alpha> hrel_des" ("\<mu>\<^sub>D") where
"\<mu>\<^sub>D F \<equiv> \<^bold>\<mu>\<^bsub>DES\<^esub> F"

abbreviation design_gfp :: "('\<alpha> hrel_des \<Rightarrow> '\<alpha> hrel_des) \<Rightarrow> '\<alpha> hrel_des" ("\<nu>\<^sub>D") where
"\<nu>\<^sub>D F \<equiv> \<^bold>\<nu>\<^bsub>DES\<^esub> F"

syntax
  "_dmu" :: "pttrn \<Rightarrow> logic \<Rightarrow> logic" ("\<mu>\<^sub>D _ \<bullet> _" [0, 10] 10)
  "_dnu" :: "pttrn \<Rightarrow> logic \<Rightarrow> logic" ("\<nu>\<^sub>D _ \<bullet> _" [0, 10] 10)

translations
  "\<mu>\<^sub>D X \<bullet> P" == "\<^bold>\<mu>\<^bsub>CONST DES\<^esub> (\<lambda> X. P)"
  "\<nu>\<^sub>D X \<bullet> P" == "\<^bold>\<nu>\<^bsub>CONST DES\<^esub> (\<lambda> X. P)"

thm design_theory_continuous.GFP_unfold
thm design_theory_continuous.LFP_unfold

text {* Example Galois connection between designs and relations. Based on Jim's example in COMPASS
        deliverable D23.5. *}

definition [upred_defs]: "Des(R) = \<^bold>H(\<lceil>R\<rceil>\<^sub>D \<and> $ok\<acute>)"
definition [upred_defs]: "Rel(D) = \<lfloor>D\<lbrakk>true,true/$ok,$ok\<acute>\<rbrakk>\<rfloor>\<^sub>D"

lemma Des_design: "Des(R) = true \<turnstile>\<^sub>r R"
  by (rel_auto)

lemma Rel_design: "Rel(P \<turnstile>\<^sub>r Q) = (P \<Rightarrow> Q)"
  by (rel_auto)

interpretation Des_Rel_coretract:
  coretract "DES \<leftarrow>\<langle>Des,Rel\<rangle>\<rightarrow> REL"
  rewrites
    "\<And> x. x \<in> carrier \<X>\<^bsub>DES \<leftarrow>\<langle>Des,Rel\<rangle>\<rightarrow> REL\<^esub> = (x is \<^bold>H)" and
    "\<And> x. x \<in> carrier \<Y>\<^bsub>DES \<leftarrow>\<langle>Des,Rel\<rangle>\<rightarrow> REL\<^esub> = True" and
    "\<pi>\<^sub>*\<^bsub>DES \<leftarrow>\<langle>Des,Rel\<rangle>\<rightarrow> REL\<^esub> = Des" and
    "\<pi>\<^sup>*\<^bsub>DES \<leftarrow>\<langle>Des,Rel\<rangle>\<rightarrow> REL\<^esub> = Rel" and
    "le \<X>\<^bsub>DES \<leftarrow>\<langle>Des,Rel\<rangle>\<rightarrow> REL\<^esub> = op \<sqsubseteq>" and
    "le \<Y>\<^bsub>DES \<leftarrow>\<langle>Des,Rel\<rangle>\<rightarrow> REL\<^esub> = op \<sqsubseteq>"
proof (unfold_locales, simp_all add: rel_hcond_def des_hcond_def)
  show "\<And>x. x is id"
    by (simp add: Healthy_def)
next
  show "Rel \<in> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>id\<rbrakk>\<^sub>H"
    by (auto simp add: Rel_def rel_hcond_def Healthy_def)
next
  show "Des \<in> \<lbrakk>id\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H"
    by (auto simp add: Des_def des_hcond_def Healthy_def H1_H2_commute H1_idem H2_idem)
next
  fix R :: "'a hrel"
  show "R \<sqsubseteq> Rel (Des R)"
    by (simp add: Des_design Rel_design)
next
  fix R :: "'a hrel" and D :: "'a hrel_des"
  assume a: "D is \<^bold>H"
  then obtain D\<^sub>1 D\<^sub>2 where D: "D = D\<^sub>1 \<turnstile>\<^sub>r D\<^sub>2"
    by (metis H1_H2_commute H1_H2_is_rdesign H1_idem Healthy_def')
  show "(Rel D \<sqsubseteq> R) = (D \<sqsubseteq> Des R)"
  proof -
    have "(D \<sqsubseteq> Des R) = (D\<^sub>1 \<turnstile>\<^sub>r D\<^sub>2 \<sqsubseteq> true \<turnstile>\<^sub>r R)"
      by (simp add: D Des_design)
    also have "... = `D\<^sub>1 \<and> R \<Rightarrow> D\<^sub>2`"
      by (simp add: rdesign_refinement)
    also have "... = ((D\<^sub>1 \<Rightarrow> D\<^sub>2) \<sqsubseteq> R)"
      by (rel_auto)
    also have "... = (Rel D \<sqsubseteq> R)"
      by (simp add: D Rel_design)
    finally show ?thesis ..
  qed
qed

text {* From this interpretation we gain many Galois theorems. Some require simplification to
        remove superfluous assumptions. *}

thm Des_Rel_coretract.deflation[simplified]
thm Des_Rel_coretract.inflation
thm Des_Rel_coretract.upper_comp[simplified]
thm Des_Rel_coretract.lower_comp

text {* Specialise @{thm [source] mu_refine_intro} to designs. *}

lemma design_mu_refine_intro:
  assumes "$ok\<acute> \<sharp> C" "$ok\<acute> \<sharp> S" "(C \<turnstile> S) \<sqsubseteq> F(C \<turnstile> S)" "`C \<Rightarrow> (\<mu>\<^sub>D F \<Leftrightarrow> \<nu>\<^sub>D F)`"
  shows "(C \<turnstile> S) \<sqsubseteq> \<mu>\<^sub>D F"
proof -
  from assms have "(C \<turnstile> S) \<sqsubseteq> \<nu>\<^sub>D F"
    thm design_theory_continuous.weak.GFP_upperbound
    by (simp add: design_is_H1_H2 design_theory_continuous.weak.GFP_upperbound)
  with assms show ?thesis
    by (rel_auto, metis (no_types, lifting))
qed

lemma rdesign_mu_refine_intro:
  assumes "(C \<turnstile>\<^sub>r S) \<sqsubseteq> F(C \<turnstile>\<^sub>r S)" "`\<lceil>C\<rceil>\<^sub>D \<Rightarrow> (\<mu>\<^sub>D F \<Leftrightarrow> \<nu>\<^sub>D F)`"
  shows "(C \<turnstile>\<^sub>r S) \<sqsubseteq> \<mu>\<^sub>D F"
  using assms by (simp add: rdesign_def design_mu_refine_intro unrest)

lemma H1_H2_mu_refine_intro:
  assumes "P is \<^bold>H" "P \<sqsubseteq> F(P)" "`\<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D \<Rightarrow> (\<mu>\<^sub>D F \<Leftrightarrow> \<nu>\<^sub>D F)`"
  shows "P \<sqsubseteq> \<mu>\<^sub>D F"
  by (metis H1_H2_eq_rdesign Healthy_if assms rdesign_mu_refine_intro)

text {* A theorem we'd like to have, but that doesn't seem true ... *}

lemma conditional_refine:
  assumes "mono F" "(P \<Rightarrow> F(Q)) \<sqsubseteq> Q"
  shows "(P \<Rightarrow> \<mu> F) \<sqsubseteq> Q"
  oops

locale design_fp =
  fixes F :: "'\<alpha> hrel_des \<Rightarrow> '\<alpha> hrel_des"
  assumes mono_F: "mono F"
  and type_F: "F \<in> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H"
begin

  definition "P(Y) \<equiv> \<nu> X \<bullet> pre\<^sub>D(F(X \<turnstile>\<^sub>r Y))"
  definition "Q \<equiv> \<mu> Y \<bullet> (P(Y) \<Rightarrow> post\<^sub>D(F(P(Y) \<turnstile>\<^sub>r Y)))"

  lemma mono_design_iter: "mono (\<lambda>X. pre\<^sub>D (F X) \<turnstile>\<^sub>r post\<^sub>D (F X))"
    apply (rule monoI)
    apply (rule rdesign_refine_intro')
    apply (metis design_pre_choice mono_F mono_def semilattice_sup_class.le_iff_sup utp_pred_laws.inf.absorb_iff2)
    apply (metis (no_types, lifting) design_post_choice mono_F semilattice_inf_class.inf.absorb2 semilattice_inf_class.inf.orderE semilattice_sup_class.mono_sup semilattice_sup_class.sup.orderE semilattice_sup_class.sup_ge1 utp_pred_laws.le_infI2 utp_pred_laws.sup.order_iff)
  done

  lemma mu_design_iter:
    "(\<mu> X \<bullet> pre\<^sub>D(F(X)) \<turnstile>\<^sub>r post\<^sub>D(F(X))) = F(\<mu> X \<bullet> pre\<^sub>D(F(X)) \<turnstile>\<^sub>r post\<^sub>D(F(X)))"
      by (metis (no_types, lifting) H1_H2_eq_rdesign H1_H2_idempotent Healthy_def Healthy_if
                PiE gfp_fixpoint mem_Collect_eq mono_design_iter type_F)

  lemma mu_design_form:
    "\<mu>\<^sub>D F = (\<mu> X \<bullet> pre\<^sub>D(F(X)) \<turnstile>\<^sub>r post\<^sub>D(F(X)))"
  proof -
    have 1: "F (\<mu> X \<bullet> pre\<^sub>D (F X) \<turnstile>\<^sub>r post\<^sub>D (F X)) is \<^bold>H"
      by (metis (no_types, lifting) H1_H2_eq_rdesign Healthy_def' gfp_unfold mono_design_iter mu_design_iter)
    have 2:"Mono\<^bsub>uthy_order DES\<^esub> F"
      by (simp add: mono_F mono_Monotone_utp_order)
    hence 3:"\<mu>\<^sub>D F = F (\<mu>\<^sub>D F)"
      by (simp add: design_theory_continuous.LFP_unfold[THEN sym] type_F)
    hence "pre\<^sub>D (F (F (\<mu>\<^sub>D F))) \<turnstile>\<^sub>r post\<^sub>D (F (F (\<mu>\<^sub>D F))) = \<mu>\<^sub>D F"
      by (metis H1_H2_eq_rdesign Healthy_def design_theory_continuous.weak.LFP_closed)
    hence "(\<mu> X \<bullet> pre\<^sub>D (F X) \<turnstile>\<^sub>r post\<^sub>D (F X)) \<sqsubseteq> F (\<mu>\<^sub>D F)"
      by (simp add: 2 design_theory_continuous.weak.LFP_lemma3 gfp_upperbound type_F)
    thus ?thesis
      using 1 3 design_theory_continuous.weak.LFP_lowerbound eq_iff mu_design_iter by auto
  qed

  lemma mu_postcondition: "post\<^sub>D(\<mu>\<^sub>D F) = Q"
  proof (rule antisym)
    show "Q \<sqsubseteq> post\<^sub>D (\<mu>\<^sub>D F)"
      apply (simp add: Q_def)
      apply (rule gfp_upperbound)
    oops

  lemma mu_postcondition:
    "post\<^sub>D(F(\<mu> X \<bullet> pre\<^sub>D(F(X)) \<turnstile>\<^sub>r post\<^sub>D(F(X)))) = Q"
  proof (simp add: Q_def, rule antisym)
    show "(\<mu> Y \<bullet> P Y \<Rightarrow> post\<^sub>D (F (P Y \<turnstile>\<^sub>r Y))) \<sqsubseteq> post\<^sub>D (F (\<mu> X \<bullet> pre\<^sub>D (F X) \<turnstile>\<^sub>r post\<^sub>D (F X)))"
    proof (rule gfp_upperbound)
  oops

  lemma mu_precondition:
    "pre\<^sub>D(F(\<mu> X \<bullet> pre\<^sub>D(F(X)) \<turnstile>\<^sub>r post\<^sub>D(F(X)))) = P(Q)"
  proof (simp add: P_def, rule antisym)
    show "(\<nu> X \<bullet> pre\<^sub>D (F (X \<turnstile>\<^sub>r Q))) \<sqsubseteq> pre\<^sub>D (F (\<mu> X \<bullet> pre\<^sub>D (F X) \<turnstile>\<^sub>r post\<^sub>D (F X)))"
    proof (rule lfp_greatest)
      fix Y
      assume a:"Y \<sqsubseteq> pre\<^sub>D (F (Y \<turnstile>\<^sub>r Q))"
      have "pre\<^sub>D (F (Y \<turnstile>\<^sub>r Q)) \<sqsubseteq> pre\<^sub>D (F (\<mu> X \<bullet> pre\<^sub>D (F X) \<turnstile>\<^sub>r post\<^sub>D (F X)))"
      proof (rule rdesign_ref_monos)
        show "F (\<mu> X \<bullet> pre\<^sub>D (F X) \<turnstile>\<^sub>r post\<^sub>D (F X)) \<sqsubseteq> F (Y \<turnstile>\<^sub>r Q)"
        proof (rule monoD[OF mono_F])
          show "(\<mu> X \<bullet> pre\<^sub>D (F X) \<turnstile>\<^sub>r post\<^sub>D (F X)) \<sqsubseteq> Y \<turnstile>\<^sub>r Q"
          proof (rule gfp_upperbound, rule rdesign_refine_intro')
            show "Y \<sqsubseteq> pre\<^sub>D (F (Y \<turnstile>\<^sub>r Q))"
              using a by blast
            have "post\<^sub>D (F (Y \<turnstile>\<^sub>r Q)) \<sqsubseteq> Q"
              apply (simp add: Q_def)
              apply (rule gfp_least)
            oops

  lemma mono_pre_F: "X \<sqsubseteq> Y \<Longrightarrow> pre\<^sub>D(F (X \<turnstile>\<^sub>r Z)) \<sqsubseteq> pre\<^sub>D(F (Y \<turnstile>\<^sub>r Z))"
    apply (rule rdesign_ref_monos(1))
    using rdesign_is_H1_H2 type_F apply fastforce
    using rdesign_is_H1_H2 type_F apply fastforce
    apply (rule monoD[OF mono_F])
    apply (rel_simp)
  done

  lemma P_is_pre: "P(X) = pre\<^sub>D((F (P X \<turnstile>\<^sub>r X)))"
    apply (simp add: P_def)
    apply (subst lfp_unfold)
    apply (simp_all add: monoI mono_pre_F)
  done

  lemma antitone_post_F: "X \<sqsubseteq> Y \<Longrightarrow> pre\<^sub>D(F (Z \<turnstile>\<^sub>r Y)) \<sqsubseteq> pre\<^sub>D(F (Z \<turnstile>\<^sub>r X))"
    apply (rule rdesign_ref_monos(1))
    using rdesign_is_H1_H2 type_F apply fastforce
    using rdesign_is_H1_H2 type_F apply fastforce
    apply (rule monoD[OF mono_F])
    apply (rel_simp)
  done

 lemma P_antitone:
    "X \<sqsubseteq> Y \<Longrightarrow> P(Y) \<sqsubseteq> P(X)"
    apply (simp add: P_def)
    apply (rule lfp_mono)
    apply (simp add: antitone_post_F)
  done

  lemma mono_post_F: "Y \<sqsubseteq> X \<Longrightarrow> post\<^sub>D(F(P(Y) \<turnstile>\<^sub>r Y)) \<sqsubseteq> (P(Y) \<and> post\<^sub>D(F(P(X) \<turnstile>\<^sub>r X)))"
    apply (subst P_is_pre)
    apply (rule rdesign_ref_monos(2))
    using rdesign_is_H1_H2 type_F apply fastforce
    using rdesign_is_H1_H2 type_F apply fastforce
    apply (rule monoD[OF mono_F])
    apply (rule rdesign_refine_intro)
    using P_antitone refBy_order apply auto[1]
    apply (rel_auto)
  done

  lemma P_Q_design_fixed_point:
    "F(P(Q) \<turnstile>\<^sub>r Q) = (P(Q) \<turnstile>\<^sub>r Q)"
  proof -
    have "F(P(Q) \<turnstile>\<^sub>r Q) = pre\<^sub>D(F(P(Q) \<turnstile>\<^sub>r Q)) \<turnstile>\<^sub>r post\<^sub>D(F(P(Q) \<turnstile>\<^sub>r Q))"
    proof -
      have "P Q \<turnstile>\<^sub>r Q is \<^bold>H"
        using rdesign_is_H1_H2 by blast
      then show ?thesis
        by (metis (no_types) H1_H2_eq_rdesign Healthy_if Pi_iff mem_Collect_eq type_F)
    qed
    also have "... = P(Q) \<turnstile>\<^sub>r post\<^sub>D(F(P(Q) \<turnstile>\<^sub>r Q))"
    proof -
      have "mono (\<lambda>X. pre\<^sub>D(F (X \<turnstile>\<^sub>r Q)))"
        by (simp add: monoI mono_pre_F)
      hence "pre\<^sub>D(F(P(Q) \<turnstile>\<^sub>r Q)) = P(Q)"
        using P_is_pre by auto
      thus ?thesis by simp
    qed
    also have "... = P(Q) \<turnstile>\<^sub>r (P(Q) \<Rightarrow> post\<^sub>D(F(P(Q) \<turnstile>\<^sub>r Q)))"
      by (rel_auto)
    also have "... = P(Q) \<turnstile>\<^sub>r Q"
    proof -
      have "mono (\<lambda>Y. P Y \<Rightarrow> post\<^sub>D(F (P Y \<turnstile>\<^sub>r Y)))"
        by (simp add: P_antitone impl_refine_intro monoI mono_post_F)
      hence "(P(Q) \<Rightarrow> post\<^sub>D(F(P(Q) \<turnstile>\<^sub>r Q))) = Q"
        using Q_def gfp_fixpoint by auto
      thus ?thesis
        by simp
    qed
    finally show ?thesis .
  qed

end
  
theorem rdesign_mu_wf_refine_intro: 
  assumes   WF: "wf R"
    and      M: "Monotonic F"
    and      H: "F \<in> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H"
    and  induct_step:
    "\<And>st. (P \<and> \<lceil>e\<rceil>\<^sub>< =\<^sub>u \<guillemotleft>st\<guillemotright>) \<turnstile>\<^sub>r Q \<sqsubseteq> F ((P \<and> (\<lceil>e\<rceil>\<^sub><, \<guillemotleft>st\<guillemotright>)\<^sub>u \<in>\<^sub>u \<guillemotleft>R\<guillemotright>) \<turnstile>\<^sub>r Q)"
  shows "(P \<turnstile>\<^sub>r Q) \<sqsubseteq> \<mu>\<^sub>D F"            
proof -          
  {
  fix st
  have "(P \<and> \<lceil>e\<rceil>\<^sub>< =\<^sub>u \<guillemotleft>st\<guillemotright>) \<turnstile>\<^sub>r Q \<sqsubseteq> \<mu>\<^sub>D F" 
  using WF proof (induction rule: wf_induct_rule)
    case (less st)
    hence 0: "(P \<and> (\<lceil>e\<rceil>\<^sub><, \<guillemotleft>st\<guillemotright>)\<^sub>u \<in>\<^sub>u \<guillemotleft>R\<guillemotright>) \<turnstile>\<^sub>r Q \<sqsubseteq> \<mu>\<^sub>D F"
      by rel_blast
    from M H design_theory_continuous.LFP_lemma3 mono_Monotone_utp_order
    have 1: "\<mu>\<^sub>D F \<sqsubseteq>  F (\<mu>\<^sub>D F)"
      by blast
    from 0 1 have 2:"(P \<and> (\<lceil>e\<rceil>\<^sub><,\<guillemotleft>st\<guillemotright>)\<^sub>u\<in>\<^sub>u\<guillemotleft>R\<guillemotright>) \<turnstile>\<^sub>r Q \<sqsubseteq> F (\<mu>\<^sub>D F)"
      by simp
    have 3: "F ((P \<and> (\<lceil>e\<rceil>\<^sub><, \<guillemotleft>st\<guillemotright>)\<^sub>u \<in>\<^sub>u \<guillemotleft>R\<guillemotright>) \<turnstile>\<^sub>r Q) \<sqsubseteq> F (\<mu>\<^sub>D F)"
      by (simp add: 0 M monoD)
    have 4:"(P \<and> \<lceil>e\<rceil>\<^sub>< =\<^sub>u \<guillemotleft>st\<guillemotright>) \<turnstile>\<^sub>r Q \<sqsubseteq> \<dots>" 
      by (rule induct_step)
    show ?case
      using order_trans[OF 3 4] H M design_theory_continuous.LFP_lemma2 dual_order.trans mono_Monotone_utp_order 
      by blast
  qed
  }
  thus ?thesis
    by (pred_simp)
qed  

theorem ndesign_mu_wf_refine_intro': 
  assumes   WF: "wf R"
    and      M: "Monotonic F"
    and      H: "F \<in> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H"
    and  induct_step:
    "\<And>st. ((p \<and> e =\<^sub>u \<guillemotleft>st\<guillemotright>) \<turnstile>\<^sub>n Q) \<sqsubseteq> F ((p \<and> (e, \<guillemotleft>st\<guillemotright>)\<^sub>u \<in>\<^sub>u \<guillemotleft>R\<guillemotright>) \<turnstile>\<^sub>n Q)"
  shows "(p \<turnstile>\<^sub>n Q) \<sqsubseteq> \<mu>\<^sub>D F"
  using assms unfolding ndesign_def
  by (rule_tac rdesign_mu_wf_refine_intro[of R F "\<lceil>p\<rceil>\<^sub><" e], simp_all add: alpha)

theorem ndesign_mu_wf_refine_intro: 
  assumes   WF: "wf R"
    and      M: "Monotonic F"
    and      H: "F \<in> \<lbrakk>\<^bold>N\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>N\<rbrakk>\<^sub>H"
    and  induct_step:
    "\<And>st. ((p \<and> e =\<^sub>u \<guillemotleft>st\<guillemotright>) \<turnstile>\<^sub>n Q) \<sqsubseteq> F ((p \<and> (e, \<guillemotleft>st\<guillemotright>)\<^sub>u \<in>\<^sub>u \<guillemotleft>R\<guillemotright>) \<turnstile>\<^sub>n Q)"
  shows "(p \<turnstile>\<^sub>n Q) \<sqsubseteq> \<^bold>\<mu>\<^bsub>NDES\<^esub> F"
proof -          
  {
  fix st
  have "(p \<and> e =\<^sub>u \<guillemotleft>st\<guillemotright>) \<turnstile>\<^sub>n Q \<sqsubseteq> \<^bold>\<mu>\<^bsub>NDES\<^esub> F" 
  using WF proof (induction rule: wf_induct_rule)
    case (less st)
    hence 0: "(p \<and> (e, \<guillemotleft>st\<guillemotright>)\<^sub>u \<in>\<^sub>u \<guillemotleft>R\<guillemotright>) \<turnstile>\<^sub>n Q \<sqsubseteq> \<^bold>\<mu>\<^bsub>NDES\<^esub> F"
      by rel_blast
    from M H design_theory_continuous.LFP_lemma3 mono_Monotone_utp_order
    have 1: "\<^bold>\<mu>\<^bsub>NDES\<^esub> F \<sqsubseteq>  F (\<^bold>\<mu>\<^bsub>NDES\<^esub> F)"
      by (simp add: mono_Monotone_utp_order normal_design_theory_continuous.LFP_lemma3)
    from 0 1 have 2:"(p \<and> (e, \<guillemotleft>st\<guillemotright>)\<^sub>u\<in>\<^sub>u\<guillemotleft>R\<guillemotright>) \<turnstile>\<^sub>n Q \<sqsubseteq> F (\<^bold>\<mu>\<^bsub>NDES\<^esub> F)"
      by simp
    have 3: "F ((p \<and> (e, \<guillemotleft>st\<guillemotright>)\<^sub>u \<in>\<^sub>u \<guillemotleft>R\<guillemotright>) \<turnstile>\<^sub>n Q) \<sqsubseteq> F (\<^bold>\<mu>\<^bsub>NDES\<^esub> F)"
      by (simp add: 0 M monoD)
    have 4:"(p \<and> e =\<^sub>u \<guillemotleft>st\<guillemotright>) \<turnstile>\<^sub>n Q \<sqsubseteq> \<dots>" 
      by (rule induct_step)
    show ?case
      using order_trans[OF 3 4] H M normal_design_theory_continuous.LFP_lemma2 dual_order.trans mono_Monotone_utp_order 
      by blast
  qed
  }
  thus ?thesis
    by (pred_simp)
qed  

subsection {* Normal Designs Proof Tactics *}
  
named_theorems ND_elim
  
lemma ndes_elim: "\<lbrakk> P is \<^bold>N; Q(\<lfloor>pre\<^sub>D(P)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P)) \<rbrakk> \<Longrightarrow> Q(P)"
  by (simp add: ndesign_form)

lemma ndes_ind_elim: "\<lbrakk> \<And> i. P i is \<^bold>N; Q(\<lambda> i. \<lfloor>pre\<^sub>D(P i)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P i)) \<rbrakk> \<Longrightarrow> Q(P)"
  by (simp add: ndesign_form)
    
lemma ndes_split [ND_elim]: "\<lbrakk> P is \<^bold>N; \<And> pre post. Q(pre \<turnstile>\<^sub>n post) \<rbrakk> \<Longrightarrow> Q(P)"
  by (metis H1_H2_eq_rdesign H1_H3_impl_H2 H3_unrest_out_alpha Healthy_def drop_pre_inv ndesign_def)
    
method ndes_expand uses cls = (insert cls, (erule ND_elim)+)
  
method ndes_simp uses cls =
  ((ndes_expand cls: cls)?, (simp add: ndes_simp closure alpha usubst unrest wp prod.case_eq_if))

method ndes_refine uses cls =
  (ndes_simp cls: cls; rule_tac ndesign_refine_intro; (insert cls; rel_simp; auto?))

method ndes_eq uses cls =
  (ndes_simp cls: cls; rule_tac antisym; rule_tac ndesign_refine_intro; (insert cls; rel_simp; auto?))

subsection {* Alternation *}
  
definition GrdCommD :: "'\<alpha> upred \<Rightarrow> ('\<alpha>, '\<beta>) rel_des \<Rightarrow> ('\<alpha>, '\<beta>) rel_des" ("_ \<rightarrow>\<^sub>D _" [85, 86] 85) where
[upred_defs]: "b \<rightarrow>\<^sub>D P = P \<triangleleft> b \<triangleright>\<^sub>D \<top>\<^sub>D"

lemma GrdCommD_ndes_simp [ndes_simp]:
  "b \<rightarrow>\<^sub>D (p\<^sub>1 \<turnstile>\<^sub>n P\<^sub>2) = ((b \<Rightarrow> p\<^sub>1) \<turnstile>\<^sub>n (\<lceil>b\<rceil>\<^sub>< \<and> P\<^sub>2))"
  by (rel_auto)

lemma GrdCommD_H1_H3_closed [closure]: "P is \<^bold>N \<Longrightarrow> b \<rightarrow>\<^sub>D P is \<^bold>N"
  by (simp add: GrdCommD_def closure)

lemma GrdCommD_true [simp]: "true \<rightarrow>\<^sub>D P = P"
  by (rel_auto)
    
lemma GrdCommD_false [simp]: "false \<rightarrow>\<^sub>D P = \<top>\<^sub>D"
  by (rel_auto)
  
lemma GrdCommD_abort [simp]: "b \<rightarrow>\<^sub>D true = ((\<not> b) \<turnstile>\<^sub>n false)"
  by (rel_auto)
    
consts
  ualtern       :: "'a set \<Rightarrow> ('a \<Rightarrow> 'p) \<Rightarrow> ('a \<Rightarrow> 'r) \<Rightarrow> 'r \<Rightarrow> 'r"
  ualtern_list  :: "('a \<times> 'r) list \<Rightarrow> 'r \<Rightarrow> 'r"
  
definition AlternateD :: "'a set \<Rightarrow> ('a \<Rightarrow> '\<alpha> upred) \<Rightarrow> ('a \<Rightarrow> ('\<alpha>, '\<beta>) rel_des) \<Rightarrow> ('\<alpha>, '\<beta>) rel_des \<Rightarrow> ('\<alpha>, '\<beta>) rel_des" where
[upred_defs, ndes_simp]:
"AlternateD A g P Q = (\<Sqinter> i\<in>A \<bullet> g(i) \<rightarrow>\<^sub>D P(i)) \<sqinter> (\<And> i\<in>A \<bullet> \<not> g(i)) \<rightarrow>\<^sub>D Q"

text {* This lemma shows that our generalised alternation is the same operator as Marcel Oliveira's
  definition of alternation when the else branch is abort. *}

lemma AlternateD_abort_alternate:
  assumes "\<And> i. P(i) is \<^bold>N"
  shows
  "AlternateD A g P \<bottom>\<^sub>D = 
  ((\<Or> i\<in>A \<bullet> g(i)) \<and> (\<And> i\<in>A \<bullet> g(i) \<Rightarrow> \<lfloor>pre\<^sub>D(P i)\<rfloor>\<^sub><)) \<turnstile>\<^sub>n (\<Or> i\<in>A \<bullet> \<lceil>g(i)\<rceil>\<^sub>< \<and> post\<^sub>D(P i))"
proof (cases "A = {}")
  case False
  have "AlternateD A g P \<bottom>\<^sub>D = 
        (\<Sqinter> i\<in>A \<bullet> g(i) \<rightarrow>\<^sub>D (\<lfloor>pre\<^sub>D(P i)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P i))) \<sqinter> (\<And> i\<in>A \<bullet> \<not> g(i)) \<rightarrow>\<^sub>D (false \<turnstile>\<^sub>n true)"
    by (simp add: AlternateD_def ndesign_form bot_d_ndes_def assms)
  also have "... = ((\<Or> i\<in>A \<bullet> g(i)) \<and> (\<And> i\<in>A \<bullet> g(i) \<Rightarrow> \<lfloor>pre\<^sub>D(P i)\<rfloor>\<^sub><)) \<turnstile>\<^sub>n (\<Or> i\<in>A \<bullet> \<lceil>g(i)\<rceil>\<^sub>< \<and> post\<^sub>D(P i))"
    by (simp add: ndes_simp False, rel_auto)
  finally show ?thesis by simp
next
  case True
  thus ?thesis
    by (simp add: AlternateD_def, rel_auto)
qed
     
definition AlternateD_list :: "('\<alpha> upred \<times> ('\<alpha>, '\<beta>) rel_des) list \<Rightarrow> ('\<alpha>, '\<beta>) rel_des  \<Rightarrow> ('\<alpha>, '\<beta>) rel_des" where 
[upred_defs, ndes_simp]:
"AlternateD_list xs P = 
  AlternateD {0..<length xs} (\<lambda> i. map fst xs ! i) (\<lambda> i. map snd xs ! i) P"

adhoc_overloading
  ualtern AlternateD and
  ualtern_list AlternateD_list

nonterminal gcomm and gcomms
  
syntax
  "_altind_els"   :: "pttrn \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic" ("if _\<in>_ \<bullet> _ \<rightarrow> _ else _ fi")
  "_altind"       :: "pttrn \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic" ("if _\<in>_ \<bullet> _ \<rightarrow> _ fi")
  "_gcomm"        :: "logic \<Rightarrow> logic \<Rightarrow> gcomm" ("_ \<rightarrow> _" [65, 66] 65)
  "_gcomm_nil"    :: "gcomm \<Rightarrow> gcomms" ("_")
  "_gcomm_cons"   :: "gcomm \<Rightarrow> gcomms \<Rightarrow> gcomms" ("_ | _" [60, 61] 61)
  "_gcomm_show"   :: "logic \<Rightarrow> logic"
  "_altgcomm_els" :: "gcomms \<Rightarrow> logic \<Rightarrow> logic" ("if _ else _ fi")
  "_altgcomm"     :: "gcomms \<Rightarrow> logic" ("if _ fi")
  
translations
  "_altind_els x A g P Q" => "CONST ualtern A (\<lambda> x. g) (\<lambda> x. P) Q"
  "_altind_els x A g P Q" <= "CONST ualtern A (\<lambda> x. g) (\<lambda> x'. P) Q"
  "_altind x A g P" => "CONST ualtern A (\<lambda> x. g) (\<lambda> x. P) (CONST Orderings.top)"
  "_altind x A g P" <= "CONST ualtern A (\<lambda> x. g) (\<lambda> x'. P) (CONST Orderings.top)"
  "_altgcomm cs" => "CONST ualtern_list cs (CONST Orderings.top)"
  "_altgcomm (_gcomm_show cs)" <= "CONST ualtern_list cs (CONST Orderings.top)"
  "_altgcomm_els cs P" => "CONST ualtern_list cs P"
  "_altgcomm_els (_gcomm_show cs) P" <= "CONST ualtern_list cs P"

  "_gcomm g P" => "(g, P)"
  "_gcomm g P" <= "_gcomm_show (g, P)"
  "_gcomm_cons c cs" => "c # cs"
  "_gcomm_cons (_gcomm_show c) (_gcomm_show (d # cs))" <= "_gcomm_show (c # d # cs)"
  "_gcomm_nil c" => "[c]"
  "_gcomm_nil (_gcomm_show c)" <= "_gcomm_show [c]"
  
lemma AlternateD_H1_H3_closed [closure]: 
  assumes "\<And> i. i \<in> A \<Longrightarrow> P i is \<^bold>N" "Q is \<^bold>N"
  shows "if i\<in>A \<bullet> g(i) \<rightarrow> P(i) else Q fi is \<^bold>N"
proof (cases "A = {}")
  case True
  then show ?thesis
    by (simp add: AlternateD_def closure false_upred_def assms)
next
  case False
  then show ?thesis
    by (simp add: AlternateD_def closure assms)
qed

lemma false_sup [simp]: "false \<sqinter> P = P" "P \<sqinter> false = P"
  by (rel_auto)+

lemma true_inf [simp]: "true \<squnion> P = P" "P \<squnion> true = P"
  by (rel_auto)+
    
lemma AltD_ndes_simp [ndes_simp]: 
  "if i\<in>A \<bullet> g(i) \<rightarrow> (P\<^sub>1(i) \<turnstile>\<^sub>n P\<^sub>2(i)) else Q\<^sub>1 \<turnstile>\<^sub>n Q\<^sub>2 fi 
   = ((\<And> i \<in> A \<bullet> g i \<Rightarrow> P\<^sub>1 i) \<and> ((\<And> i \<in> A \<bullet> \<not> g i) \<Rightarrow> Q\<^sub>1)) \<turnstile>\<^sub>n
     ((\<Or> i \<in> A \<bullet> \<lceil>g i\<rceil>\<^sub>< \<and> P\<^sub>2 i) \<or> (\<And> i \<in> A \<bullet> \<not> \<lceil>g i\<rceil>\<^sub><) \<and> Q\<^sub>2)"
proof (cases "A = {}")
  case True
  then show ?thesis by (simp add: AlternateD_def)
next
  case False
  then show ?thesis
    by (simp add: ndes_simp, rel_auto)
qed
  
lemma UINF_pred_false [simp]: 
  "(\<Sqinter> i | false \<bullet> P(i)) = false"
  by (rel_auto)

declare UINF_upto_expand_first [ndes_simp]
declare UINF_Suc_shift [ndes_simp]
declare USUP_upto_expand_first [ndes_simp]
declare USUP_Suc_shift [ndes_simp]
declare true_upred_def [THEN sym, ndes_simp]
  
lemma AlternateD_mono_refine:
  assumes "\<And> i. P i \<sqsubseteq> Q i" "R \<sqsubseteq> S"
  shows "(if i\<in>A \<bullet> g(i) \<rightarrow> P(i) else R fi) \<sqsubseteq> (if i\<in>A \<bullet> g(i) \<rightarrow> Q(i) else S fi)"
  using assms by (rel_auto, meson)
  
lemma Monotonic_AlternateD [closure]:
  "\<lbrakk> \<And> i. Monotonic (F i); Monotonic G \<rbrakk> \<Longrightarrow> Monotonic (\<lambda> X. if i\<in>A \<bullet> g(i) \<rightarrow> F i X else G(X) fi)" 
  by (rel_auto, meson)
    
lemma AlternateD_empty:
  "if i\<in>{} \<bullet> g(i) \<rightarrow> P(i) else Q fi = Q"
  by (rel_auto)
    
lemma AlternateD_true_singleton:
  assumes "P is \<^bold>N"
  shows "if true \<rightarrow> P fi = P"
  by (ndes_simp cls: assms)

lemma AlernateD_singleton:
  assumes "P is \<^bold>N"
  shows "if b \<rightarrow> P fi = if i\<in>{0} \<bullet> b \<rightarrow> P fi"
  by (ndes_simp cls: assms)
    
lemma AlternateD_commute:
  assumes "P is \<^bold>N" "Q is \<^bold>N"
  shows "if g\<^sub>1 \<rightarrow> P | g\<^sub>2 \<rightarrow> Q fi = if g\<^sub>2 \<rightarrow> Q | g\<^sub>1 \<rightarrow> P fi"
  by (ndes_eq cls:assms)

lemma AlternateD_dcond:
  assumes "P is \<^bold>N" "Q is \<^bold>N"
  shows "if g \<rightarrow> P else Q fi = P \<triangleleft> g \<triangleright>\<^sub>D Q"
  by (ndes_eq cls:assms)

lemma AlternateD_cover:
  assumes "P is \<^bold>N" "Q is \<^bold>N"
  shows "if g \<rightarrow> P else Q fi = if g \<rightarrow> P | (\<not> g) \<rightarrow> Q fi"
  by (ndes_eq cls: assms)

lemma UINF_ndes_expand:
  assumes "\<And> i. i\<in>A \<Longrightarrow> P(i) is \<^bold>N"
  shows "(\<Sqinter> i \<in> A \<bullet> \<lfloor>pre\<^sub>D(P(i))\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P(i))) = (\<Sqinter> i \<in> A \<bullet> P(i))"
  by (rule UINF_cong, simp add: assms ndesign_form)

lemma USUP_ndes_expand:
  assumes "\<And> i. i\<in>A \<Longrightarrow> P(i) is \<^bold>N"
  shows "(\<Squnion> i \<in> A \<bullet> \<lfloor>pre\<^sub>D(P(i))\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P(i))) = (\<Squnion> i \<in> A \<bullet> P(i))"
  by (rule USUP_cong, simp add: assms ndesign_form)
    
lemma AlternateD_ndes_expand:
  assumes "\<And> i. i\<in>A \<Longrightarrow> P(i) is \<^bold>N" "Q is \<^bold>N"
  shows "if i\<in>A \<bullet> g(i) \<rightarrow> P(i) else Q fi =
         if i\<in>A \<bullet> g(i) \<rightarrow> (\<lfloor>pre\<^sub>D(P(i))\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P(i))) else \<lfloor>pre\<^sub>D(Q)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(Q) fi"
  apply (simp add: AlternateD_def)
  apply (subst UINF_ndes_expand[THEN sym])
  apply (simp add: assms closure)
  apply (ndes_simp cls: assms)
  apply (rel_auto)
done

lemma AlternateD_ndes_expand':
  assumes "\<And> i. i\<in>A \<Longrightarrow> P(i) is \<^bold>N"
  shows "if i\<in>A \<bullet> g(i) \<rightarrow> P(i) fi = if i\<in>A \<bullet> g(i) \<rightarrow> (\<lfloor>pre\<^sub>D(P(i))\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P(i))) fi"
  apply (simp add: AlternateD_def)
  apply (subst UINF_ndes_expand[THEN sym])
  apply (simp add: assms closure)
  apply (ndes_simp cls: assms)
  apply (rel_auto)
done

  
    
lemma ndesign_ind_form:
  assumes "\<And> i. P(i) is \<^bold>N"
  shows "(\<lambda> i. \<lfloor>pre\<^sub>D(P(i))\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P(i))) = P"
  by (simp add: assms ndesign_form)
    
lemma AlternateD_insert:
  assumes "\<And> i. i\<in>(insert x A) \<Longrightarrow> P(i) is \<^bold>N" "Q is \<^bold>N"
  shows "if i\<in>(insert x A) \<bullet> g(i) \<rightarrow> P(i) else Q fi = 
         if g(x) \<rightarrow> P(x) | 
            (\<Or> i\<in>A \<bullet> g(i)) \<rightarrow> if i\<in>A \<bullet> g(i) \<rightarrow> P(i) fi 
            else Q 
         fi" (is "?lhs = ?rhs")
proof -
  have "?lhs = if i\<in>(insert x A) \<bullet> g(i) \<rightarrow> (\<lfloor>pre\<^sub>D(P(i))\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P(i))) else (\<lfloor>pre\<^sub>D(Q)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(Q)) fi"
    using AlternateD_ndes_expand assms(1) assms(2) by blast
  also 
  have "... =
         if g(x) \<rightarrow> (\<lfloor>pre\<^sub>D(P(x))\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P(x))) | 
            (\<Or> i\<in>A \<bullet> g(i)) \<rightarrow> if i\<in>A \<bullet> g(i) \<rightarrow> \<lfloor>pre\<^sub>D(P(i))\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P(i)) fi 
            else \<lfloor>pre\<^sub>D(Q)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(Q)
         fi"
    by (ndes_simp cls:assms, rel_auto)
  also have "... = ?rhs"
    by (simp add: AlternateD_ndes_expand' ndesign_form assms)
  finally show ?thesis .
qed
   
lemma "\<lbrakk> P\<^sub>1 is \<^bold>N; P\<^sub>2 is \<^bold>N \<rbrakk> \<Longrightarrow> if g\<^sub>1 \<rightarrow> P\<^sub>1 | g\<^sub>2 \<rightarrow> P\<^sub>2 fi = undefined"
  apply (simp add: AlternateD_list_def atLeast0_lessThan_Suc)
  apply (subst AlternateD_insert)
    apply (auto simp add: AlternateD_insert closure)
oops
  
subsection {* Iteration *}

text {* Overloadable Syntax *}
  
consts
  uiterate       :: "'a set \<Rightarrow> ('a \<Rightarrow> 'p) \<Rightarrow> ('a \<Rightarrow> 'r) \<Rightarrow> 'r"
  uiterate_list  :: "('a \<times> 'r) list \<Rightarrow> 'r"

syntax
  "_iterind"       :: "pttrn \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic \<Rightarrow> logic" ("do _\<in>_ \<bullet> _ \<rightarrow> _ od")
  "_itergcomm"     :: "gcomms \<Rightarrow> logic" ("do _ od")
  
translations
  "_iterind x A g P" => "CONST uiterate A (\<lambda> x. g) (\<lambda> x. P)"
  "_iterind x A g P" <= "CONST uiterate A (\<lambda> x. g) (\<lambda> x'. P)"
  "_itergcomm cs" => "CONST uiterate_list cs"
  "_itergcomm (_gcomm_show cs)" <= "CONST uiterate_list cs"
  
definition IterateD :: "'a set \<Rightarrow> ('a \<Rightarrow> '\<alpha> upred) \<Rightarrow> ('a \<Rightarrow> '\<alpha> hrel_des) \<Rightarrow> '\<alpha> hrel_des" where
[upred_defs, ndes_simp]:
"IterateD A g P = (\<^bold>\<mu>\<^bsub>NDES\<^esub> X \<bullet> if i\<in>A \<bullet> g(i) \<rightarrow> P(i) ;; X else II\<^sub>D fi)"

definition IterateD_list :: "('\<alpha> upred \<times> '\<alpha> hrel_des) list \<Rightarrow> '\<alpha> hrel_des" where 
[upred_defs, ndes_simp]:
"IterateD_list xs = IterateD {0..<length xs} (\<lambda> i. fst (nth xs i)) (\<lambda> i. snd (nth xs i))"

adhoc_overloading
  uiterate IterateD and
  uiterate_list IterateD_list
  
lemma IterateD_H1_H3_closed [closure]: 
  assumes "\<And> i. i \<in> A \<Longrightarrow> P i is \<^bold>N"
  shows "do i\<in>A \<bullet> g(i) \<rightarrow> P(i) od is \<^bold>N"
proof (cases "A = {}")
  case True
  then show ?thesis
    by (simp add: IterateD_def closure assms)
next
  case False
  then show ?thesis
    by (simp add: IterateD_def closure assms)
qed

lemma IterateD_empty:
  "do i\<in>{} \<bullet> g(i) \<rightarrow> P(i) od = II\<^sub>D"
  by (simp add: IterateD_def AlternateD_empty normal_design_theory_continuous.LFP_const skip_d_is_H1_H3)

lemma IterateD_list_single_expand:
  "do b \<rightarrow> P od = (\<^bold>\<mu>\<^bsub>NDES\<^esub> X \<bullet> if b \<rightarrow> P ;; X else II\<^sub>D fi)"
oops
    
lemma IterateD_singleton:
  "do b \<rightarrow> P od = do i\<in>{0} \<bullet> b \<rightarrow> P od"
  apply (simp add: IterateD_list_def IterateD_def)
oops

lemma IterateD_mono_refine:
  assumes 
    "\<And> i. P i is \<^bold>N" "\<And> i. Q i is \<^bold>N"
    "\<And> i. P i \<sqsubseteq> Q i"
  shows "(do i\<in>A \<bullet> g(i) \<rightarrow> P(i) od) \<sqsubseteq> (do i\<in>A \<bullet> g(i) \<rightarrow> Q(i) od)"
  apply (simp add: IterateD_def normal_design_theory_continuous.utp_lfp_def)
  apply (subst normal_design_theory_continuous.utp_lfp_def)
  apply (simp_all add: closure assms)
  apply (subst normal_design_theory_continuous.utp_lfp_def)
  apply (simp_all add: closure assms)
  apply (simp add: ndes_hcond_def)
  apply (rule gfp_mono)
  apply (rule AlternateD_mono_refine)
  apply (simp_all add: closure seqr_mono assms)
done

lemma IterateD_single_refine:
  assumes 
    "P is \<^bold>N" "Q is \<^bold>N" "P \<sqsubseteq> Q"
  shows "(do g \<rightarrow> P od) \<sqsubseteq> (do g \<rightarrow> Q od)"
oops
  
lemma IterateD_refine_intro:
  fixes V :: "(nat, 'a) uexpr"
  assumes "vwb_lens w"
  shows
  "I \<turnstile>\<^sub>n (w:[\<lceil>I \<and> \<not> (\<Or> i\<in>A \<bullet> g(i))\<rceil>\<^sub>>]) \<sqsubseteq> 
   do i\<in>A \<bullet> g(i) \<rightarrow> (I \<and> g(i)) \<turnstile>\<^sub>n (w:[\<lceil>I\<rceil>\<^sub>> \<and> \<lceil>V\<rceil>\<^sub>> <\<^sub>u \<lceil>V\<rceil>\<^sub><]) od"
proof (cases "A = {}")
  case True
  with assms show ?thesis
    by (simp add: IterateD_empty, rel_auto)
next
  case False
  then show ?thesis
  using assms
    apply (simp add: IterateD_def)
    apply (rule ndesign_mu_wf_refine_intro[where e=V and R="{(x, y). x < y}"])
    apply (simp_all add: wf closure)
    apply (simp add: ndes_simp unrest)
    apply (rule ndesign_refine_intro)
    apply (rel_auto)
    apply (rel_auto)
    apply (metis mwb_lens.put_put vwb_lens_mwb)
  done
qed
  
lemma IterateD_single_refine_intro:
  fixes V :: "(nat, 'a) uexpr"
  assumes "vwb_lens w"
  shows
  "I \<turnstile>\<^sub>n (w:[\<lceil>I \<and> \<not> g\<rceil>\<^sub>>]) \<sqsubseteq> 
   do g \<rightarrow> ((I \<and> g) \<turnstile>\<^sub>n (w:[\<lceil>I\<rceil>\<^sub>> \<and> \<lceil>V\<rceil>\<^sub>> <\<^sub>u \<lceil>V\<rceil>\<^sub><])) od"
  apply (rule order_trans)
  defer
  apply (rule IterateD_refine_intro[of w "{0}" "\<lambda> i. g" I V, simplified, OF assms(1)])
  apply (rel_auto)
done
  
subsection {* Let and Local Variables *}
  
definition LetD :: "('a, '\<alpha>) uexpr \<Rightarrow> ('a \<Rightarrow> '\<alpha> hrel_des) \<Rightarrow> '\<alpha> hrel_des" where
[upred_defs]: "LetD v P = (P x)\<lbrakk>x \<rightarrow> \<lceil>v\<rceil>\<^sub>D\<^sub><\<rbrakk>"

syntax
  "_LetD"       :: "[letbinds, 'a] \<Rightarrow> 'a"                ("(let\<^sub>D (_)/ in (_))" [0, 10] 10)

translations
  "_LetD (_binds b bs) e"  \<rightleftharpoons> "_LetD b (_LetD bs e)"
  "let\<^sub>D x = a in e"        \<rightleftharpoons> "CONST LetD a (\<lambda>x. e)"

lemma LetD_ndes_simp [ndes_simp]: 
  "LetD v (\<lambda> x. p(x) \<turnstile>\<^sub>n Q(x)) = (p(x)\<lbrakk>x \<rightarrow> v\<rbrakk>) \<turnstile>\<^sub>n (Q(x)\<lbrakk>x \<rightarrow> \<lceil>v\<rceil>\<^sub><\<rbrakk>)"
  by (rel_auto)
    
lemma LetD_H1_H3_closed [closure]:
  "\<lbrakk> \<And> x. P(x) is \<^bold>N \<rbrakk> \<Longrightarrow> LetD v P is \<^bold>N"
  by (rel_auto)
  
alphabet 'l dlocal =
  dlocal :: "'l"
  
definition map_dlocal ::
  "('\<sigma> \<Rightarrow> '\<tau>) \<Rightarrow>
   ('\<sigma>, '\<alpha>) dlocal_scheme \<Rightarrow> ('\<tau>, '\<alpha>) dlocal_scheme" where
[lens_defs]: "map_dlocal f = (\<lambda>r. \<lparr>dlocal\<^sub>v = f (dlocal\<^sub>v r), \<dots> = more r\<rparr>)"

definition map_dlocal_lens ::
  "('\<sigma> \<Longrightarrow> '\<psi>) \<Rightarrow>
   ('\<sigma>, '\<alpha>) dlocal_scheme des \<Longrightarrow> ('\<psi>, '\<alpha>) dlocal_scheme des" ("map'_dlocal\<^sub>L") where
[lens_defs]:
"map_dlocal_lens l = lmap\<^sub>D \<lparr>
  lens_get = map_dlocal (get\<^bsub>l\<^esub>),
  lens_put = map_dlocal o (put\<^bsub>l\<^esub>) o dlocal\<^sub>v\<rparr>"
    
definition vlocal_d :: "(('l \<Longrightarrow> ('l, 's) dlocal_ext) \<Rightarrow> ('l, 's) dlocal_ext hrel_des) \<Rightarrow> (unit, 's) dlocal_ext hrel_des" where
[upred_defs]: "vlocal_d f = rel_ares (f dlocal) (map_dlocal\<^sub>L 0\<^sub>L)"
  
definition case_prod_lens :: "(('a \<Longrightarrow> '\<alpha>) \<Rightarrow> ('b \<Longrightarrow> '\<alpha>) \<Rightarrow> 'c) \<Rightarrow> (('a \<times> 'b \<Longrightarrow> '\<alpha>) \<Rightarrow> 'c)" where
"case_prod_lens P x = P (fst\<^sub>L ;\<^sub>L x) (snd\<^sub>L ;\<^sub>L x)"

nonterminal lpttrn and lpttrns

syntax
  (* This is an abstraction binder for functions that take lenses as arguments. *)
  "_Labs"      :: "lpttrn \<Rightarrow> logic \<Rightarrow> logic"        ("\<L> _ . _" [0, 10] 10)
  "_lid"        :: "id \<Rightarrow> lpttrn"                    ("_")
  "_lcoerce"    :: "id \<Rightarrow> type \<Rightarrow> lpttrn"             ("_ :: _")
  "_lpattern"   :: "lpttrn \<Rightarrow> lpttrns \<Rightarrow> lpttrn"    ("'(_,/ _')")
  "_lpatnil"    :: "lpttrn \<Rightarrow> lpttrns"              ("_")
  "_lpatterns"  :: "lpttrn \<Rightarrow> lpttrns \<Rightarrow> lpttrns"  ("_,/ _")
  
translations
  "_abs (_lid x) P" => "_abs x P"
  "_abs (_lcoerce x t) P" => "_abs (_constrain x (_uvar_ty t)) P"
  "_Labs (_lpatnil x) P" => "_abs x P"
  "_Labs (_lpattern x y) P" \<rightleftharpoons> "CONST case_prod_lens (_abs x (_Labs y P))"
  "_Labs (_lpatterns x y) P" => "_Labs (_lpattern x y) P"
  "_Labs x P" => "_abs x P"
  "\<L> (x, y) . P" <= "CONST case_prod_lens (_Labs x (_Labs y P))"
  "\<L> (x, y) . P" <= "\<L> x . \<L> y . P" 
    
syntax
  "_dcl_d"       :: "lpttrns \<Rightarrow> logic \<Rightarrow> logic" ("dcl\<^sub>D _ \<bullet> _" [0, 10] 10)
  
translations
  "_dcl_d ds P" \<rightleftharpoons> "CONST vlocal_d (_Labs ds P)"
  
term "dcl\<^sub>D x :: int \<bullet> x :=\<^sub>D 1"
    
subsection {* Deep Local Variables *}

definition des_local_state :: 
  "'a::countable itself \<Rightarrow> ((nat, 's) local_scheme des, 's, nat, 'a::countable) local_prim" where
  "des_local_state t = \<lparr> sstate = \<Sigma>\<^sub>D, sassigns = assigns_d, inj_local = nat_inj_univ \<rparr>"
  
syntax
  "_des_local_state_type" :: "type \<Rightarrow> logic" ("\<L>\<^sub>D[_]")
  "_des_var_scope_type" :: "id \<Rightarrow> type \<Rightarrow> logic \<Rightarrow> logic" ("var\<^sub>D _ :: _ \<bullet> _" [0, 0, 10] 10)
  
translations
  "\<L>\<^sub>D['a]" == "CONST des_local_state TYPE('a)"
  "_des_var_scope_type x t P" => "_var_scope_type (_des_local_state_type t) x t P"
  "var\<^sub>D x :: 'a \<bullet> P" <= "var[\<L>\<^sub>D['a]] x \<bullet> P"
  
lemma get_rel_local [lens_defs]:
  "get\<^bsub>\<^bold>s\<^bsub>\<L>\<^sub>D['a::countable]\<^esub>\<^esub> = get\<^bsub>\<Sigma>\<^sub>D\<^esub>"
  by (simp add: des_local_state_def)
    
lemma des_local_state [simp]: "utp_local_state \<L>\<^sub>D['a::countable]"
  by (unfold_locales, simp_all add: upred_defs assigns_comp des_local_state_def, rel_auto)
     (metis local.cases_scheme)
     
lemma sassigns_des_state [simp]: "\<^bold>\<langle>\<sigma>\<^bold>\<rangle>\<^bsub>\<L>\<^sub>D['a::countable]\<^esub> = \<langle>\<sigma>\<rangle>\<^sub>D"
  by (simp add: des_local_state_def)

lemma des_var_open_H1_H3_closed [closure]:
  "open[\<L>\<^sub>D['a::countable]] is \<^bold>N"
  by (simp add: utp_local_state.var_open_def closure)

lemma des_var_close_H1_H3_closed [closure]:
  "close[\<L>\<^sub>D['a::countable]] is \<^bold>N"
  by (simp add: utp_local_state.var_close_def closure)  
   
lemma unrest_ok_vtop_des [unrest]: "ok \<sharp> top[\<L>\<^sub>D['a::countable]]"
  by (simp add: utp_local_state.top_var_def, simp add: des_local_state_def  unrest)
    
lemma msubst_H1_H3_closed [closure]:
  "\<lbrakk> $ok \<sharp> v; out\<alpha> \<sharp> v; (\<And>x. P x is \<^bold>N) \<rbrakk> \<Longrightarrow> (P(x)\<lbrakk>x\<rightarrow>v\<rbrakk>) is \<^bold>N"
  by (rel_auto, metis+)
  
lemma var_block_H1_H3_closed [closure]:
  "(\<And>x. P x is \<^bold>N) \<Longrightarrow> \<V>[\<L>\<^sub>D['a::countable], P] is \<^bold>N"
  by (simp add: utp_local_state.var_scope_def closure unrest)

lemma inj_local_rel [simp]: "inj_local R\<^sub>l = \<U>\<^sub>\<nat>"
  by (simp add: rel_local_state_def)
    
lemma sstate_rel [simp]: "\<^bold>s\<^bsub>R\<^sub>l\<^esub> = 1\<^sub>L"
  by (simp add: rel_local_state_def)

lemma inj_local_des [simp]: 
  "inj_local \<L>\<^sub>D['a::countable] = \<U>\<^sub>\<nat>"
  by (simp add: des_local_state_def)
  
lemma sstate_des [simp]: "\<^bold>s\<^bsub>\<L>\<^sub>D['a::countable]\<^esub> = \<Sigma>\<^sub>D"
  by (simp add: des_local_state_def)
      
lemma ndesign_msubst_top [usubst]:
  "(p x \<turnstile>\<^sub>n Q x)\<lbrakk>x\<rightarrow>\<lceil>top[\<L>\<^sub>D['a::countable]]\<rceil>\<^sub><\<rbrakk> = ((p x)\<lbrakk>x\<rightarrow>top[R\<^sub>l['a]]\<rbrakk> \<turnstile>\<^sub>n (Q x)\<lbrakk>x\<rightarrow>\<lceil>top[R\<^sub>l['a]]\<rceil>\<^sub><\<rbrakk>)"
  by (rel_auto')
          
text {* First attempt at a law for expanding design variable blocks. Far from adequate at the
  moment though. *}
    
lemma ndesign_local_expand_1 [ndes_simp]:
  "(var\<^sub>D x :: 'a :: countable \<bullet> p(x) \<turnstile>\<^sub>n Q(x)) =
       (\<Squnion> v \<bullet> (p x)\<lbrakk>x\<rightarrow>top[R\<^sub>l]\<rbrakk>\<lbrakk>&store ^\<^sub>u \<langle>\<guillemotleft>v\<guillemotright>\<rangle>/store\<rbrakk>) \<turnstile>\<^sub>n
       (\<Sqinter> v \<bullet> store := &store ^\<^sub>u \<langle>\<guillemotleft>v\<guillemotright>\<rangle> ;; (Q x)\<lbrakk>x\<rightarrow>\<lceil>top[R\<^sub>l]\<rceil>\<^sub><\<rbrakk> ;; store := (front\<^sub>u(&store) \<triangleleft> 0 <\<^sub>u #\<^sub>u(&store) \<triangleright> &store))"
  apply (simp add: utp_local_state.var_scope_def utp_local_state.var_open_def utp_local_state.var_close_def seq_UINF_distr' usubst)
  apply (simp add: ndes_simp wp unrest)
  apply (rel_auto')
done
    
end