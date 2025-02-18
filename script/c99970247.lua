--[ S¢Óigma ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCL(1,id)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	e2:SetCost(aux.SelfBanishCost)
	c:RegisterEffect(e2)
	
end

function s.cost1fil(c)
	return c:IsSetCard(0x6d70) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost1fil,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cost1fil,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(0)
	if g:GetFirst():IsAttribute(ATT_L) then e:SetLabel(1) end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Destroy(g,REASON_EFFECT)
		if Duel.IsPlayerCanDraw(tp,1) 
			and e:GetLabel()==1
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

function s.matfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x6d70) and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.matfil2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c,tp)
end
function s.matfil2(c,mc,tp)
	return c:IsFaceup() and c:IsSetCard(0x6d70) and c:IsMonster() and c:IsCanBeXyzMaterial(mc,tp,REASON_EFFECT)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)	
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.SelectMatchingCard(tp,s.matfil2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil,tc,tp)
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and #g>0 then
		Duel.Overlay(tc,g)
	end
end
