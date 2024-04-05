--트리아드나 라티아
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsAttribute),ATTRIBUTE_EARTH))
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(aux.TargetBoolFunction(aux.FaceupFilter(Card.IsCode,87979586)))
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.con4)
	e4:SetCost(s.cost4)
	e4:SetTarget(s.tar4)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
end
s.listed_names={87979586}
function s.nfil1(c,e,tp)
	return c:IsCode(87979586) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.con1(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	local rg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c)
	return #rg>=1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
		and Duel.IsExistingMatchingCard(s.nfil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c,og)
	--cost
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local rg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c)
	local dg=aux.SelectUnselectGroup(rg,e,tp,(Duel.IsSummonCancelable() and 0 or 1),1,aux.ChkfMMZ(2),1,tp,HINTMSG_DISCARD,nil,nil,true)
	if #dg==0 then return end
	Duel.SendtoGrave(dg,REASON_DISCARD+REASON_COST)
	--spsummon
	local tg=Group.FromCards(c)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	tg:Merge(Duel.SelectMatchingCard(tp,s.nfil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp))
	for tc in tg:Iter() do
		local pos=0
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp) then pos=pos|POS_FACEUP_DEFENSE end
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,tp) then pos=pos|POS_FACEDOWN_DEFENSE end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_COST)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabel(pos)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_MZONE,e:GetLabel(),false)
			e:GetHandler():SetStatus(STATUS_SUMMONING,true)
			e:Reset()
		end)
		tc:RegisterEffect(e1)
		og:Merge(tc)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return (re:IsActiveType(TYPE_MONSTER) and rc:IsAttribute(ATTRIBUTE_EARTH)) or rc:IsSetCard(0xfa3)
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsFacedown() and c:IsCanChangePosition()
	end
	Duel.ChangePosition(c,POS_FACEUP_ATTACK)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,1,nil)
		if Duel.Destroy(sg,REASON_EFFECT)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Recover(tp,500,REASON_EFFECT)
		end
	end
end