--ÀÌÅÍ³Î¡Ù¸á·Ð¡ÚÀÌ±×µå¶ó½Ç
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","G")
	e2:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and rp~=tp
end
function s.cfil1(c)
	return c:IsSetCard("¡Ù¸á·Ð¡Ú") and c:IsFaceup() and c:IsAbleToHandAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"M",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SMCard(tp,s.cfil1,tp,"M",0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		Duel.SOI(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.cfil2(c)
	return c:IsSetCard("¡Ù¸á·Ð¡Ú") and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.cfun2(g)
	return g:GetClassCount(Card.GetAttribute)==#g
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GMGroup(s.cfil2,tp,"G",0,nil)
	if chk==0 then
		return g:CheckSubGroup(s.cfun2,3,3)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.cfun2,false,3,3)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsSSetable()
	end
	Duel.SOI(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(3301)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1)
	end
end