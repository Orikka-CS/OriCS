--천재앙 이즈모 카무이
local s,id=GetID()
function s.initial_effect(c)
	--order summon
	aux.AddOrderProcedure(c,"L",nil,s.ordfil1,s.ordfil2)
	c:EnableReviveLimit()
	--이 카드의 속성은 "땅" "물" "화염" "바람"으로도 취급한다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND)
	c:RegisterEffect(e1)
	--이 몬스터가 앞면 표시로 존재하는 동안, 그 몬스터의 컨트롤을 얻는다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_ORDER) end)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--Add to hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.effcon)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.effcon2)
	c:RegisterEffect(e4)
end
function s.ordfil1(c)
	return c:IsSummonLocation(LOCATION_HAND|LOCATION_GRAVE) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.ordfil2(c)
	return c:IsSummonLocation(LOCATION_HAND|LOCATION_DECK) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND) and c:IsControlerCanBeChanged()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetCondition(s.ctcon)
		tc:RegisterEffect(e1)
	end
end
function s.ctcon(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) 
		and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		and ((c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp) or c:IsReason(REASON_BATTLE))
end
function s.effcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.damfilter(c,tid)
	return c:GetTurnID()==tid and (c:GetReason()&REASON_DESTROY)~=0 and c:IsAttackAbove(1)
end
function s.tdfilter(c)
	return c:IsSpellTrap() and c:IsAbleToDeck()
end
function s.tgfilter(c,tp)
	return c:IsMonster() and c:IsAbleToGrave()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--이 턴에 파괴된 자신 묘지의 몬스터 1장을 골라, 그 공격력의 절반의 데미지를 상대에게 준다.
	local tid=Duel.GetTurnCount()
	local b1=not Duel.HasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(s.damfilter,tp,LOCATION_GRAVE,0,1,nil,tid)
	--필드의 마법 / 함정 카드 1장을 골라 주인의 덱 맨 위로 되돌린다.
	local b2=not Duel.HasFlagEffect(tp,id+1) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	--덱에서 몬스터 1장을 묘지로 보낸다.
	local b3=not Duel.HasFlagEffect(tp,id+2) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	--상대의 패를 무작위로 1장 고르고 묘지로 보낸다.
	local b4=not Duel.HasFlagEffect(tp,id+3) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	if chk==0 then return (b1 or b2 or b3 or b4) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)},
		{b4,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DAMAGE)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		local g=Duel.GetMatchingGroup(s.damfilter,tp,LOCATION_GRAVE,0,nil,tid)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TODECK)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif op==4 then
		e:SetCategory(CATEGORY_HANDES)
		Duel.RegisterFlagEffect(tp,id+3,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local tid=Duel.GetTurnCount()
		local g=Duel.SelectMatchingCard(tp,s.damfilter,tp,LOCATION_GRAVE,0,1,1,nil,tid)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Damage(1-tp,g:GetFirst():GetAttack()/2,REASON_EFFECT)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	elseif op==4 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		local sg=g:RandomSelect(ep,1)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end