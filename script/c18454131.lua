--¸£ºí¶û ÇÁ¸°¼¼½º
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S","M")
	e2:SetCode(EFFECT_SET_CONTROL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_TOHAND)
	WriteEff(e4,4,"CTO")
	c:RegisterEffect(e4)
end
function s.con2(e)
	return Duel.IsBattlePhase()
end
function s.val2(e,c)
	local handler=e:GetHandler()
	return handler:GetOwner()
end
function s.tfil3(c,e,tp)
	return c:IsSetCard("¸£ºí¶û") and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or (Duel.GetLocCount(1-tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil,e,tp)
	end
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then
		return
	end
	aux.ToHandOrElse(tc,tp,
		function(sc)
			return sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and Duel.GetLocCount(1-tp,"M")>0
		end,
		function(sc)
			Duel.SpecialSummon(sc,0,tp,1-tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,0)
	)
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHandAsCost()
	end
	Duel.SendtoHand(c,1-tp,REASON_COST)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsAbleToHand() and chkc:IsOnField()
	end
	if chk==0 then
		return Duel.IETarget(Card.IsAbleToHand,tp,"O","O",1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.STarget(tp,Card.IsAbleToHand,tp,"O","O",1,1,nil)
	Duel.SOI(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end