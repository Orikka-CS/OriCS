--허월상의 운희 아히나
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf34),3,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&(LOCATION_ONFIELD)>0 and rp==1-tp and Duel.IsChainNegatable(ev)
end

function s.cst1filter(c)
	return c:IsSetCard(0xf34) and c:IsAbleToRemoveAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_ONFIELD)
end

function s.op1filter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&(REASON_FUSION+REASON_MATERIAL))==(REASON_FUSION+REASON_MATERIAL) and c:GetReasonCard()==fusc and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE+FUSPROC_NOTFUSION)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=0
	if c:IsSummonType(SUMMON_TYPE_FUSION) then
		local mg=c:GetMaterial()
		ct=#mg-mg:FilterCount(s.op1filter,nil,e,tp,c,mg)
	end
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	if Duel.NegateEffect(ev) and ct>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
		Duel.BreakEffect()
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0 and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,e:GetHandler():GetMaterialCount())
	Duel.DisableShuffleCheck()
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end