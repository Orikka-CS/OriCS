--토성(새턴 고스텔라)-윤회의 스타카토
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")	
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ghost=Duel.GetPlayerEffect(tp,EFFECT_GHOSTELLAR)
	if chk==0 then
		return ghost or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,1,c)
	end
	if ghost then
		Duel.Hint(HINT_CARD,0,ghost:GetHandler():GetCode())
		ghost:Reset()
		e:SetLabel(0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SMCard(tp,Card.IsDiscardable,tp,"H",0,1,1,c)
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
		e:SetLabel(1)
	end
end
function s.tfil1(c,e)
	return c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.tfun1(g)
	if #g~=2 then
		return false
	end
	local fc=g:GetFirst()
	local sc=g:GetNext()
	return (fc:IsLoc("M") and sc:IsType(TYPE_SPELL+TYPE_TRAP))
		or (sc:IsLoc("M") and fc:IsType(TYPE_SPELL+TYPE_TRAP))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return false
	end
	local g=Duel.GMGroup(s.tfil1,tp,"O","O",nil,e)
	if chk==0 then
		return g:CheckSubGroup(s.tfun1,2,2)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local sg=g:SelectSubGroup(tp,s.tfun1,false,2,2)
	Duel.SetTargetCard(sg)
	Duel.SOI(0,CATEGORY_TOHAND,sg,2,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	if e:GetLabel()~=0 then
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_GHOSTELLAR)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTR(1,0)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDiscardDeck(tp,1)
	end
	Duel.SOI(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)~=0 then
		local g=Duel.GetOperatedGroup()
		local tc=g:GetFirst()
		local ae=tc:GetActivateEffect()
		if tc:IsSetCard("고스텔라") and tc:IsType(TYPE_SPELL) and tc:IsLoc("G") and ae then
			local e1=MakeEff(tc,"I","G")
			e1:SetDescription(ae:GetDescription())
			e1:SetCL(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_PHASE|PHASE_END&~RESET_TOFIELD)
			e1:SetTarget(s.otar21)
			e1:SetOperation(s.oop21)
			tc:RegisterEffect(e1)
		end
	end
end
function s.otar21(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	local ae=e:GetHandler():GetActivateEffect()
	local atg=ae:GetTarget()
	if chk==0 then
		return not atg or atg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	if ae:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else
		e:SetProperty(0)
	end
	if atg then
		atg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function s.oop21(e,tp,eg,ep,ev,re,r,rp)
	local ae=e:GetHandler():GetActivateEffect()
	local aop=ae:GetOperation()
	aop(e,tp,eg,ep,ev,re,r,rp)
end