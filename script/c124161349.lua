--폴루스턴 옥시데이션
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf36) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1filter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local lg=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #lg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local lsg=aux.SelectUnselectGroup(lg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP):GetFirst()
			local ct=math.min(3,lsg:GetLevel()-1)
			local lv=Duel.AnnounceNumberRange(tp,1,ct)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			lsg:RegisterEffect(e1)
		end
	end
end

--effect 2 
function s.tg2dfilter(c)
	return c:IsSetCard(0xf36) and c:IsAbleToGrave()
end

function s.tg2filter(c,tp)
	if not (c:IsFaceup() and c:IsMonster() and c:GetLevel()<c:GetOriginalLevel()) then return false end
	local b1=c:IsSetCard(0xf36) and Duel.GetMatchingGroupCount(s.tg2dfilter,tp,LOCATION_DECK,0,nil,tp)>0
	local b2=c:IsType(TYPE_SYNCHRO) and Duel.IsPlayerCanDraw(tp,1)
	local b3=c:IsType(TYPE_TUNER)
	return b1 or b2 or b3
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET):GetFirst()
	Duel.SetTargetCard(sg)
	if sg:IsSetCard(0xf36) and Duel.GetMatchingGroupCount(s.tg2dfilter,tp,LOCATION_DECK,0,nil,tp)>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
	if sg:IsType(TYPE_SYNCHRO) and Duel.IsPlayerCanDraw(tp,1) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	if sg:IsType(TYPE_TUNER) then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,900)
	end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not tg or not tg:IsRelateToEffect(e) or not tg:IsFaceup() then return end
	local applied=false
	if tg:IsSetCard(0xf36) then
		local g=Duel.GetMatchingGroup(s.tg2dfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
			if #sg>0 then
				Duel.SendtoGrave(sg,REASON_EFFECT)
				applied=true
			end
		end
	end
	if tg:IsType(TYPE_SYNCHRO) and Duel.IsPlayerCanDraw(tp,1) then
		if applied then Duel.BreakEffect() end
		if Duel.Draw(tp,1,REASON_EFFECT)>0 then
			applied=true
		end
	end
	if tg:IsType(TYPE_TUNER) then
		if applied then Duel.BreakEffect() end
		Duel.Damage(1-tp,900,REASON_EFFECT)
	end
end