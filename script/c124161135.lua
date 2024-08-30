--Naufrate Curse
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetValue(function(e) e:SetLabel(1) end)
	e2:SetCondition(function(e) return Duel.GetMatchingGroupCount(s.cst1filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>0 end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsContinuousTrap() and c:IsTrapMonster() and c:IsAbleToRemoveAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_GRAVE,0,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end

function s.tg1filter(c)
	return c:IsFaceup() and (c:IsSetCard(0xf28) or c:IsTrapMonster())
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local ct=math.min(Duel.GetLocationCount(1-tp,LOCATION_SZONE),Duel.GetMatchingGroupCount(s.tg1filter,tp,LOCATION_MZONE,0,nil))
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return ct>0 and #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local ct=Duel.GetLocationCount(1-tp,LOCATION_SZONE)
	if #g>0 then
		if #g>ct then
			local gg=aux.SelectUnselectGroup(g,e,tp,#g-ct,#g-ct,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
			Duel.SendtoGrave(gg,REASON_RULE,nil,PLAYER_NONE)
			g=g-gg
		end
		for tc in g:Iter() do
			Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			tc:RegisterEffect(e1)
		end
	end
end