--르블랑 잔느
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
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
	local e4=MakeEff(c,"STo")
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCategory(CATEGORY_CONTROL)
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)
end
function s.nfil1(c,tp)
	return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToChangeControler()
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(1-tp,"M",tp,LOCATION_REASON_CONTROL)>0
		and Duel.IEMCard(s.nfil1,tp,"M",0,1,nil,tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SMCard(tp,s.nfil1,tp,"M",0,0,1,nil,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.GetControl(g,1-tp)
	g:DeleteGroup()
end
function s.val2(e,re,tp)
	local rc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and not rc:IsSetCard("르블랑") and re:IsActiveType(TYPE_TRAP)
end
function s.con3(e)
	return Duel.IsBattlePhase()
end
function s.val3(e,c)
	local handler=e:GetHandler()
	return handler:GetOwner()
end
function s.tfil4(c)
	return c:IsAbleToChangeControler() and (c:GetSequence()<5 or Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil4,tp,"M",0,1,nil)
			and Duel.IEMCard(s.tfil4,tp,0,"M",1,nil)
	end
	Duel.SOI(0,CATEGORY_CONTROL,nil,0,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (Duel.IEMCard(s.tfil4,tp,"M",0,1,nil)
		and Duel.IEMCard(s.tfil4,tp,0,"M",1,nil)) then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g1=Duel.SMCard(tp,s.tfil4,tp,"M",0,1,1,nil)
	Duel.HintSelection(g1)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)
	local g2=Duel.SMCard(1-tp,s.tfil4,1-tp,"M",0,1,1,nil)
	Duel.HintSelection(g2)
	local c1=g1:GetFirst()
	local c2=g2:GetFirst()
	Duel.SwapControl(c1,c2,0,0)
end