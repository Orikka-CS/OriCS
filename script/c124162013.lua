--무한검 언엔달
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,nil,function(e,mc) return mc:IsControler(e:GetHandlerPlayer()) end)
	--effect 1
	c:SetUniqueOnField(1,0,id)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCost(s.cst3)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_EQUIP)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsCode(id) and tc:GetEquipTarget() then
			Duel.RegisterFlagEffect(tc:GetControler(),id,0,0,1)
		end
	end
end

--effect 2
function s.val2(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)*500
end

--effect 3
function s.cst3filter(c,tp,ec)
	local ct=Duel.GetMatchingGroupCount(s.tg3filter,tp,LOCATION_MZONE,0,c,ec)
	return c:IsAbleToGraveAsCost() and ct>0 and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or (c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5))
end
function s.cst3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst3filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,tp,e:GetHandler())
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.tg3filter(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_MZONE,0,nil,c)
	if chk==0 then return #g>0 and c:CheckUniqueOnField(tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_MZONE,0,nil,c)
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) and #g>0 and c:CheckUniqueOnField(tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		Duel.Equip(tp,c,sg)
	end
end
