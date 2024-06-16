--용암 대지
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","G")
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCost(aux.bfgcost)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttackAbove(0)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		if #tg>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=tg:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			local tc=sg:GetFirst()
			local ttype=tc:Type()
			tc:Type(ttype|TYPE_TOKEN)
			if Duel.Destroy(sg,REASON_EFFECT)>0 then
				table.insert(Auxiliary.BurningZone[tc:GetOwner()],tc)
				Auxiliary.BurningZoneTopCardOperation(e,tp,eg,ep,ev,re,r,rp)
			end
			tc:Type(ttype)
		else
			local tc=tg:GetFirst()
			local ttype=tc:Type()
			tc:Type(ttype|TYPE_TOKEN)
			if Duel.Destroy(tg,REASON_EFFECT)>0 then
				table.insert(Auxiliary.BurningZone[tc:GetOwner()],tc)
				Auxiliary.BurningZoneTopCardOperation(e,tp,eg,ep,ev,re,r,rp)
			end
			tc:Type(ttype)
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then
		return false
	end
	local tg=g:GetMaxGroup(Card.GetAttack)
	return tg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.tfil2(c)
	return c:IsAbleToHand() and (c:IsCode(97169186) or c:IsCode(66788016))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end