--왕립 흑마도서관
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DRAW)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
s.listed_names={70791313,18454445}
function s.cfil1(c)
	return (c:IsLoc("H") or c:IsFaceup()) and (c:IsAbleToGraveAsCost() or c:IsAbleToDeckAsCost())
		and (c:IsRace(RACE_SPELLCASTER) or c:IsType(TYPE_SPELL) or c:IsCode(18454445))
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"HO",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"HO",0,1,1,c)
	local tc=g:GetFirst()
	local b1=tc:IsAbleToGraveAsCost()
	local b2=tc:IsAbleToDeckAsCost()
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	if op==1 then
		Duel.SendtoGrave(g,REASON_COST)
	elseif op==2 then
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.ofil1(c)
	return c:IsFaceup() and c:IsCode(70791313)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerCanDraw(tp,2) and Duel.IEMCard(s.ofil1,tp,"OG",0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Draw(tp,2,REASON_EFFECT)
	else
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTR(1,0)
		e1:SetValue(function(_,re)
			local rc=re:GetHandler()
			return (re:IsMonsterEffect() and not rc:IsRace(RACE_SPELLCASTER))
				or (re:IsTrapEffect() and not rc:IsCode(18454445))
		end)
		Duel.RegisterEffect(e1,tp)
	end
end