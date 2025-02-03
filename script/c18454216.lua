--고스텔라 루나티
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","M")
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetCL(1)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
function s.nfil1(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsType(TYPE_EQUIP)
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(s.nfil1,tp,"O",0,1,nil)
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(s.nfil1,tp,"O",0,1,nil)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDiscardDeck(tp,2)
	end
	Duel.SOI(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,2,REASON_EFFECT)~=0 then
		local g=Duel.GetOperatedGroup()
		local tc=g:GetFirst()
		while tc do
			local ae=tc:GetActivateEffect()
			if tc:IsSetCard("고스텔라") and tc:IsType(TYPE_SPELL) and tc:IsLoc("G") and ae then
				local e1=MakeEff(tc,"I","G")
				e1:SetDescription(ae:GetDescription())
				e1:SetCL(1)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_PHASE|PHASE_END&~RESET_TOFIELD)
				e1:SetTarget(s.otar31)
				e1:SetOperation(s.oop31)
				tc:RegisterEffect(e1)
			end
			tc=g:GetNext()
		end
	end
end
function s.otar31(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
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
function s.oop31(e,tp,eg,ep,ev,re,r,rp)
	local ae=e:GetHandler():GetActivateEffect()
	local aop=ae:GetOperation()
	aop(e,tp,eg,ep,ev,re,r,rp)
end