--Pyrthirio Teras
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),extrafil=s.extrafil,extraop=s.extraop,extratg=s.extratg})
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.extrafil(e,tp,mg)
	local unu=10-Duel.GetLocationCount(tp,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)+Duel.GetFieldGroupCount(tp,LOCATION_EMZONE,0)-Duel.GetLocationCount(tp,LOCATION_SZONE)-Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)+Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)
	if unu>0 then
		local sg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
		if #sg>0 then
			return sg,s.fcheck
		end
		return nil
	end
end

function s.fcheck(tp,sg,fc)
	local unu=10-Duel.GetLocationCount(tp,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)+Duel.GetFieldGroupCount(tp,LOCATION_EMZONE,0)-Duel.GetLocationCount(tp,LOCATION_SZONE)-Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)+Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)
	if not fc:IsSetCard(0xf21) then return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<1 end
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=unu
end

function s.extraop(e,tc,tp,sg)
	local g1=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.Remove(g1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Sub(g1)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end

--effect 2
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	local dis=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,tp,dis)
	Duel.SetTargetParam(dis)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(function(e) return e:GetLabel() end)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetLabel(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
	Duel.RegisterEffect(e1,tp)
end