--최종화
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.pfil1,1,1)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","MG")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.pfil1(c,lc,sumtype,tp)
	return c:IsType(TYPE_TUNER,lc,sumtype,tp) and c:IsLevelAbove(7) and not c:IsSummonableCard()
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.tfil1(c)
	return c:IsCode(18454037) and not c:IsForbidden()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocCount(tp,"S")>0
			and Duel.IEMCard(s.tfil1,tp,"DG",0,1,nil)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(tp,"S")<1 then
		return
	end
	local g=Duel.SMCard(tp,s.tfil1,tp,"DG",0,1,1,nil)
	local tc=g:GetFirst()
	local pos=POS_FACEUP_ATTACK
	if tc:IsSSetable() then
		pos=POS_ATTACK
	end
	local spos=Duel.SelectPosition(tp,tc,pos)
	if spos==POS_FACEUP_ATTACK then
		Duel.MoveToField(tc,tp,tp,LSTN("S"),POS_FACEUP,true)
	else
		Duel.SSet(tp,tc)
	end
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.cfil2(c)
	return c:IsType(TYPE_TUNER) and c:IsLevelAbove(7) and not c:IsSummonableCard() and c:IsAbleToRemoveAsCost()
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
	local rg=Group.CreateGroup()
	if c:IsReleasable() then
		rg:AddCard(c)
	end
	local rc=rg:GetFirst()
	while rc do
		local exc=rc
		local sg=Group.CreateGroup()
		Fusion.CheckAdditional=s.tfun2
		local mg1=Duel.GetFusionMaterial(tp)
		if exc then
			mg1:RemoveCard(exc)
		end
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
	Duel.Release(rg,REASON_COST)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"E")
end
function s.ofil2(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Group.CreateGroup()
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
	if sc:IsType(TYPE_FUSION) then
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