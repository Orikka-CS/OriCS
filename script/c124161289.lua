--로그인 투 체어라키
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1a:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1a:SetValue(function(e) e:SetLabel(1) end)
	e1a:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.cst1filter,e:GetHandlerPlayer(),LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),e:GetHandlerPlayer()) end)
	c:RegisterEffect(e1a)
	e1:SetLabelObject(e1a)
end

--effect 1
function s.cst1filter(c,tp)
	return c:IsAbleToGraveAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.cst1filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
		Duel.SendtoGrave(g,REASON_COST)
	end
end

function s.tg1filter(c,e,tp)
	return c:IsSetCard(0xf32) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.op1filter(c)
	return c:IsSetCard(0xf32) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON):GetFirst()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local xg=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_MZONE,0,nil)
		if c:IsRelateToEffect(e) and #xg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			local xsg=aux.SelectUnselectGroup(xg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP):GetFirst()
			c:CancelToGrave()
			Duel.Overlay(xsg,c)
		end
	end
end