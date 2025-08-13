--[ Ven©ªmicTail ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x6d71),aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e99=Effect.CreateEffect(c)
	e99:SetType(EFFECT_TYPE_SINGLE)
	e99:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e99:SetValue(function(e,damp) if e:GetOwnerPlayer()==1-damp then return Duel.GetLP(damp) else return -1 end end)
	c:RegisterEffect(e99)
	
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(s.atktg)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e5:SetValue(s.defval)
	c:RegisterEffect(e5)
	
end

function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.cfilter(c,tp)
	return c:IsAbleToGraveAsCost() and (c:IsControler(tp) or c:IsFaceup())
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
end

function s.tar1f(c)
	return c:IsSetCard(0x6d71) and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tar1f(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tar1f,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.tar1f,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

function s.tgf(c,tp)
	return c:IsSetCard(0x6d71) and c:IsMonster() and c:IsFaceup() and c:IsControler(tp)
end
function s.atktg(e,c)
	return c:GetColumnGroup():IsExists(s.tgf,1,nil,e:GetHandlerPlayer())
end
function s.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
function s.defval(e,c)
	return math.ceil(c:GetDefense()/2)
end
