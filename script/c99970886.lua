--[ Colossus ]
local s,id=GetID()
function s.initial_effect(c)

	RevLim(c)
	Xyz.AddProcedure(c,nil,10,3,s.xyzfilter,aux.Stringid(id,3),nil,s.xyzop)
	
	local e1=Effect.CreateEffect(c)
	e1:SetD(id,0)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetD(id,1)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(aux.dxmcostgen(1,1,nil))
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"FTo","M")
	e3:SetD(id,2)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	
end

function s.xyzfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(0x3d6f,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.GetHandLimit(tp)<=3 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end

function s.tar1fil(c)
	return c:IsSetCard(0x3d6f) and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar1fil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.nsfilter(c)
	return c:IsSetCard(0x3d6f) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_ADJUST)~=0
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and eg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #g>0 then
		Duel.Overlay(e:GetHandler(),g,true)
	end
end

