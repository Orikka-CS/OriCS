--패스 오브 애쉬블룸
local m=47210025
local cm=_G["c"..m]

local costcard=nil
local payed=false

function cm.initial_effect(c)

	--Activate
	--local e99=Effect.CreateEffect(c)
	--e99:SetType(EFFECT_TYPE_ACTIVATE)
	--e99:SetCode(EVENT_FREE_CHAIN)
	--e99:SetHintTiming(0,TIMING_END_PHASE)
	--e99:SetCost(cm.eff00_cost)
	--c:RegisterEffect(e99)

	--Activate_TO_Effect_02
	local e92=Effect.CreateEffect(c)
	e92:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e92:SetType(EFFECT_TYPE_ACTIVATE)
	e92:SetCode(EVENT_FREE_CHAIN)
	e92:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e92:SetRange(LOCATION_SZONE)
	e92:SetHintTiming(0,TIMING_END_PHASE)
	e92:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e92:SetCost(cm.eff00_cost)
	e92:SetTarget(cm.eff00_tar)
	e92:SetOperation(cm.eff02_op)
	c:RegisterEffect(e92)

	--Effect_00
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetDescription(aux.Stringid(m,0))
	e0:SetValue(function(e,c) e:SetLabel(1) end)
	e0:SetCondition(function(e) return Duel.IsExistingMatchingCard(cm.eff00_filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil) end)
	c:RegisterEffect(e0)
	--e99:SetLabelObject(e0)
	e92:SetLabelObject(e0)

	--Effect_01
	c:SetUniqueOnField(1,0,m)

	--Effect_02
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(cm.eff02_tar)
	e2:SetOperation(cm.eff02_op)
	c:RegisterEffect(e2)

	--Effect_03
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetValue(cm.eff03_val)
	e3:SetTarget(cm.eff03_tar)
	e3:SetOperation(cm.eff03_op)
	c:RegisterEffect(e3)

end

function cm.eff00_filter(c)
	return c:IsSetCard(0xa7b) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function cm.eff00_cost(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then e:GetLabelObject():SetLabel(0) return true end

	if e:GetLabelObject():GetLabel()>0 then
		e:GetLabelObject():SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,cm.eff00_filter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		payed=true
	end

end

function cm.eff00_addcost(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then return Duel.IsExistingMatchingCard(cm.eff00_filter,tp,LOCATION_GRAVE,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.eff00_filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function cm.eff00_tar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)

	if chk==0 then return Duel.GetFlagEffect(tp,m)==0 end

	if payed==false and cm.eff00_addcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		cm.eff00_addcost(e,tp,eg,ep,ev,re,r,rp,1)
		payed=true
	end
	payed=false

	if Duel.GetFlagEffect(tp,m)==0 and Duel.IsExistingTarget(cm.eff02_filter,tp,LOCATION_REMOVED,0,1,costcard) and Duel.IsPlayerCanDraw(tp,1) then

		costcard=nil

		if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and cm.eff02_filter(chkc) end

		if Duel.SelectYesNo(tp,aux.Stringid(m,1)) then

			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectTarget(tp,cm.eff02_filter,tp,LOCATION_REMOVED,0,1,1,nil)

			Duel.HintSelection(g,true)
			Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)

			Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)

		end
	end
end

function cm.eff02_filter(c)
	return c:IsSetCard(0xa7b) and c:IsFaceup()
end

function cm.eff02_tar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)

	if chk==0 then return Duel.GetFlagEffect(tp,m)==0 and Duel.IsExistingTarget(cm.eff02_filter,tp,LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) end

	if Duel.GetFlagEffect(tp,m)==0 and Duel.IsExistingTarget(cm.eff02_filter,tp,LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) then

		if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and cm.eff02_filter(chkc) end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectTarget(tp,cm.eff02_filter,tp,LOCATION_REMOVED,0,1,1,nil)

		Duel.HintSelection(g,true)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)

		Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
	end
end

function cm.eff02_op(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetTargetCards(e)

	if #g>0 then


		--local ct=
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)

		local dg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)

		if #dg<1 then return end

		Duel.BreakEffect()

		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(1)

		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)

		if Duel.Draw(p,d,REASON_EFFECT) then

			local tc=Duel.GetOperatedGroup():GetFirst()

			if tc:IsType(TYPE_TRAP) and tc:IsSetCard(0xa7b) and Duel.SelectYesNo(tp,aux.Stringid(m,3)) then
				
				Duel.BreakEffect()
				
				Duel.SSet(tp,tc)
				local e0=Effect.CreateEffect(tc)
				e0:SetType(EFFECT_TYPE_SINGLE)
				e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e0:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e0)

			end
		end
	end
end



function cm.eff03_filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xa7b) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and not c:IsReason(REASON_REPLACE)
end

function cm.eff03_tar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(cm.eff03_filter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function cm.eff03_val(e,c)
	return cm.eff03_filter(c,e:GetHandlerPlayer())
end

function cm.eff03_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end