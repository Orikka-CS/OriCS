--강성(카네이션 고스텔라)-파천의 아르카디아
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_REMOVE)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ghost=Duel.GetPlayerEffect(tp,EFFECT_GHOSTELLAR)
	if chk==0 then
		return ghost or Duel.CheckLPCost(tp,3000)
	end
	if ghost then
		Duel.Hint(HINT_CARD,0,ghost:GetHandler():GetCode())
		ghost:Reset()
		e:SetLabel(0)
	else
		Duel.PayLPCost(tp,3000)
		e:SetLabel(1)
	end
end
function s.tfil1(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard("고스텔라")
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 
			and Duel.IEMCard(s.tfil1,tp,"R",0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocCount(tp,"M")
	if ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SMCard(tp,s.tfil1,tp,"R",0,ft,ft,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
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
		return Duel.IEMRemoveCard(Card.IsSetCard,tp,"D",0,1,nil,"고스텔라")
	end
	Duel.SOI(0,CATEGORY_REMOVE,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SMRemoveCard(tp,Card.IsSetCard,tp,"D",0,1,1,nil,"고스텔라")
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local e1=MakeEff(c,"FC","R")
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.ocon21)
		e1:SetOperation(s.oop21)
		tc:RegisterEffect(e1)
	end
end
function s.ocon21(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsAbleToHand() or (Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.oop21(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.ToHandOrElse(c,tp,
		function(sc)
			return sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		end,
		function(sc)
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,0)
	)
end