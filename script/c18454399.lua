--무너져 내리는 희망
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DRAW)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","G")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetCondition(aux.exccon)
	WriteEff(e2,2,"CO")
	c:RegisterEffect(e2)
	if s.global_check==nil then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetCondition(s.gcon1)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetCondition(s.gcon1)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
	end
end
s.listed_names={id}
function s.gcon1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsCode(id)
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[rp]=s[rp]+1
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	s[rp]=s[rp]-1
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.FractionDraw(tp,{(s[tp]-1)*2+1,2},REASON_EFFECT)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeckAsCost()
	end
	Duel.SendtoDeck(c,nil,2,REASON_COST)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.FractionDraw(tp,{1,2},REASON_EFFECT)
end