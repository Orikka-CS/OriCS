--무의식의 샘
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local params={lvtype=RITPROC_EQUAL,extraop=s.op2}
	local e2=MakeEff(c,"I","F")
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetTarget(Ritual.Target(params))
	e2:SetOperation(Ritual.Operation(params))
	c:RegisterEffect(e2)
end
function s.op2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end