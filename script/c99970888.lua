--[ Colossus ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"FTo","G")
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCL(1,id)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	
end

function s.filter(c)
	return c:IsSetCard(0x3d6f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsfilter(c)
	return c:IsSetCard(0x3d6f) and c:IsSummonable(true,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			local ng=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
			if #ng>0 and Duel.GetHandLimit(tp)>=3 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			local nsg=ng:Select(tp,1,1,nil)
			Duel.Summon(tp,nsg:GetFirst(),true,nil)
		end
	end
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_ADJUST)~=0
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end
