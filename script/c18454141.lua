--르블랑 아크라이트
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_SUMMON)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"A")
	e4:SetCode(EVENT_CHAINING)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	WriteEff(e4,4,"NTO")
	c:RegisterEffect(e4)
end
function s.nfil1(c)
	return c:IsFaceup() and c:IsSetCard("르블랑")
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0
		and Duel.IEMCard(s.nfil1,tp,"O","O",1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SOI(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and Duel.IsChainNegatable(ev)
		and Duel.IEMCard(s.nfil1,tp,"O","O",1,nil)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SOI(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
