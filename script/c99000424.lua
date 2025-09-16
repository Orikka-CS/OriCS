--페넘브라 린네
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,{99000417,s.sheya_matfilter},s.matfilter)
	--이 카드는 융합 소환으로만 엑스트라 덱에서 특수 소환할 수 있다.
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0a:SetValue(s.splimit)
	c:RegisterEffect(e0a)
	--이 카드는 융합 소재로 할 수 없다.
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0b:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0b:SetValue(1)
	c:RegisterEffect(e0b)
	--덱 / 엑스트라 덱에서 "페넘브라" 몬스터 3장을 릴리스한다(같은 이름의 카드는 1장까지).
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetTarget(s.rltg)
	e1:SetOperation(s.rlop)
	c:RegisterEffect(e1)
	--상대는 자신의 덱에서 앞면인 카드 1장을 제외하지 않으면, 카드의 효과를 발동할 수 없다.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCost(s.costchk)
	e2:SetOperation(s.costop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	--상대는 자신의 패 / 필드의 몬스터를 전부 뒷면 표시로 제외해야 한다.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.rmcon)
	e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	end)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
end
s.listed_series={0xc11}
s.listed_names={99000417}
function s.sheya_matfilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp) and c:ListsCode(99000417)
end
function s.matfilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,3,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.rfilter(c)
	return c:IsSetCard(0xc11) and c:IsMonster() and c:IsReleasableByEffect()
end
function s.mfilter(c)
	return c:IsMonster() and not c:IsFaceup()
end
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,nil)
	local gc=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if #g<3 or gc<3 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_RELEASE)
	if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT|REASON_RELEASE)~=0 then
		local g2=Duel.GetMatchingGroup(s.mfilter,1-tp,LOCATION_DECK,0,nil)
		if #g2>2 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_POSCHANGE)
			local sg=g2:Select(1-tp,3,3,nil)
			Duel.ShuffleDeck(1-tp)
			for tc in sg:Iter() do
				tc:ReverseInDeck()
				local e3=Effect.CreateEffect(c)
				e3:SetDescription(aux.Stringid(id,2))
				e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e3:SetCode(EVENT_MOVE)
				e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_DECK) end)
				e3:SetOperation(s.penumbra_op3)
				tc:RegisterEffect(e3)
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e4:SetCode(EVENT_ADJUST)
				e4:SetLabelObject(tc)
				e4:SetOperation(s.sheya_check)
				Duel.RegisterEffect(e4,0)
			end
		end
	end
end
function s.sheya_check(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x3fe,0x3fe,nil)
	for gc in g:Iter() do
		if c:GetFlagEffect(99000417)==0 then
			Debug.PreSetTarget(c,gc)
		else
			c:CancelCardTarget(gc)
			e:Reset()
		end
	end
end
function s.penumbra_op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(tp,30459350) or c:GetFlagEffect(99000417)~=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
	if #g>0 then
		Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN,REASON_RULE)
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,tp)
	end
	c:RegisterFlagEffect(99000417,RESET_EVENT|RESETS_STANDARD,0,1)
	e:Reset()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAbleToRemoveAsCost()
end
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,ct,nil)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(1-tp,30459350) then return end
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE|LOCATION_HAND,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,1-tp)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
	Duel.BreakEffect()
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end