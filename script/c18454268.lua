--음유사신 종글구울
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_SUMMON_COST)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,id)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","G")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetCL(1,id)
	e4:SetCost(aux.bfgcost)
	WriteEff(e4,4,"NTO")
	c:RegisterEffect(e4)
end
s.listed_names={66429798}
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetMaterialCount()==0 then
		local e1=MakeEff(c,"S","M")
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
		e1:SetValue(-500)
		c:RegisterEffect(e1)
	end
end
function s.tfil2(c,e,tp)
	return c:IsFaceup() and (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not c:IsCode(id)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("GR") and chkc:IsControler(tp) and s.tfil2(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and Duel.IETarget(s.tfil2,tp,"GR",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil2,tp,"GR",0,1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0
		and c:IsRelateToEffect(e) and c:IsFaceup() and c:HasLevel() and tc:HasLevel()
		and Duel.GetFieldGroupCount(tp,LSTN("G"),0)>=25
		and Duel.GetFieldGroupCount(tp,0,LSTN("G"))>=25 then
		local b1=true
		local b2=c:GetLevel()~=tc:GetLevel()
		local b3=true
		local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)})
		if op==2 then
			local e1=MakeEff(c,"S","M")
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(tc:GetLevel())
			c:RegisterEffect(e1)
		elseif op==3 then
			local sum=c:GetLevel()+tc:GetLevel()
			local e1=MakeEff(c,"S","M")
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(sum)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			tc:RegisterEffect(e2)
		end
	end
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return (Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2))
		or (Duel.GetTurnPlayer()~=tp and (ph>PHASE_MAIN1 and ph<PHASE_MAIN2))
end
function s.tfil4(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCode(66429798) and c:IsFaceup()
		and (c:IsAbleToHand() or (Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)))
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("GR") and chkc:IsControler(tp) and s.tfil4(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil4,tp,"G",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.STarget(tp,s.tfil4,tp,"GR",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc:IsLoc("G") then
		Duel.SOI(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
	Duel.SPOI(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)	
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		aux.ToHandOrElse(tc,tp,
			function(sc)
				return sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and Duel.GetLocCount(tp,"M")>0
			end,
			function(sc)
			return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end,
			aux.Stringid(id,3)
		)
	end
end