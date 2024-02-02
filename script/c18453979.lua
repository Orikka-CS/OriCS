--클릭의 준비
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","G")
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
s.listed_names={18453902}
function s.tfil11(c)
	return c:IsCode(18453903) and c:IsAbleToHand()
end
function s.tfil12(c)
	return not c:IsCode(id) and c:ListsCode(18453902) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GMGroup(s.tfil11,tp,"DG",0,nil)
	local g2=Duel.GMGroup(s.tfil12,tp,"DG",0,nil)
	if chk==0 then
		return #g1>0 and #g2>0
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,2,tp,"DG")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GMGroup(s.tfil11,tp,"DG",0,nil)
	local g2=Duel.GMGroup(s.tfil12,tp,"DG",0,nil)
	if #g1<1 or #g2<1 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg1=g1:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	Duel.SendtoHand(sg1,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sg1)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
	end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)<1
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then
		return
	end
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTR("HM",0)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTarget(s.otar21)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.otar21(e,c)
	return c:IsCode(18453903)
end