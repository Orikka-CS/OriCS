--페넘브라 세라
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	--Pendulum.AddProcedure
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetDescription(1163)
	e0a:SetCode(EFFECT_SPSUMMON_PROC_G)
	e0a:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0a:SetRange(LOCATION_PZONE)
	e0a:SetCondition(Pendulum.Condition())
	e0a:SetOperation(Pendulum.Operation())
	e0a:SetValue(SUMMON_TYPE_PENDULUM)
	c:RegisterEffect(e0a)
	local e0b=Effect.CreateEffect(c)
	e0b:SetDescription(1160)
	e0b:SetType(EFFECT_TYPE_ACTIVATE)
	e0b:SetCode(EVENT_FREE_CHAIN)
	e0b:SetRange(LOCATION_HAND)
	e0b:SetOperation(s.sheya_op)
	c:RegisterEffect(e0b)
	--자신의 패 / 필드의 몬스터를 융합 소재로서 릴리스하고, 어둠 속성의 융합 몬스터 1장을 융합 소환한다.
	local params={fusfilter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),
				matfilter=Card.IsReleasable,
				extratg=s.extra_target,
				extraop=s.extra_operation}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)
	--패 / 필드 / 묘지의 이 카드는, 융합 몬스터 카드에 카드명이 쓰여진 융합 소재 몬스터 1장 대신으로 할 수 있다.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(s.subcon)
	c:RegisterEffect(e2)
	--이 카드와 상대의 덱 맨 위의 카드를 덱에 앞면으로 넣고 셔플한다.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e3:SetTarget(s.penumbra_tg)
	e3:SetOperation(s.penumbra_op)
	c:RegisterEffect(e3)
end
s.listed_names={99000417}
function s.sheya_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckPendulumZones(tp) and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,0)) then
		local token=Duel.CreateToken(tp,99000417)
		Duel.MoveToField(token,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		--[[
		이 토큰이 펜듈럼 존에 존재하는 한,
		자신이 어둠 속성 융합 몬스터를 융합 소환할 경우, 
		자신의 펜듈럼 존에 존재하는 융합 소재 몬스터도 필드의 몬스터로서 융합 소재로 사용할 수 있다.
		]]
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		e1:SetRange(LOCATION_PZONE)
		e1:SetTargetRange(LOCATION_PZONE,0)
		e1:SetValue(function(_,c) return c and c:IsAttribute(ATTRIBUTE_DARK) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1)
	end
end
function s.extra_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
end
function s.extra_operation(e,tc,tp,sg)
	Duel.Release(sg,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.penumbra_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.penumbra_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		c:ReverseInDeck()
		--그 카드가 덱에서 벗어났을 경우, 상대는 자신의 패 / 필드의 몬스터 1장을 뒷면 표시로 제외해야 한다.
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_MOVE)
		e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_DECK) end)
		e1:SetOperation(s.penumbra_op2)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ADJUST)
		e2:SetLabelObject(c)
		e2:SetOperation(s.sheya_check)
		Duel.RegisterEffect(e2,0)
		Duel.ConfirmDecktop(1-tp,1)
		local g=Duel.GetDecktopGroup(1-tp,1)
		if #g>0 then
			local tc=g:GetFirst()
			Duel.ShuffleDeck(1-tp)
			tc:ReverseInDeck()
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(id,3))
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
function s.penumbra_op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(tp,30459350) or c:GetFlagEffect(99000417)~=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsMonster,1-tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
	if #g>0 then
		Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,1-tp)
	end
	c:RegisterFlagEffect(99000417,RESET_EVENT|RESETS_STANDARD,0,1)
	e:Reset()
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