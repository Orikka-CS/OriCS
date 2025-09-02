--신무리의 감귤천사
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.cfil1(c)
	return c:IsSetCard(0x2ce) and c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and c:IsAbleToGraveAsCost()
		and Duel.IEMCard(Card.IsNegatable,0,"O","O",1,c)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"HM",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"HM",0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(Card.IsNegatable,tp,"O","O",1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local sc=Duel.SMCard(tp,Card.IsNegatable,tp,"O","O",1,1,nil):GetFirst()
	if not sc then
		return
	end
	Duel.HintSelection(sc)
	if sc:IsCanBeDisabledByEffect(e) then
		sc:NegateEffects(c,RESETS_STANDARD_PHASE_END)
		Duel.AdjustInstantly(sc)
		local atk=sc:GetAttack()
		if sc:IsMonster() and atk>0 then
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end