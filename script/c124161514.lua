--페를라렌트 퀘스터 가이우스
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf41),aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT))
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.PayLP(700))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,124161508,0xf41,TYPES_TOKEN,700,700,2,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_FACEUP,tp)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,124161508,0xf41,TYPES_TOKEN,700,700,2,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_FACEUP,1-tp)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,1) and (b1 or b2) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanSpecialSummonCount(tp,1) then return end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,124161508,0xf41,TYPES_TOKEN,700,700,2,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_FACEUP,tp)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,124161508,0xf41,TYPES_TOKEN,700,700,2,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_FACEUP,1-tp)
	if b1 or b2 then
		local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
		local token=Duel.CreateToken(tp,124161508)
		if op==1 then
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end

--effect 2
function s.tg2eqfilter(c,tc)
	return c:GetEquipTarget()==tc
end

function s.tg2hfilter(c)
	return not c:IsAbleToHand()
end

function s.tg2filter(c,eg)
	local g=c:GetEquipGroup()
	return c:IsFaceup() and c:IsAbleToHand() and eg:IsExists(s.tg2eqfilter,1,nil,c) and not g:IsExists(s.tg2hfilter,1,nil)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,eg)
	if chk==0 then return #g>0 end
	local rg=Group.CreateGroup()
	for tc in g:Iter() do
		rg:Merge(tc:GetEquipGroup())
		rg:AddCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,rg,#rg,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,eg)
	if #g>0 then
		local rg=Group.CreateGroup()
		for tc in g:Iter() do
			rg:Merge(tc:GetEquipGroup())
			rg:AddCard(tc)
		end
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end