--종말의 경계
local s,id=GetID()
function s.initial_effect(c)
	--이하의 효과에서 1개를 선택하고 발동할 수 있다.
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_ACTIVATE)
	e1a:SetCode(EVENT_FREE_CHAIN)
	e1a:SetCost(s.effcost)
	e1a:SetTarget(s.efftg)
	e1a:SetOperation(s.effop)
	c:RegisterEffect(e1a)
	--이 카드는 패를 1장 버리고, 세트한 턴에 발동할 수도 있다.
	local e1b=Effect.CreateEffect(c)
	e1b:SetDescription(aux.Stringid(99000265,0))
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1b:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1b:SetValue(function(e,c) e:SetLabel(1) end)
	e1b:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsDiscardable,e:GetHandlerPlayer(),LOCATION_HAND,0,1,nil) end)
	c:RegisterEffect(e1b)
	e1a:SetLabelObject(e1b)
	--자신이나 상대의 LP가 변화했을 경우에 발동할 수 있다. (데미지 / 회복 / 지불 / 상실)
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(99000264)
	e2a:SetRange(LOCATION_GRAVE)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetTargetRange(1,1)
	c:RegisterEffect(e2a)
	--이 카드를 패에 넣는다.
	local e2b=Effect.CreateEffect(c)
	e2b:SetCategory(CATEGORY_TOHAND)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2b:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2b:SetCode(EVENT_CUSTOM+99000264)
	e2b:SetRange(LOCATION_GRAVE)
	e2b:SetCountLimit(1,id)
	e2b:SetTarget(s.thtg)
	e2b:SetOperation(s.thop)
	c:RegisterEffect(e2b)
	local e2c=e2b:Clone()
	e2c:SetCode(EVENT_RECOVER)
	c:RegisterEffect(e2c)
	local e2d=e2b:Clone()
	e2d:SetCode(EVENT_DAMAGE)
	c:RegisterEffect(e2d)
end
s.listed_turn_count=true
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR|RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local label_obj=e:GetLabelObject()
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
	local b2=not Duel.HasFlagEffect(tp,id+1000)
		and Duel.IsExistingMatchingCard(Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,1,nil,1082946)
		and Duel.IsPlayerCanDraw(1-tp,1)
	if chk==0 then label_obj:SetLabel(0) return b1 or b2 end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.DiscardHand(tp,nil,1,1,REASON_COST|REASON_DISCARD)
	end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(1082946,0))
		local turn_count_g=Duel.SelectMatchingCard(tp,Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,1,1,nil,1082946)
		local turn_count_tc=turn_count_g:GetFirst()
		local eff={turn_count_tc:GetCardEffect(1082946)}
		local sel={}
		local seld={}
		local turne
		for _,te in ipairs(eff) do
			table.insert(sel,te)
			table.insert(seld,te:GetDescription())
		end
		if #sel==1 then turne=sel[1] elseif #sel>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			local op=Duel.SelectOption(tp,table.unpack(seld))+1
			turne=sel[op]
		end
		if not turne then return end
		local op=turne:GetOperation()
		op(turne,turne:GetOwnerPlayer(),nil,0,1082946,nil,0,0)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cost_skip=e:GetLabel()~=-100
	local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and (not cost_skip or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
	local b2=(cost_skip or not Duel.HasFlagEffect(tp,id+1000))
		and (not cost_skip or Duel.IsPlayerCanDraw(1-tp,1))
		and Duel.IsExistingMatchingCard(Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,1,nil,1082946)
	if chk==0 then e:SetLabel(0) return b1 or b2 end
	local op=e:GetLabel()
	if op==0 then
		cost_skip=true
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
	else
		cost_skip=false
	end
	e:SetLabel(0)
	Duel.SetTargetParam(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	elseif op==2 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+1000,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetTargetPlayer(1-tp)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,2)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local p,op=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if op==1 then
		--자신의 묘지 / 제외 상태인 전사족 / 악마족 몬스터 1장을 특수 소환한다.
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--상대는 1장 드로우한다. 그 후, 상대는 패를 무작위로 1장 버린다. 추가로 상대는 패가 있을 경우에는 1장 고르고 버린다.
		if Duel.Draw(p,1,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			local dg=Duel.GetFieldGroup(p,LOCATION_HAND,0):RandomSelect(p,1)
			if Duel.SendtoGrave(dg,REASON_EFFECT|REASON_DISCARD)>0 and Duel.GetFieldGroupCount(p,LOCATION_HAND,0)>0 then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				Duel.DiscardHand(p,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
			end
		end
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end