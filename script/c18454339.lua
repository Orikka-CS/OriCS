--퍼스트쿼터 네가테
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","G")
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,{id,1})
	e2:SetCost(aux.bfgcost)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField() and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IETarget(Card.IsFaceup,tp,"O","O",1,c)
	end
	Duel.STarget(tp,Card.IsFaceup,tp,"O","O",1,1,c)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		if (tc:GetBaseAttack()==2500 or tc:GetBaseDefense()==2500) and tc:IsControler(tp) and tc:IsLoc("M") then
			local e1=MakeEff(c,"S")
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetDescription(3000)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=MakeEff(c,"S")
			e2:SetCode(EFFECT_IMMUNE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e2:SetDescription(3100)
			e2:SetValue(s.oval12)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		else
			local e3=MakeEff(c,"S")
			e3:SetCode(EFFECT_DISABLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetLabel(tp)
			e3:SetCondition(s.ocon13)
			tc:RegisterEffect(e3)
			local e4=MakeEff(c,"S")
			e4:SetCode(EFFECT_DISABLE_EFFECT)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetValue(RESET_TURN_SET)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e4:SetLabel(tp)
			e4:SetCondition(s.ocon13)
			tc:RegisterEffect(e4)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e5=MakeEff(c,"S")
				e5:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e5:SetLabel(tp)
				e5:SetCondition(s.ocon13)
				tc:RegisterEffect(e5)
			end
		end
	end
end
function s.oval12(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
function s.onfil13(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500)
end
function s.ocon13(e)
	local tp=e:GetLabel()
	return Duel.IEMCard(s.onfil13,tp,"MG",0,1,nil)
end
function s.tfil2(c,e,tp)
	return c:IsSetCard("퍼스트쿼터") and c:IsAbleToHand()
		and (c:IsAbleToHand() or (Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLoc("G") and s.tfil2(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"G",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.STarget(tp,s.tfil2,tp,"G",0,1,1,nil,e,tp)
	Duel.SPOI(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		aux.ToHandOrElse(tc,tp,
			function(sc)
				return sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocCount(tp,"M")>0
			end,
			function(sc)
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end,
			aux.Stringid(id,0)
		)
	end
end