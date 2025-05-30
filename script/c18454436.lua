--왕립 학술도서관
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
s.listed_names={18454445}
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLPCost(tp,500)
	end
	Duel.PayLPCost(tp,500)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SOI(0,CATEGORY_RECOVER,nil,0,1-tp,500)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Draw(tp,1,REASON_EFFECT)>0 then
		Duel.Recover(1-tp,500,REASON_EFFECT)
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