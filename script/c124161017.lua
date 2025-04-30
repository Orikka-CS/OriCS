--피르티리오 스네이크
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xf21),gc=Fusion.ForcedHandler,stage2=s.stage2}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.stage2(e,tc,tp,sg,chk)
	local c=e:GetHandler()
	if chk==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.BreakEffect()
		local dis=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		Duel.SetTargetParam(dis)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetOperation(function(e) return e:GetLabel() end)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetLabel(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
		Duel.RegisterEffect(e1,tp)
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local ch=ev-1
	if ch==0 or not (ep==1-tp and Duel.IsChainDisablable(ev)) or re:GetHandler():IsDisabled() then return false end
	local ch_player,ch_eff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
	local ch_c=ch_eff:GetHandler()
	return ch_player==tp and (ch_c:IsSetCard(0xf21) and ch_c:IsType(TYPE_FUSION) and ch_eff:IsMonsterEffect())
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp) 
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end