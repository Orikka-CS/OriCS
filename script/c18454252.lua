--功力狼 捞档累屈
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCL(1,id)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_MOVE)
	WriteEff(e4,4,"N")
	c:RegisterEffect(e4)
end
function s.cfil1(c)
	return c:IsSetCard("功力") and (c:IsAbleToGraveAsCost() or c:IsAbleToRemoveAsCost())
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"HO",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"HO",0,1,1,c)
	local tc=g:GetFirst()
	if tc:IsAbleToGraveAsCost() and (not tc:IsAbleToRemoveAsCost() or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.SendtoGrave(tc,REASON_COST)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,2)
	end
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,2,REASON_EFFECT)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTR(1,0)
	e1:SetValue(2)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,1)
	Duel.RegisterEffect(e1,tp)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LSTN("R")) and c:IsLoc("G")
end