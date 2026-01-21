--스큐드라스 드라스티치
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c,e)
	return (c:IsAbleToChangeControler() or not c:IsLocation(LOCATION_ONFIELD)) and not c:IsType(TYPE_TOKEN)
end

function s.tg1vfilter(c)
	return c:IsSetCard(0xf38) and c:IsType(TYPE_XYZ)
end

function s.tg1ofilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local vg=Duel.GetMatchingGroup(s.tg1vfilter,tp,LOCATION_MZONE,0,nil)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in mg:Iter() do
		local og=tc:GetOverlayGroup():Filter(s.tg1vfilter,nil)
		vg:Merge(og)
	end
	local ct=0
	if Duel.GetMatchingGroupCount(s.tg1filter,tp,0,LOCATION_HAND,nil)>0 then ct=ct+1 end
	if Duel.GetMatchingGroupCount(s.tg1filter,tp,0,LOCATION_ONFIELD,nil)>0 then ct=ct+1 end
	if Duel.GetMatchingGroupCount(s.tg1filter,tp,0,LOCATION_GRAVE,nil)>0 then ct=ct+1 end
	if chk==0 then return #vg>0 and ct>0 and Duel.GetMatchingGroupCount(s.tg1ofilter,tp,LOCATION_MZONE,0,nil)>0 end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local vg=Duel.GetMatchingGroup(s.tg1vfilter,tp,LOCATION_MZONE,0,nil)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local xg=Duel.GetMatchingGroup(s.tg1ofilter,tp,LOCATION_MZONE,0,nil)
	local g1=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_HAND,nil)
	local g2=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_ONFIELD,nil)
	local g3=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_GRAVE,nil)
	local ct=0
	if #g1>0 then ct=ct+1 end
	if #g2>0 then ct=ct+1 end
	if #g3>0 then ct=ct+1 end
	for tc in mg:Iter() do
		local og=tc:GetOverlayGroup():Filter(s.tg1vfilter,nil)
		vg:Merge(og)
	end
	local dt=math.min(vg:GetClassCount(Card.GetCode),ct)
	if dt==0 or #xg==0 then return end
	local sg=Group.CreateGroup()
	local b1=false
	local b2=false
	local b3=false
	local b4=false
	if #g1>0 then b1=true end
	if #g2>0 then b2=true end
	if #g3>0 then b3=true end
	local b
	for i=1,dt do
		if not (b1 or b2 or b3) then break end
		b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)},{b4,aux.Stringid(id,3)})
		if b==1 then
			local hg=g1:RandomSelect(tp,1)
			sg:Merge(hg)
			b1=false
			b4=true
		elseif b==2 then
			local fg=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
			sg:Merge(fg)
			b2=false
			b4=true
		elseif b==3 then
			local gg=aux.SelectUnselectGroup(g3,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
			sg:Merge(gg)
			b3=false
			b4=true
		else
			break
		end
	end
	local xsg=aux.SelectUnselectGroup(xg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP):GetFirst()
	Duel.Overlay(xsg,sg)
end

--effect 2
function s.tg2spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg2filter(c,e,tp)
	return c:IsSetCard(0xf38) and c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:GetOverlayGroup():FilterCount(s.tg2spfilter,nil,e,tp)>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	local g=tg:GetOverlayGroup():Filter(s.tg2spfilter,nil,e,tp)
	if tg and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end