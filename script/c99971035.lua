--[ Deadmoon ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	aux.AddModuleProcedure(c,aux.FBF(Card.IsModuleCode,99971031),aux.FBF(Card.IsOriginalType,TYPE_MONSTER),2,5,nil)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(99971031)
	c:RegisterEffect(e1)
	
	local e3=MakeEff(c,"Qo","M")
	e3:SetD(id,1)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetCode(EVENT_CHAINING)
	WriteEff(e3,3,"NCTO")
	c:RegisterEffect(e3)
	
	local e4=MakeEff(c,"FC","M")
	e4:SetCode(EVENT_ADJUST)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
	
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.cost3f(c,g)
	return c:IsAbleToGraveAsCost() and g:IsContains(c)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=e:GetHandler():GetEquipGroup()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost3f,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost3f,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,g)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateEffect(ev) and c:IsRelateToEffect(e) and c:IsControler(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		if seq then
			Duel.MoveSequence(c,math.log(seq,2))
		end
	end
end

function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	local g=Duel.GetMatchingGroup(function(c,col) return c:IsCanTurnSet() and col:IsContains(c) end,tp,0,LOCATION_MZONE,nil,cg)
	if #g>0 then 
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
