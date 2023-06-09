--소울 슬레이어의 전장
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--activate from GY
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.cost2)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_ACTIVATE_COST)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.actarget)
	e3:SetCost(s.acchk)
	e3:SetOperation(s.acop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(id,6))
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCondition(s.spcon2)
	e5:SetLabel(1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetLabel(2)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetLabel(3)
	c:RegisterEffect(e7)
	local e8=e5:Clone()
	e8:SetLabel(4)
	c:RegisterEffect(e8)
end
s.listed_series={0x903}
s.listed_names={id}
--activate
function s.tfil11(c)
	return c:IsSetCard(0x903) and c:IsAbleToGrave()
end
function s.tfil12(c,e,tp)
	return c:IsSetCard(0x903) and
		((c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
			or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)) or c:IsAbleToHand())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil11,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.tfil12,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tfil11,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.tfil12,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		aux.ToHandOrElse(tc,tp,function(c)
				if tc:IsMonster() then
					return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
						and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
				elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) then
					return tc:IsSSetable()
				end
				return false
			end,
		function(c)
				if tc:IsMonster() then
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				else
					Duel.SSet(tp,tc)
				end
			end,1153)
	end
end
--activate from GY
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetType(EFFECT_TYPE_ACTIVATE)
		local cost=Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,nil,e:GetHandler(),0x903)
		local activatable=e:GetLabelObject():IsActivatable(tp,true,false)
		e:SetType(EFFECT_TYPE_IGNITION)
		return cost and activatable
	end
	e:SetType(EFFECT_TYPE_ACTIVATE)
	local sg=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,nil,e:GetHandler(),0x903)
	Duel.Release(sg,REASON_COST)
end
function s.actarget(e,te,tp)
	return te==e:GetLabelObject()
end
function s.acchk(e,te,tp)
	return not e:GetHandler():IsForbidden()
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_FZONE,POS_FACEUP,false)
end
--special summon
function s.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil,1-tp)
	if #g<5 then return false end
	e:SetLabel(#g)
	e:SetDescription(aux.Stringid(id,5))
	return true
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	if eg:Filter(s.cfilter,nil,1-tp):GetCount()~=e:GetLabel() then return false end
	e:SetDescription(aux.Stringid(id,e:GetLabel()))
	return true
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x903) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetLabel()>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,math.min(ft,e:GetLabel()),nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
