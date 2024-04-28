--하이텐션 하이틴
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","H")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetCL(1,id)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.val1(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
function s.cfil2(c)
	return c:IsType(TYPE_TUNER) and c:IsLevelAbove(7) and not c:IsSummonableCard() and not c:IsPublic()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsPublic() and Duel.IEMCard(s.cfil2,tp,"H",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SMCard(tp,s.cfil2,tp,"H",0,1,1,c)
	g:AddCard(c)
	Duel.ConfirmCards(1-tp,g)
end
function s.tfil21(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.tfil22(c,e,tp,mg,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil,chkf)
end
function s.tfil23(c)
	return c:IsType(TYPE_TUNER) and c:IsLevelAbove(7) and not c:IsSummonableCard()
end
function s.tfun2(tp,sg,fc)
	return sg:IsExists(s.tfil23,1,nil)
end
function s.tfil24(c,mg)
	return mg:IsExists(s.tfil25,1,nil,c)
end
function s.tfil25(c,syn)
	return syn:IsSynchroSummonable(c)
end
function s.tfil26(c,mg)
	return mg:IsExists(s.tfil27,1,nil,c)
end
function s.tfil27(c,xyz)
	return xyz:IsXyzSummonable(Group.FromCards(c))
end
function s.tfil28(c,mg)
	return mg:IsExists(s.tfil29,1,nil,c)
end
function s.tfil29(c,lnk)
	return lnk:IsLinkSummonable(Group.FromCards(c))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Group.CreateGroup()
	if Duel.GetLocCount(tp,"M")>0 then
		local sg1=Duel.GMGroup(s.tfil21,tp,"H",0,nil,e,tp)
		sg:Merge(sg1)
	end
	Fusion.CheckAdditional=s.tfun2
	local mg1=Duel.GetFusionMaterial(tp)
	local sg21=Duel.GMGroup(s.tfil22,tp,"E",0,nil,e,tp,mg1,nil,tp)
	sg:Merge(sg21)
	local ce=Duel.GetChainMaterial(tp)
	local mg2=nil
	local sg22=nil
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg22=Duel.GMGroup(s.tfil22,tp,"E",0,nil,e,tp,mg3,mf,tp)
		sg:Merge(sg22)
	end
	Fusion.CheckAdditional=nil
	local mg3=Duel.GMGroup(s.tfil23,tp,"M",0,nil)
	local sg3=Duel.GMGroup(s.tfil24,tp,"E",0,nil,mg3)
	sg:Merge(sg3)
	local sg4=Duel.GMGroup(s.tfil26,tp,"E",0,nil,mg3)
	sg:Merge(sg4)
	local sg5=Duel.GMGroup(s.tfil28,tp,"E",0,nil,mg3)
	sg:Merge(sg5)
	if chk==0 then
		return #sg>0
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"HE")
end
function s.ofil2(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Group.CreateGroup()
	if Duel.GetLocCount(tp,"M")>0 then
		local sg1=Duel.GMGroup(s.tfil21,tp,"H",0,nil,e,tp)
		sg:Merge(sg1)
	end
	Fusion.CheckAdditional=s.tfun2
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.ofil2,nil,e)
	local sg21=Duel.GMGroup(s.tfil22,tp,"E",0,nil,e,tp,mg1,nil,tp)
	sg:Merge(sg21)
	local ce=Duel.GetChainMaterial(tp)
	local mg2=nil
	local sg22=nil
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg22=Duel.GMGroup(s.tfil22,tp,"E",0,nil,e,tp,mg3,mf,tp)
		sg:Merge(sg22)
	end
	Fusion.CheckAdditional=nil
	local mg3=Duel.GMGroup(s.tfil23,tp,"M",0,nil)
	local sg3=Duel.GMGroup(s.tfil24,tp,"E",0,nil,mg3)
	sg:Merge(sg3)
	local sg4=Duel.GMGroup(s.tfil26,tp,"E",0,nil,mg3)
	sg:Merge(sg4)
	local sg5=Duel.GMGroup(s.tfil28,tp,"E",0,nil,mg3)
	sg:Merge(sg5)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if sc:IsLoc("H") then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	elseif sc:IsType(TYPE_FUSION) then
		Fusion.CheckAdditional=s.tfun2
		if sg21:IsContains(sc) and (sg22==nil or not sg22:IsContains(sc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,sc,mg1,nil,chkf)
			sc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,sc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,sc,mat2)
		end
		Fusion.CheckAdditional=nil
		sc:CompleteProcedure()
	elseif sc:IsType(TYPE_SYNCHRO) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local mc=mg3:FilterSelect(tp,s.tfil25,1,1,nil,sc):GetFirst()
		Duel.SynchroSummon(tp,sc,mc)
	elseif sc:IsType(TYPE_XYZ) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mc=mg3:FilterSelect(tp,s.tfil27,1,1,nil,sc):GetFirst()
		Duel.XyzSummon(tp,sc,Group.FromCards(mc))
	elseif sc:IsType(TYPE_LINK) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
		local mc=mg3:FilterSelect(tp,s.tfil29,1,1,nil,sc):GetFirst()
		Duel.LinkSummon(tp,sc,mc)
	end
end