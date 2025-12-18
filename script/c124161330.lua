--스노위퍼 크라일 XV
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,5,2)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(Cost.DetachFromSelf(1,1,nil))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FORCE_MZONE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(function(e) return e:GetHandler():GetSequence()==0 or e:GetHandler():GetSequence()==4 end)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--xyz
function s.xyzfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_MACHINE,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_WATER,lc,sumtype,tp)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_MMZONE,0)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.TRUE,0) end
end

function s.op1filter(c)
	return c:GetSequence()==0 or c:GetSequence()==4
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MMZONE,0)
	if #g==0 then return end
	local swap_g=aux.SelectUnselectGroup(g,e,tp,2,2,aux.TRUE,1,tp,HINTMSG_TOZONE)
	if #swap_g~=2 then return end
	Duel.SwapSequence(swap_g:GetFirst(),swap_g:GetNext())
	local ct=Duel.GetMatchingGroupCount(s.op1filter,tp,0,LOCATION_ONFIELD,nil)
	local cg=Duel.GetMatchingGroup(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,nil)
	if ct>0 and #cg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		local csg=aux.SelectUnselectGroup(cg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL)
		Duel.GetControl(csg,tp)
	end
end

--effect 2
function s.val2(e,c,fp,rp,r)
	local seq=e:GetHandler():GetSequence()
	if seq==0 then
		return 0x1
	else
		return 0x10
	end
end