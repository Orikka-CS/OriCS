--할로위즈 퓨전
local m=18452741
local cm=_G["c"..m]
function cm.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","G")
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetCountLimit(1,m+1)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
cm.listed_series={0x2d2,0x12d2}
function cm.tfil11(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial()
end
function cm.tfil12(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x2d2) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,chkf)
end
function cm.tfun1(g)
	local res=0
	for i=0,31 do
		local att=1<<i
		if g:IsExists(Card.IsAttribute,1,nil,att) then
			res=res+1
		end
	end
	return res
end
function cm.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		local mg2=Duel.GMFaceupGroup(Card.IsCanBeFusionMaterial,tp,0,"M",nil)
		mg1:Merge(mg2)
		local g=Duel.GMFaceupGroup(nil,tp,"M","M",nil)
		if cm.tfun1(g)>2 then
			local mg3=Duel.GMGroup(cm.tfil11,tp,"D",0,nil)
			mg1:Merge(mg3)
		end
		local res=Duel.IEMCard(cm.tfil12,tp,"E",0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce then
				local fgroup=ce:GetTarget()
				local mg4=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IEMCard(cm.tfil12,tp,"E",0,1,nil,e,tp,mg4,mf,chkf)
			end
		end
		return res
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"E")
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsNotImmuneToEffect,nil,e)
	local mg2=Duel.GMFaceupGroup(Card.IsCanBeFusionMaterial,tp,0,"M",nil)
	mg1:Merge(mg2)
	local g=Duel.GMFaceupGroup(nil,tp,"M","M",nil)
	if cm.tfun1(g)>2 then
		local mg3=Duel.GMGroup(cm.tfil11,tp,"D",0,nil)
		mg1:Merge(mg3)
	end
	local sg1=Duel.GMGroup(cm.tfil12,tp,"E",0,nil,e,tp,mg1,nil,chkf)
	local mg4=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:Getvalue()
		sg2=Duel.GMGroup(cm.tfil12,tp,"E",0,nil,e,tp,mg4,mf,chkf)
	end
	if #sg1>0 or (sg2 and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then
			sg:Merge(sg2)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (not sg2 or not sg2:IsContains(tc)
			or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat)
			local omat=mat:Filter(Card.IsControler,nil,1-tp)
			mat:Sub(omat)
			local dmat=mat:Filter(Card.IsLoc,nil,"D")
			mat:Sub(dmat)
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.Remove(dmat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			local oc=omat:GetFirst()
			while oc do
				local e1=MakeEff(c,"S")
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
				e1:SetValue(0)
				oc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
				oc:RegisterEffect(e2)
				oc=omat:GetNext()
			end
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			Duel.BreakEffect()
			local oc=omat:GetFirst()
			while oc do
				local e3=MakeEff(c,"S")
				e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetReset(RESET_EVENT+0x1fe0000)
				e3:SetValue(1)
				oc:RegisterEffect(e3)
				oc=omat:GetNext()
			end
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg4,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
function cm.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
	end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function cm.tfil21(c)
	return c:IsLoc("O") and c:IsAbleToRemove()
end
function cm.tfil22(c)
	return c:IsCanBeFusionMaterial() and (c:IsLoc("M") or c:IsAbleToRemove())
		 and c:IsType(TYPE_MONSTER)
end
function cm.tfil23(c)
	return c:IsSetCard(0x2d2) and c:IsCanBeFusionMaterial() and c:IsAbleToHand()
end
function cm.tfil24(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x12d2) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,chkf)
end
function cm.tfun21(g)
	local res=0
	for i=0,31 do
		local att=1<<i
		if g:IsExists(Card.IsAttribute,1,nil,att) then
			res=res+1
		end
	end
	return res
end
function cm.tfun22(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x12d2)
end
function cm.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		mg1=mg1:Filter(cm.tfil21,nil)
		local mg2=Duel.GMFaceupGroup(cm.tfil22,tp,"G","MG",nil)
		mg1:Merge(mg2)
		local g=Duel.GMFaceupGroup(nil,tp,"M","M",nil)
		if cm.tfun21(g)>2 then
			local mg3=Duel.GMGroup(cm.tfil23,tp,"R",0,nil)
			mg1:Merge(mg3)
		end
		aux.FCheckAdditional=cm.tfun22
		Fusion.CheckAdditional=cm.tfun22
		local res=Duel.IEMCard(cm.tfil24,tp,"E",0,1,nil,e,tp,mg1,nil,chkf)
		aux.FCheckAdditional=nil
		Fusion.CheckAdditional=nil
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce then
				local fgroup=ce:GetTarget()
				local mg4=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IEMCard(cm.tfil23,tp,"E",0,1,nil,e,tp,mg4,mf,chkf)
			end
		end
		return res
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"E")
	Duel.SOI(0,CATEGORY_REMOVE,nil,0,0,"G")
end
function cm.ofil2(c,p)
	return c:IsLoc("M") and c:IsControler(p)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsNotImmuneToEffect,nil,e)
	mg1=mg1:Filter(cm.tfil21,nil)
	local mg2=Duel.GMFaceupGroup(cm.tfil22,tp,"G","MG",nil)
	mg1:Merge(mg2)
	local g=Duel.GMFaceupGroup(nil,tp,"M","M",nil)
	if cm.tfun21(g)>2 then
		local mg3=Duel.GMGroup(cm.tfil23,tp,"R",0,nil)
		mg1:Merge(mg3)
	end
	aux.FCheckAdditional=cm.tfun22
	Fusion.CheckAdditional=cm.tfun22
	local sg1=Duel.GMGroup(cm.tfil24,tp,"E",0,nil,e,tp,mg1,nil,chkf)
	local mg4=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:Getvalue()
		sg2=Duel.GMGroup(cm.tfil24,tp,"E",0,nil,e,tp,mg4,mf,chkf)
	end
	if #sg1>0 or (sg2 and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then
			sg:Merge(sg2)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (not sg2 or not sg2:IsContains(tc)
			or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			aux.FCheckAdditional=nil
			Fusion.CheckAdditional=nil
			tc:SetMaterial(mat)
			local omat=mat:Filter(cm.ofil2,nil,1-tp)
			mat:Sub(omat)
			local rmat=mat:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
			mat:Sub(rmat)
			Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.SendtoHand(rmat,nil,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.ConfirmCards(1-tp,rmat)
			local oc=omat:GetFirst()
			while oc do
				local e1=MakeEff(c,"S")
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
				e1:SetValue(0)
				oc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
				oc:RegisterEffect(e2)
				oc=omat:GetNext()
			end
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			Duel.BreakEffect()
			local oc=omat:GetFirst()
			while oc do
				local e3=MakeEff(c,"S")
				e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetReset(RESET_EVENT+0x1fe0000)
				e3:SetValue(1)
				oc:RegisterEffect(e3)
				oc=omat:GetNext()
			end
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg4,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end