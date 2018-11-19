theory utp_hyprog_ex
  imports utp_hyprog
begin

type_synonym gravs = "(real^3, unit) hybs_scheme"

abbreviation h :: "real \<Longrightarrow> gravs" where "h \<equiv> \<Pi>[0] ;\<^sub>L \<^bold>c"
abbreviation v :: "real \<Longrightarrow> gravs" where "v \<equiv> \<Pi>[Suc 0] ;\<^sub>L \<^bold>c"
abbreviation t :: "real \<Longrightarrow> gravs" where "t \<equiv> \<Pi>[Suc (Suc 0)] ;\<^sub>L \<^bold>c"

lemma dInv_grav_ex:
  "\<lbrace>[&v <\<^sub>P 0 \<and>\<^sub>P &h \<le>\<^sub>P 2]\<^sub>P\<rbrace>\<langle>der(h) = v, der(v) = -9.81\<rangle>\<lbrace>[&v <\<^sub>P 0 \<and>\<^sub>P &h \<le>\<^sub>P 2]\<^sub>P\<rbrace>\<^sub>u"
  apply (rule dCut_split)
   apply (rule dInv)
    apply (simp add: closure)
   apply (simp add: closure uderiv usubst fode_def mkuexpr alpha)
   apply (rel_auto)
  apply (simp)
  apply (rule dInv)
   apply (simp add: closure)
  apply (simp add: closure uderiv usubst fode_def mkuexpr alpha hyprop_pred_def)
  apply (rel_simp')
  done   

abbreviation "g \<equiv> - (981 / 10\<^sup>2)"

abbreviation 
  "BBall \<equiv> (\<langle>der(h) = v, der(v) = g, der(t) = 1 | (&h \<ge>\<^sub>u 0)\<rangle> ;;
            (if\<^sub>u (&h =\<^sub>u 0 \<and> &t >\<^sub>u 0)
              then v := (-0.8 * &v) ;; t := 0 
              else II))\<^sup>\<star>"

lemma hoare_iter: "\<lbrace>P\<rbrace>S\<lbrace>P\<rbrace>\<^sub>u \<Longrightarrow> \<lbrace>P\<rbrace>S\<^sup>\<star>\<lbrace>P\<rbrace>\<^sub>u"
  by (rel_simp', metis (mono_tags, lifting) mem_Collect_eq rtrancl_induct)

lemma "\<lbrace>[&v\<^sup>2 \<le>\<^sub>P 2*\<guillemotleft>g\<guillemotright>*(\<guillemotleft>H\<guillemotright>-&h) \<and>\<^sub>P 0 \<le>\<^sub>P \<guillemotleft>H\<guillemotright>]\<^sub>P\<rbrace> BBall \<lbrace>[&v\<^sup>2 \<le>\<^sub>P 2*\<guillemotleft>g\<guillemotright>*(\<guillemotleft>H\<guillemotright>-&h) \<and>\<^sub>P 0 \<le>\<^sub>P \<guillemotleft>H\<guillemotright>]\<^sub>P\<rbrace>\<^sub>u"
  apply (rule hoare_iter)
  apply (rule seq_hoare_invariant)
   apply (rule dInv)
    apply (simp add: closure)
   apply (simp add: closure uderiv usubst fode_def mkuexpr alpha)
  apply (rel_simp')
  oops

end