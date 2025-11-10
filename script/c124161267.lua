--메가히트 소울 깁스넬
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf31),2)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DRAW)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(ep,id)
	if Duel.GetTurnCount()==0 then return end
	if ev>ct then
		for i=1,ev-ct do
			Duel.RegisterFlagEffect(ep,id,0,0,1)
		end
	end
end

--link
function s.linkfilter(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xf31,lc,sumtype,tp)
end

--effect 1
function s.tg1filter(c,e,tp)
	if not (c:IsSetCard(0xf31) and c:IsSpellTrap() and c:IsFaceup() and c:IsAbleToHand()) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetCode()==EVENT_DESTROYED and eff:IsHasType(EFFECT_TYPE_SINGLE) then
			local tg=eff:GetTarget()
			if tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0) then
				return true
			end
		end
	end
	return false
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tg1filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tg1filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	local available_effs={}
	local effs={tc:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetCode()==EVENT_DESTROYED and eff:IsHasType(EFFECT_TYPE_SINGLE) then
			local tg=eff:GetTarget()
			if tg==nil or tg(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,0) then
				table.insert(available_effs,eff)
			end
		end
	end
	local eff=nil
	eff=available_effs[1]
	if eff then
		Duel.Hint(HINT_OPSELECTED,1-tp,eff:GetDescription())
		Duel.ClearTargetCard()
		tc:CreateEffectRelation(e)
		e:SetLabel(eff:GetLabel())
		e:SetLabelObject(eff:GetLabelObject())
		local tg=eff:GetTarget()
		if tg then
			tg(e,tp,eg,ep,ev,re,r,rp,1)
			eff:SetLabel(e:GetLabel())
			eff:SetLabelObject(e:GetLabelObject())
			Duel.ClearOperationInfo(0)
		end
		e:SetLabelObject(eff)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local _,tc=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	tc=tc:GetFirst()
	if tc and tc:IsRelateToEffect(e) then
		local te=e:GetLabelObject()
		if te then
			local break_chk=false
			local op=te:GetOperation()
			if tc:IsFaceup() and op then
				e:SetLabel(te:GetLabel())
				e:SetLabelObject(te:GetLabelObject())
				op(e,tp,eg,ep,ev,re,r,rp)
				break_chk=true
			end
			e:SetLabel(0)
			e:SetLabelObject(nil)
		end
		if break_chk then Duel.BreakEffect() end
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf31) and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_MZONE,0,nil)
	return rp==1-tp and g>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsCanBeEffectTarget(e) end
	local ct=Duel.GetFlagEffect(tp,id)
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return e:GetHandler():IsAbleToDeck() and #g>0 and ct>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end