--[ S¢Óigma ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.matfilter,1,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)

	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"I","M")
	e3:SetD(id,0)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCL(1,id)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	
end

function s.matfilter(c,xyz,sumtype,tp)
	return c:IsSetCard(0x6d70,xyz,sumtype,tp) and c:IsAttribute(ATT_D,xyz,sumtype,tp)
end
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(0x6d70,xyzc,SUMMON_TYPE_XYZ,tp)
	   and c:IsAttribute(ATT_L,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end

function s.atkval(e,c)
	return math.abs(Duel.GetLP(1)-Duel.GetLP(0))
end

function s.tar3fil(c)
	return c:IsSetCard(0x6d70) and c:IsAbleToDeck() and c:IsFaceup()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tar3fil(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(s.tar3fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tar3fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)==0 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
