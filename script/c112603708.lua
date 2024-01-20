--FOX 1 / 유키노
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.pfil1,1,1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.val0)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCountLimit(1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		s[0]={}
		s[1]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(function()
			s[0]={}
			s[1]={}
		end)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.pfil1(c,lc,sumtype,tp)
	local code=c:GetCode()
	return c:IsSetCard(0xe76,lc,sumtype,tp) and not c:IsSummonCode(lc,sumtype,tp,id)
		and not s[tp][code]
end
function s.val0(e,c)
	local tp=c:GetControler()
	local g=c:GetMaterial()
	for tc in aux.Next(g) do
		local code=tc:GetCode()
		s[tp][code]=true
	end
end
function s.tfil11(c,lg,rg,handler,tp)
	return lg:IsContains(c) and rg:IsExists(s.tfil12,1,Group.FromCards(c,handler),tp,c)
end
function s.tfil12(c,tp,tc)
	return Duel.IsExistingMatchingCard(s.tfil13,tp,LOCATION_DECK,0,1,nil,c:GetCode(),tc and tc:GetCode())
end
function s.tfil13(c,code1,code2)
	return c:IsSetCard(0xe76) and c:IsAbleToHand() and not c:IsCode(code1) and (not code2 or not c:IsCode(code2))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local rg=Duel.GetReleaseGroup(tp)
	local sg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_SZONE,0,nil)
	rg:Merge(sg)
	if chkc then
		return false
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil11,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg,rg,c,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tfil11,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lg,rg,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local rg=Duel.GetReleaseGroup(tp)
	local sg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_SZONE,0,nil)
	rg:Merge(sg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local exg=Group.CreateGroup()
	if c:IsRelateToEffect(e) then
		exg:AddCard(c)
	end
	local exc=nil
	if tc:IsRelateToEffect(e) then
		exg:AddCard(tc)
		exc=tc
	end
	local g=rg:FilterSelect(tp,s.tfil12,1,1,exg,tp,exc)
	if #g>0 and Duel.Release(g,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local rc=g:GetFirst()
		local code1=rc:GetCode()
		local code2=nil
		if exc then
			code2=exc:GetCode()
		end
		local tg=Duel.SelectMatchingCard(tp,s.tfil13,tp,LOCATION_DECK,0,1,1,nil,code1,code2)
		if #tg>0 then
			Duel.SendtoHand(tg,nil,REASON_EFFFCT)
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
function s.cfil2(c,tp)
	return not c:IsCode(id) and Duel.GetMZoneCount(tp,c)>0
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rg=Duel.GetReleaseGroup(tp)
	local sg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_SZONE,0,nil)
	rg:Merge(sg)
	rg=rg:Filter(s.cfil2,nil,tp)
	if chk==0 then
		return c:IsAbleToRemoveAsCost() and #rg>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELSAE)
	local tg=rg:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	if tc:IsSetCard(0xe76) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.Remove(c,REASON_COST)
	Duel.Release(tg,REASON_COST)
end
function s.tfil2(c,e,tp)
	return c:IsSetCard(0xe76) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_SZONE+LOCATION_REMOVED))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_REMOVED,
			0,1,nil,e,tp)
	end
	if e:GetLabel()==1 then
		Duel.SetChainLimit(aux.FALSE)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tfil2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_REMOVED,
		0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end