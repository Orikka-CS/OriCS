--¸£ºí¶û ÆÒÅÒ
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","M")
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,0)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S","M")
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.con3)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetCL(1)
	WriteEff(e4,4,"NCTO")
	c:RegisterEffect(e4)
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(1-tp,"M")>=2 and Duel.GetLocCount(tp,"M")>0
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,18454142,0,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	for i=1,2 do
		local token=Duel.CreateToken(tp,18454142)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SpecialSummonComplete()
end
function s.val2(e,re,tp)
	local rc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and not rc:IsSetCard("¸£ºí¶û") and re:IsActiveType(TYPE_SPELL)
end
function s.con3(e)
	return Duel.IsBattlePhase()
end
function s.val3(e,c)
	local handler=e:GetHandler()
	return handler:GetOwner()
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.GetFieldGroupCount(tp,LSTN("M"),0)<=Duel.GetFieldGroupCount(tp,0,LSTN("M"))-2
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToChangeControler() and Duel.GetLocCount(1-tp,"M",tp,LOCATION_REASON_CONTROL)>0
	end
	Duel.GetControl(c,1-tp)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLoc("M") and chkc:IsControler(1-tp) and chkc~=c and chkc:IsAbleToChangeControler()
	end
	if chk==0 then
		local ct=2
		if c:GetSequence()<5 then
			ct=1
		end
		return Duel.GetLocCount(tp,"M",tp,LOCATION_REASON_CONTROL)>=ct
			and Duel.IETarget(Card.IsAbleToChangeControler,tp,0,"M",2,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.STarget(tp,Card.IsAbleToChangeControler,tp,0,"M",2,2,c)
	Duel.SOI(0,CATEGORY_CONTROL,g,2,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsControler,nil,1-tp)
	if #g>0 then
		Duel.GetControl(g,tp)
	end
end