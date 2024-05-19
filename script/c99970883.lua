--[ Colossus ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.AddColossusSummonProcedure(c)
	
	local e3=MakeEff(c,"STo")
	e3:SetD(id,0)
	e3:SetCategory(CATEGORY_SEARCH_CARD)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local e2=e3:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	local e1=MakeEff(c,"Qf","M")
	e1:SetD(id,1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	WriteEff(e1,1,"NO")
	c:RegisterEffect(e1)
	
	local e8=MakeEff(c,"STo")
	e8:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_RELEASE)
	WriteEff(e8,8,"NTO")
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_TO_GRAVE)
	e9:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp and (r&REASON_ADJUST)~=0 end)
	c:RegisterEffect(e9)
	
end

function s.tar3fil(c)
	return c:IsSetCard(0x3d6f) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar3fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar3fil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.BreakEffect()
			local sg=e:GetHandler():GetColumnGroup():Filter(Card.IsControler,e:GetHandler(),1-tp)
			if #sg<1 then return end
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and ep==1-tp
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local zone=eg:GetBitwiseOr(Card.GetColumnZone,LOCATION_MZONE,0,0,tp)
	local tc=re:GetHandler()
	local c=e:GetHandler()
	
	if not c:IsRelateToEffect(e) then return end
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	e1:SetLabelObject(re)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	
	if not tc:IsRelateToEffect(re) or tc:IsControler(tp)
		or Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL,zone)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(c,math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~zone),2))
	
end
function s.efilter(e,re)
	return re==e:GetLabelObject()
end

function s.con8(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
function s.tar8fil(c,ft,e,tp)
	return (c:IsSetCard(0x3d6f) and not c:IsCode(id) and c:IsM()) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar8(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.tar8fil,tp,LOCATION_GRAVE,0,1,nil,ft,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op8(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local tc=Duel.SelectMatchingCard(tp,s.tar8fil,tp,LOCATION_GRAVE,0,1,1,nil,ft,e,tp):GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,
		function(tc)
			return ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(tc)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2))
	end
end

