--언엔달 데스포티스 헬베르트
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,8,2,s.ovfilter,0,2,s.ovop)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.Detach(1,1,nil))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--xyz
function s.ovffilter(c,tp)
	return c:IsCode(124161058) and c:IsControler(tp)
end

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsCanBeXyzMaterial() and c:IsControler(tp) and c:IsSetCard(0xf23) and c:GetEquipGroup():IsExists(s.ovffilter,1,nil,tp)
end

function s.ovop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsCanBeEffectTarget(e) end
	local eq=Duel.GetFlagEffect(tp,124161058)
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g>0 and eq>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,eq,aux.TRUE,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():GetEquipGroup():IsExists(s.ovffilter,1,nil,tp) then return false end
	local rc=re:GetHandler()
	return rp==1-tp and rc:IsOnField() and rc:IsRelateToEffect(re)
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsControler(1-tp) and c:IsRelateToEffect(e) and c:IsType(TYPE_XYZ) and not rc:IsImmuneToEffect(e) then
		rc:CancelToGrave()
		Duel.Overlay(c,rc,true)
	end
end
