--왕립 퇴마도서관
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_DISABLE)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
end
s.listed_names={18454445}
s.counter_place_list={COUNTER_SPELL}
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return (re:IsMonsterEffect() and rc:IsRace(RACE_SPELLCASTER))
		or (re:IsSpellEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.tfil1(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_SPELL,1)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsChainDisablable(ev) or Duel.IEMCard(s.tfil1,tp,"O","O",1,nil)
	end
	Duel.SPOI(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local minct=0
	if not Duel.IsChainDisablable(ev) then
		minct=1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SMCard(tp,s.tfil1,tp,"O","O",minct,1,nil)
	local tc=g:GetFirst()
	if tc then
		tc:AddCounter(COUNTER_SPELL,1)
	else
		Duel.NegateEffect(ev)
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