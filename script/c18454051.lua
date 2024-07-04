--붉은 실의 끝에서 마주치는 진실
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetValue(function(e,c) e:SetLabel(1) end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:GetLabelObject():SetLabel(0)
		return true
	end
	if e:GetLabelObject():GetLabel()>0 then
		e:GetLabelObject():SetLabel(0)
		Duel.PayLPCost(tp,1000)
	end
end
function s.tfil1(c,e,tp)
	return c:IsSetCard(0xc00) and c:IsType(TYPE_MONSTER+TYPE_SPELL)
		and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToHand()
			or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsType(TYPE_FUSION)
				and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tfun1(g,e,tp)
	return g:GetClassCount(s.tval1)==#g
end
function s.tval1(c)
	return c:GetType()&0x7
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tfil1,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		return #g>0
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.tfun1,1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(sg)
	e:SetLabel(#sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local fc=g:Filter(Card.IsType,nil,TYPE_FUSION):GetFirst()
	local suc=false
	if fc and fc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.SpecialSummon(fc,0,tp,tp,false,false,POS_FACEUP)
		suc=true
		g:RemoveCard(fc)
	end
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		suc=true
	end
	if suc and e:GetLabel()==2 then
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
		if #dg>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end