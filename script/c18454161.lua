--크리보슈라
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsLevel,1),3,nil,s.pfun1)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetCL(1,0,EFFECT_COUNT_CODE_SINGLE)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S")
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"F","M")
	e4:SetCode(EFFECT_REVERSE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTR(1,0)
	e4:SetValue(s.val4)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"F","G")
	e5:SetCode(EFFECT_EXTRA_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTR(1,0)
	e5:SetValue(s.val5)
	e5:SetOperation(s.op5)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"SC")
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	WriteEff(e6,6,"NO")
	c:RegisterEffect(e6)
end
function s.pfun1(g,lc,sumtype,tp)
	return g:FilterCount(Card.IsType,nil,TYPE_TUNER)==1
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.tfil11(c,e)
	return c:IsSetCard(0xa4) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.tfun1(g,e,tp)
	if #g==1 then
		local tc=g:GetFirst()
		return tc:IsAbleToHand()
	elseif #g>=2 then
		return g:IsExists(s.tfil12,1,nil,g,e,tp)
	end
	return false
end
function s.tfil12(c,g,e,tp)
	return c:IsAbleToHand() and
		(#g==1 or (Duel.GetLocCount(tp,"M")>0 and g:IsExists(Card.IsCanBeSpecialSummoned,1,c,e,0,tp,false,false)))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GMGroup(s.tfil11,tp,"R",0,nil,e)
	if chkc then
		return false
	end
	if chk==0 then
		return g:IsExists(Card.IsAbleToHand,1,nil)
	end
	local ct=3
	if #g<ct then
		ct=#g
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:SelectSubGroup(tp,s.tfun1,false,1,ct,e,tp)
	Duel.SetTargetCard(sg)
	Duel.SOI(0,CATEGORY_TOHAND,sg,1,0,0)
	if #sg>=2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
		Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=g:FilterSelect(tp,s.tfil12,1,1,nil,g,e,tp)
	if #g1>0 then
		Duel.HintSelection(g1)
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
	else
		return
	end
	g:Sub(g1)
	if Duel.GetLocCount(tp,"M")<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=g:FilterSelect(tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,tp,false,false)
	if #g2>0 then
		Duel.HintSelection(g2)
		Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
	else
		return
	end
	g:Sub(g2)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
function s.tfun2(g)
	return g:GetClassCount(s.tval2)==#g
end
function s.tval2(c)
	if c:IsOnField() then
		return LOCATION_ONFIELD
	end
	return c:GetLocation()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=#(c:GetMutualLinkedGroup():Filter(Card.IsMonster,nil))
	local g=Duel.GMGroup(Card.IsAbleToDeck,tp,0,"HOG",nil)
	if chk==0 then
		return ct>0 and g:CheckSubGroup(s.tfun2,ct,ct)
	end
	Duel.SOI(0,CATEGORY_TODECK,nil,ct,1-tp,"HOG")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=#(c:GetMutualLinkedGroup():Filter(Card.IsMonster,nil))
	if ct==0 then
		return
	end
	local g=Duel.GMGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,"HOG",nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.tfun2,false,ct,ct)
	if sg and #sg==ct then
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
	end
end
function s.val4(e,re,r,rp,rc)
	local c=e:GetHandler()
	return bit.band(r,REASON_BATTLE)>0 and c:IsRelateToBattle()
end
function s.op5(c,e,tp,sg,mg,lc,og,chk)
	return true
end
function s.val5(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not c:IsAbleToRemove() then
			return Group.CreateGroup()
		else
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK then
		end
	elseif chk==2 then
	end
end
function s.con6(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=MakeEff(c,"S")
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetD(id,0)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	e2:SetValue(1)
	rc:RegisterEffect(e2,true)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	rc:RegisterEffect(e3,true)
end