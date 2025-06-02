--sparkle.exe
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC","G")
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetCL(1,{id,1})
	e2:SetTarget(s.tar2)
	e2:SetValue(s.val2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
function s.tfil1(c)
	return c:IsSetCard("sparkle.exe") and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	local cc=Duel.GetCurrentChain()
	if cc>2 then
		local p0=Duel.GetChainInfo(cc-2,CHAININFO_TRIGGERING_PLAYER)
		local p1=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
		if p0==tp and p1~=tp then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
			Duel.SPOI(0,CATEGORY_DRAW,nil,0,tp,1)
		else
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		end
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLoc("H") then
		Duel.ConfirmCards(1-tp,tc)
		local cc=Duel.GetCurrentChain()
		if cc>2 then
			local p0=Duel.GetChainInfo(cc-2,CHAININFO_TRIGGERING_PLAYER)
			local p1=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
			if p0==tp and p1~=tp and Duel.IsPlayerCanDraw(tp,1)
				and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
function s.tfil2(c,tp)
	return c:IsLoc("M") and c:IsControler(tp) and c:IsReason(REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local cc=Duel.GetCurrentChain()
		if cc<=1 or not re then
			return false
		end
		local p0=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
		local p1=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_PLAYER)
		local ce=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_EFFECT)
		return c:IsAbleToRemove() and p0==tp and p1~=tp and re==ce and eg:IsExists(s.tfil2,1,nil,tp)
	end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.val2(e,c)
	local tp=e:GetHandlerPlayer()
	return s.tfil2(c,tp)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
end