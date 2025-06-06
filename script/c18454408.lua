--세기말 어드밴티지 개념 상실(로드 오브 더 타키온 갤럭시)
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH+EFFECT_COUNT_CODE_DUEL)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local e1=MakeEff(c,"FC")
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCL(1)
	e1:SetCondition(s.ocon11)
	e1:SetOperation(s.oop11)
	Duel.RegisterEffect(e1,tp)
end
function s.ocon11(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroup(tp,LSTN("H"),0)<6 and Duel.IsPlayerCanDraw(tp)
end
function s.oop11(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local ct=Duel.GetFieldGroup(tp,LSTN("H"),0)
	local res=Duel.Draw(tp,6-ct,REASON_EFFECT)
	if res>0 then
		Duel.SetLP(tp,Duel.GetLP(tp)-1000*res)
	end
end