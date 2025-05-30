--왕립 결계도서관
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)
	c:SetCounterLimit(COUNTER_SPELL,3)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","S")
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTR(0,0xff)
	e2:SetValue(LSTN("R"))
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	--
	local e3=MakeEff(c,"F","S")
	e3:SetCode(81674782)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTR(0,0xff)
	e3:SetTarget(s.tar3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"F","S")
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTR(0,1)
	e4:SetTarget(s.tar4)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"FC","S")
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(aux.chainreg)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"FC","S")
	e6:SetCode(EVENT_CHAIN_SOLVED)
	WriteEff(e6,6,"O")
	c:RegisterEffect(e6)
	local e7=MakeEff(c,"I","S")
	e7:SetCategory(CATEGORY_DRAW)
	WriteEff(e7,7,"CTO")
	c:RegisterEffect(e7)
end
s.counter_place_list={COUNTER_SPELL}
function s.tar2(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()~=tp and Duel.IsPlayerCanRemove(tp,c)
		and (c:IsRace(RACE_SPELLCASTER) or c:IsType(TYPE_SPELL))
end
function s.tar3(e,c)
	return not c:IsPublic()
end
function s.tar4(e,c,tp,r,re)
	local ep=e:GetHandlerPlayer()
	local rc=re:GetHandler()
	return c:IsControler(ep) and r&REASON_EFFECT~=0 and (rc:IsRace(RACE_SPELLCASTER) or rc:IsType(TYPE_SPELL))
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() and c:GetFlagEffect(1)>0 then
		c:AddCounter(COUNTER_SPELL,1)
	end
end
function s.cost7(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:GetCounter(COUNTER_SPELL)==3 and c:IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.tar7(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op7(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end