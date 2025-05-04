--바람이 불면 너가 떠올라
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","G")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetCL(1,id)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.val1(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.cfil2(c)
	return c:IsType(TYPE_TUNER) and c:IsLevelAbove(7) and not c:IsSummonableCard() and c:IsAbleToHandAsCost()
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
function s.tfil24(c,mg,sg)
	return mg:IsExists(s.tfil25,1,nil,c,sg)
end
function s.tfil25(c,syn,sg)
	return syn:IsSynchroSummonable(c,sg)
end
function s.tfil26(c,mg,sg)
	return mg:IsExists(s.tfil27,1,nil,c,sg)
end
function s.tfil27(c,xyz,sg)
	return xyz:IsXyzSummonable(Group.FromCards(c),sg)
end
function s.tfil28(c,mg,sg)
	return mg:IsExists(s.tfil29,1,nil,c,sg)
end
function s.tfil29(c,lnk,sg)
	return lnk:IsLinkSummonable(Group.FromCards(c),sg)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=Group.CreateGroup()
	local rg=Duel.GMGroup(s.cfil2,tp,"M",0,nil)
	local rc=rg:GetFirst()
	while rc do
		local exc=not rc:IsAbleToHandAsCost() and rc or nil
		local sg=Group.CreateGroup()
		if Duel.GetMZoneCount(tp,rc)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			sg:AddCard(c)
		end
		Fusion.CheckAdditional=s.tfun2
		local mg1=Duel.GetFusionMaterial(tp)
		if exc then
			mg1:RemoveCard(exc)
		end
		local mg11=Duel.GMGroup(s.ofil22,tp,"G",0,nil,e)
		mg1:Merge(mg11)
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
		local mg3=Duel.GMGroup(s.tfil23,tp,"M",0,rc)
		local mg4=Duel.GMGroup(nil,tp,"M",0,rc)
		local sg3=Duel.GMGroup(s.tfil24,tp,"E",0,nil,mg3,mg4)
		sg:Merge(sg3)
		local sg4=Duel.GMGroup(s.tfil26,tp,"E",0,nil,mg3,mg4)
		sg:Merge(sg4)
		local sg5=Duel.GMGroup(s.tfil28,tp,"E",0,nil,mg3,mg4)
		sg:Merge(sg5)
		if #sg>0 then
			tg:AddCard(rc)
		end
		rc=rg:GetNext()
	end
	if chk==0 then
		if e:GetLabel()~=10000 then
			return false
		end
		e:SetLabel(0)
		return #tg>0
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local og=rg:Select(tp,1,1,nil)
	Duel.SendtoHand(og,nil,REASON_COST)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,"E")
end
function s.ofil2(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Group.CreateGroup()
	if Duel.GetLocCount(tp,"M")>0 and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		local res=true
		local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then
				res=false
			end
		end
		if res then
			sg:AddCard(c)
		end
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
	if sc==c then
		Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_REMOVE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_TUNER)
		c:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
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