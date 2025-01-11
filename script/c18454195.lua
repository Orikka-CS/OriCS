--툰드라이터
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.pfil1,1,1)
	local e1=MakeEff(c,"SC")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SEARCH)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"F","M")
	e4:SetCode(EFFECT_DISABLE)
	e4:SetTR("M","M")
	e4:SetTarget(s.tar4)
	c:RegisterEffect(e4)
end
s.listed_names={15259703,43175858}
function s.pfil1(c,lc,sumtype,tp)
	return c:IsType(TYPE_TOON,lc,sumtype,tp) and not c:IsLink(1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.nfil2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(s.nfil3,tp,0,"M",1,nil)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.tfil3(c,tp)
	return c:IsCode(15259703,43175858) and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp,true,true))
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil,tp)
	end
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil,tp)
	local tc=g:GetFirst()
	aux.ToHandOrElse(tc,tp,function(c)
		local te=tc:GetActivateEffect()
		return te:IsActivatable(tp,true,true)
	end,
	function(c)
		if tc:IsCode(43175858) then
			Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
		else
			Duel.MoveToField(tc,tp,tp,LSTN("S"),POS_FACEUP,true)	
		end
	end,
	aux.Stringid(id,0))
end
function s.tar4(e,c)
	local h=e:GetHandler()
	return h:GetLinkedGroup():IsContains(c) and c:IsType(TYPE_EFFECT)
end