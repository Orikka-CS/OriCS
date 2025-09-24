--기원의 마스카레이드
local s,id=GetID()
function s.initial_effect(c)
	--delight summon
	aux.AddDelightProcedure(c,s.dfilter,1,1)
	c:EnableReviveLimit()
	--그 몬스터를 2턴 딜레이하고, 이 카드는 엔드 페이즈까지, 그 몬스터의 원래의 카드명 / 효과와 같은 카드명 / 효과를 얻는다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_DELIGHT) end)
	e1:SetCost(s.copycost)
	e1:SetTarget(s.copytg)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)
	--상대 플레이어에게 악수를 청한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsType(TYPE_PENDULUM|TYPE_LINK) end)
end
s.custom_type=CUSTOMTYPE_DELIGHT
function s.dfilter(c)
	local tp=c:GetControler()
	return c:IsType(TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(41209827)==0 end
	e:GetHandler():RegisterFlagEffect(41209827,RESETS_STANDARD_PHASE_END,0,1)
end
function s.copyfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.copyfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code=tc:GetOriginalCode()
		aux.DelayByTurn(tc,tp,2)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			c:CopyEffect(code,RESETS_STANDARD_PHASE_END,1)
		end
	end
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,LOCATION_DECK,0,1,nil) 
			and Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_DECK,1,nil) 
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.SelectOption(1-tp,aux.Stringid(81332143,0),aux.Stringid(81332143,1))
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,577)
		local tc=Duel.SelectMatchingCard(tp,aux.NOT(Card.IsPublic),tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if not tc then return end
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
		Duel.Hint(HINT_SELECTMSG,1-tp,577)
		tc=Duel.SelectMatchingCard(1-tp,aux.NOT(Card.IsPublic),1-tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if not tc then return end
		Duel.BreakEffect()
		Duel.ShuffleDeck(1-tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(1-tp,1)
	end
end