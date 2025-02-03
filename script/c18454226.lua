--검성(블레이드 고스텔라)-해방의 니르바나
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"SC","S")
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetTarget(s.tar1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"A")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_RECOVER)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S")
	e3:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"S")
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(s.val4)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"FC","S")
	e5:SetCode(EVENT_ADJUST)
	WriteEff(e5,5,"O")
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"E")
	e6:SetCode(EFFECT_UPDATE_LEVEL)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetValue(300)
	c:RegisterEffect(e7)
	local e8=MakeEff(c,"I","G")
	e8:SetCategory(CATEGORY_TOHAND)
	WriteEff(e8,8,"CTO")
	c:RegisterEffect(e8)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReason(REASON_LOST_TARGET)
	end
	return true
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,300)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	Duel.Recover(tp,300,REASON_EFFECT)
	c:Type(TYPE_SPELL)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(TYPE_SPELL+TYPE_EQUIP)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC")
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetCL(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetLabelObject(e1)
	e2:SetOperation(s.oop22)
	Duel.RegisterEffect(e2,tp)
	local e3=MakeEff(c,"F")
	e3:SetCode(EFFECT_GHOSTELLAR)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTR(1,0)
	Duel.RegisterEffect(e3,tp)
end
function s.oop22(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local te=e:GetLabelObject()
	c:Type(TYPE_SPELL+TYPE_EQUIP)
	te:Reset()
	e:Reset()
end
function s.val4(e,c)
	return c:IsSetCard("고스텔라")
end
function s.ofil5(c)
	return c:IsSetCard("고스텔라") and c:IsFaceup()
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SMCard(tp,s.ofil5,tp,"M","M",1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.Equip(tp,c,tc)
		end
	end
end
function s.cfil8(c)
	return c:IsSetCard("고스텔라") and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
function s.cost8(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil8,tp,"G",0,2,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SMCard(tp,s.cfil8,tp,"G",0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tar8(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand()
	end
	Duel.SOI(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.op8(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end