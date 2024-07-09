--르블랑 리트레이스
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
end
function s.tfil1(c)
	return c:IsFaceup() and c:IsSetCard("르블랑")
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=#Duel.GMGroup(s.tfil1,tp,0,"M",nil)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,ct) and Duel.IsPlayerCanDraw(1-tp,ct)
	end
	Duel.SOI(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,ct)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ct=#Duel.GMGroup(s.tfil1,tp,0,"M",nil)
	if ct>0 then
		Duel.Draw(tp,ct,REASON_EFFECT)
		Duel.Draw(1-tp,ct,REASON_EFFECT)
	end
end