--아크브릿지버스터 밀비안
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,5,3,s.ovfilter,0,Xyz.InfiniteMats,s.ovop)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--xyz
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0xf3e) and c:IsType(TYPE_XYZ) and c:IsRank(4) and c:IsControler(tp) and c:IsCanBeXyzMaterial(lc)
end

function s.ovop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end

--effect 1
function s.tg1ctfilter(c)
	return c:IsSetCard(0xf3e) and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.tg1ctfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=ct end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,ct,1-tp,LOCATION_DECK)
end

function s.op1filter(c,e)
	return not c:IsType(TYPE_TOKEN) and not c:IsImmuneToEffect(e)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.tg1ctfilter,tp,LOCATION_ONFIELD,0,nil)
	ct=math.min(ct,Duel.GetFieldGroupCount(tp,0,LOCATION_DECK))
	if c:IsRelateToEffect(e) and ct>0 then
		Duel.DisableShuffleCheck()
		local g=Duel.GetDecktopGroup(1-tp,ct)
		Duel.Overlay(c,g)
		local og=Duel.GetMatchingGroup(s.op1filter,tp,0,LOCATION_ONFIELD,nil,e)
		if c:GetOverlayCount()>3 and #og>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local osg=aux.SelectUnselectGroup(og,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
			Duel.Overlay(c,osg)
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsMonster() and c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=eg:FilterCount(s.con2filter,nil,tp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local og=c:GetOverlayGroup()
	local mx=math.min(ct,#g,#og)
	if chk==0 then return mx>0 end
	local sg=aux.SelectUnselectGroup(og,e,tp,1,mx,aux.TRUE,1,tp,HINTMSG_REMOVE)
	e:SetLabel(#sg)
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.tg2filter(c)
	return c:IsAbleToRemove()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if #g>0 and ct>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.TRUE,1,tp,HINTMSG_REMOVE)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end