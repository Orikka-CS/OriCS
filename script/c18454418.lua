--몬스터 드레인
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_RECOVER)
	WriteEff(e1,1,"NO")
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsMonsterEffect() and Duel.IsChainNegatable(ev)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.IsChainDisablable(0) then
		local sel=1
		local g=Duel.GMGroup(Card.IsAttribute,tp,0,"H",nil,rc:GetAttribute())
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
		if #g>0 then
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT|REASON_DISCARD)
			Duel.NegateEffect(0)
			return
		end
	end
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		local atk=rc:GetAttack()
		if Duel.Destroy(eg,REASON_EFFECT)>0 and atk>0 then
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end