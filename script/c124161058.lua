--무한검 언엔달
local s,id=GetID()
function s.initial_effect(c)
	--activate
	aux.AddEquipProcedure(c,0)
	--effect 1
	c:SetUniqueOnField(LOCATION_ONFIELD,0,id)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCost(s.cst3)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	--equip count
	aux.GlobalCheck(s,function()
		local cnt=Effect.CreateEffect(c)
		cnt:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		cnt:SetCode(EVENT_EQUIP)
		cnt:SetOperation(s.cnt)
		Duel.RegisterEffect(cnt,0)
	end)
end
--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsCode(124161058) then Duel.RegisterFlagEffect(rp,id,0,0,1) end
	end
end

--effect 2
function s.val2(e)
	return Duel.GetFlagEffect(e:GetHandler():GetControler(),id)*500
end

--effect 3
function s.cst3filter(c)
	return c:IsAbleToGraveAsCost()
end

function s.cst3(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_MZONE,0,nil,e)
	if #tg>1 then tg=nil end
	local g=Duel.GetMatchingGroup(s.cst3filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,tg)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.tg3filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.unendalf(c)
	return c:IsCode(124161058) and c:IsFaceup()
end

function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg3filter(chck,e) end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_MZONE,0,nil,e) 
	if chk==0 then return c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #g>0 and not Duel.IsExistingMatchingCard(s.unendalf,tp,LOCATION_ONFIELD,0,1,nil) end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if c:IsRelateToEffect(e) and tg and tg:IsFaceup() and c:CheckUniqueOnField(tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not Duel.IsExistingMatchingCard(s.unendalf,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.Equip(tp,c,tg)
	end
end
