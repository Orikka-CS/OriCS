--감귤천사강림
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"A")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.con1(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LSTN("M"),0)==0
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	if Duel.IsPlayerAffectedByEffect(tp,28170018) then
		Duel.Recover(tp,math.ceil(Duel.GetLP(tp)/2),REASON_EFFECT)
	else
		Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	end
end
function s.tfil21(c,e,tp)
	local atk=c:GetAttack()
	return c:IsFaceup() and Duel.IEMCard(s.tfil22,tp,"D",0,1,nil,e,tp,atk)
		and Duel.IEMCard(s.tfil23,tp,"D",0,1,nil,e,tp,atk)
end
function s.tfil22(c,e,tp,atk)
	return c:IsSetCard(0x2ce) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetAttack()>atk
end
function s.tfil23(c,e,tp,atk)
	return c:IsSetCard(0x2ce) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetAttack()<atk
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil21,tp,0,"M",1,nil,e,tp) and Duel.GetLocCount(tp,"M")>1
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(tp,"M")<=2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SMCard(tp,s.tfil21,tp,0,"M",1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then
		return
	end
	local atk=tc:GetAttack()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SMCard(tp,s.tfil22,tp,"D",0,1,1,nil,e,tp,atk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SMCard(tp,s.tfil23,tp,"D",0,1,1,nil,e,tp,atk)
	g1:Merge(g2)
	Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
end