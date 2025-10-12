TYPE_MODULE=0x40000000
CUSTOMTYPE_SQUARE=0x1
CUSTOMTYPE_EQUATION=0x2
CUSTOMTYPE_BEYOND=0x4
CUSTOMTYPE_DELIGHT=0x8
CUSTOMTYPE_EQUAL=0x10
CUSTOMTYPE_ORDER	=0x20
CUSTOMTYPE_SEQUENCE=0x20
CUSTOMTYPE_SKULL=0x40
CUSTOMTYPE_DIFFUSION=0x4000
CUSTOMTYPE_BRAVE=0x40000000
--유리 장벽
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	return true
end
function s.revfilter(c)
	return c:IsType(TYPE_MODULE) or c:IsCustomType(CUSTOMTYPE_SQUARE) or c:IsCustomType(CUSTOMTYPE_EQUATION) or c:IsCustomType(CUSTOMTYPE_BEYOND)
			or c:IsCustomType(CUSTOMTYPE_DELIGHT) or c:IsCustomType(CUSTOMTYPE_EQUAL) or (c.CardType_Order) or (c:IsCustomType(CUSTOMTYPE_SEQUENCE) and not c.CardType_Order)
			or c:IsCustomType(CUSTOMTYPE_SKULL) or c:IsCustomType(CUSTOMTYPE_DIFFUSION) or c:IsCustomType(CUSTOMTYPE_BRAVE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local res=e:GetLabel()==-1 and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil)
		e:SetLabel(0)
		return res
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,rc)
	local b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11=false
	if rc:IsType(TYPE_MODULE) then b1=true end
	if rc:IsCustomType(CUSTOMTYPE_SQUARE) then b2=true end
	if rc:IsCustomType(CUSTOMTYPE_EQUATION) then b3=true end
	if rc:IsCustomType(CUSTOMTYPE_BEYOND) then b4=true end
	if rc:IsCustomType(CUSTOMTYPE_DELIGHT) then b5=true end
	if rc:IsCustomType(CUSTOMTYPE_EQUAL) then b6=true end
	if rc.CardType_Order then b7=true end
	if rc:IsCustomType(CUSTOMTYPE_SEQUENCE) and not rc.CardType_Order then b8=true end
	if rc:IsCustomType(CUSTOMTYPE_SKULL) then b9=true end
	if rc:IsCustomType(CUSTOMTYPE_DIFFUSION) then b10=true end
	if rc:IsCustomType(CUSTOMTYPE_BRAVE) then b11=true end
	if rc:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
	elseif rc:IsLocation(LOCATION_EXTRA) then
		Duel.ShuffleExtra(tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)},{b3,aux.Stringid(id,3)},{b4,aux.Stringid(id,4)},
						{b5,aux.Stringid(id,5)},{b6,aux.Stringid(id,6)},{b7,aux.Stringid(id,7)},{b8,aux.Stringid(id,8)},
						{b9,aux.Stringid(id,9)},{b10,aux.Stringid(id,10)},{b11,aux.Stringid(id,11)})
	Duel.SetTargetParam(op)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local ct=nil
	if opt==1 then ct=TYPE_MODULE end
	if opt==2 then ct=CUSTOMTYPE_SQUARE end
	if opt==3 then ct=CUSTOMTYPE_EQUATION end
	if opt==4 then ct=CUSTOMTYPE_BEYOND end
	if opt==5 then ct=CUSTOMTYPE_DELIGHT end
	if opt==6 then ct=CUSTOMTYPE_EQUAL end
	if opt==7 then ct=1557 end
	if opt==8 then ct=1601 end
	if opt==9 then ct=CUSTOMTYPE_SKULL end
	if opt==10 then ct=CUSTOMTYPE_DIFFUSION end
	if opt==11 then ct=CUSTOMTYPE_BRAVE end
	--Cannot Special Summon monsters of the declared type
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.sumlimit)
	e1:SetLabel(ct)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Negate the effects of monsters of that type while on the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.sumlimit)
	e2:SetLabel(ct)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local declared_type=e:GetLabel()
	if declared_type==TYPE_MODULE then
		return c:IsType(declared_type)
	elseif declared_type==1557 then
		return c.CardType_Order
	elseif declared_type==1601 then
		return c:IsCustomType(CUSTOMTYPE_SEQUENCE) and not c.CardType_Order
	else
		return c:IsCustomType(declared_type)
	end
end