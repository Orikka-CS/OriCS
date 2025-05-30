--왕립 빙결도서관
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_REMOVE)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
s.listed_names={18454445}
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
	end
	Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(Card.IsAbleToRemove,tp,0,"O",1,nil)
			and Duel.IEMCard(Card.IsAbleToRemove,tp,0,"H",1,nil)
			and Duel.IEMCard(Card.IsAbleToRemove,tp,0,"G",1,nil)
	end
	Duel.SOI(0,CATEGORY_REMOVE,nil,3,0,"OHG")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GMGroup(Card.IsAbleToRemove,tp,0,"H",nil)
	local g2=Duel.GMGroup(Card.IsAbleToRemove,tp,0,"O",nil)
	local g3=Duel.GMGroup(Card.IsAbleToRemove,tp,0,"G",nil)
	if #g1>0 and #g2>0 and #g3>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg1=g1:RandomSelect(tp,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg2=g2:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		Duel.HintSelection(sg1)
		Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
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