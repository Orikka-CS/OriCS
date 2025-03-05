--퍼스트쿼터 피트흐
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","G")
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetCL(1,{id,1})
	e2:SetCost(aux.bfgcost)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
end
function s.tfil1(c,e,tp)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and
		(c:IsAbleToGrave()
			or (Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"H",0,1,nil,e,tp)
	end
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"H")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,s.tfil1,tp,"H",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local b1=Duel.GetLocCount(tp,"M")>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local b2=tc:IsAbleToGrave()
		local res=nil
		local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b1,aux.Stringid(id,2)})
		if op==1 then
			res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif op==2 then
			res=Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		if not res then
			return
		end
		local val=0
		if tc:GetBaseAttack()==2500 then
			val=val+1
		end
		if tc:GetBaseDefense()==2500 then
			val=val+1
		end
		if val and Duel.IsPlayerCanDraw(tp,val) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Draw(tp,val,REASON_EFFECT)
		end
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTR("M",0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.otar21)
	e1:SetValue(1250)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetTarget(s.otar22)
	Duel.RegisterEffect(e2,tp)
end
function s.otar21(e,c)
	return c:GetBaseAttack()==2500
end
function s.otar22(e,c)
	return c:GetBaseDefense()==2500
end