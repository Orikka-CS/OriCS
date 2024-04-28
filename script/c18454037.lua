--고스트 인 더 머신
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","S")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetCL(1,id)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo","S")
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	local e4=MakeEff(c,"FC","S")
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetLabelObject(e3)
	WriteEff(e4,4,"O")
	c:RegisterEffect(e4)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(c,REASON_COST)
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
		sg22=Duel.GMGroup(s.tfil22,tp,"E",0,nil,e,tp,mg2,mf,tp)
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
		sg22=Duel.GMGroup(s.tfil22,tp,"E",0,nil,e,tp,mg2,mf,tp)
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
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():Filter(s.ofil4,nil,e,tp)
	if chkc then
		return g:IsContains(chkc) and s.ofil4(chkc,e,tp)
	end
	if chk==0 then 
		Duel.ResetFlagEffect(tp,id)
		for tc in aux.Next(g) do
			tc:ResetFlagEffect(id)
		end
		return #g>0
	end
	if #g==1 then
		Duel.SetTargetCard(g:GetFirst())
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=g:Select(tp,1,1,nil)
		Duel.SetTargetCard(tc)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_REMOVE_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
		if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			return
		end
		local b1=tc:HasLevel()
		local b2=tc:IsLevelAbove(2)
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
		if not op then return end
		local val=op==1 and 1 or -1
		local e2=MakeEff(c,"S")
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(val)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.ofil4(c,e,tp)
	return c:IsType(TYPE_TUNER)
		and c:IsLoc("M") and c:IsFaceup() and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=eg:Filter(s.ofil4,nil,e,tp)
	if #tg>0 then
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then
			g:Clear()
		end
		g:Merge(tg)
		g:Remove(function(c)
			return c:GetFlagEffect(id)==0
		end,nil)
		e:GetLabelObject():SetLabelObject(g)
		if Duel.GetFlagEffect(tp,id)==0 then
			Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end
end