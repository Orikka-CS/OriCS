--친목질
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
end
function s.tfil11(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsAbleToRemove()
		and Duel.IEMCard(s.tfil12,tp,"D",0,1,nil,tp,c)
end
function s.tfil12(c,tp,mc)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsAbleToRemove() and s.tfil13(c,mc)
		and Duel.IEMCard(s.tfil14,tp,"D",0,1,c,c)
end
function s.tfil13(c,d)
	local ct=0
	if not c:IsRace(d:GetRace()) then
		ct=ct+1
	end
	if not c:IsAttribute(d:GetAttribute()) then
		ct=ct+1
	end
	if not c:IsLevel(d:GetLevel()) then
		ct=ct+1
	end
	if not c:IsAttack(d:GetAttack()) and not d:IsAttack(c:GetAttack()) then
		ct=ct+1
	end
	if not c:IsDefense(d:GetDefense()) and not d:IsDefense(c:GetDefense()) then
		ct=ct+1
	end
	return ct==1
end
function s.tfil14(c,mc)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and s.tfil13(c,mc)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil11,tp,"H",0,1,nil,tp)
	end
	Duel.SOI(0,CATEGORY_REMOVE,nil,2,tp,"HD")
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rg=Duel.SMCard(tp,s.tfil11,tp,"H",0,1,1,nil,tp)
	local rc=rg:GetFirst()
	if not rc then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=Duel.SMCard(tp,s.tfil12,tp,"D",0,1,1,nil,tp,rc)
	local sc=sg:GetFirst()
	if not sc then
		return
	end
	Duel.ConfirmCards(1-tp,rc)
	Duel.ConfirmCards(1-tp,sc)
	if Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)>0 and rc:IsLocation(LSTN("R")) and rc:IsFacedown() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local th=Duel.SMCard(tp,s.tfil14,tp,"D",0,1,1,sc,sc)
		local tc=th:GetFirst()
		if tc then
			Duel.BreakEffect()
			if Duel.SendtoHand(th,nil,REASON_EFFECT)>0 and tc:IsLoc("H") then
				Duel.ConfirmCards(1-tp,th)
				Duel.Remove(sc,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end
