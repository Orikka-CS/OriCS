--[ Colossus ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.AddColossusSummonProcedure(c)

	local e2=MakeEff(c,"FTo","H")
	e2:SetD(id,0)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.nscon)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
	local e1=e2:Clone()
	e1:SetCode(EVENT_MSET)
	c:RegisterEffect(e1)
	
	local e3=Effect.CreateEffect(c)
	e3:SetD(id,1)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	
	local e8=MakeEff(c,"STo")
	e8:SetCategory(CATEGORY_REMOVE)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_RELEASE)
	WriteEff(e8,8,"NTO")
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_TO_GRAVE)
	e9:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp and (r&REASON_ADJUST)~=0 end)
	c:RegisterEffect(e9)
	
end

function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSummonable(true,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsSummonable(true,nil) then
		Duel.Summon(tp,e:GetHandler(),true,nil)
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and re:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,1-tp,LOCATION_ONFIELD)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function s.con8(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
function s.tar8(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_MZONE)
end
function s.op8(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if #g<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,2,2,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
