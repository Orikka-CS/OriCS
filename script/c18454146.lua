--지금 이 노래, 너는 알고 있겠지
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S","M")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()	
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"Qo","M")
	e5:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e5,5,"CO")
	c:RegisterEffect(e5)
end
function s.vfil1(c)
	return c:IsSetCard("라일락") and c:IsType(TYPE_TRAP)
end
function s.val1(e)
	local tp=e:GetHandlerPlayer()
	return #Duel.GMGroup(s.vfil1,tp,"G",0,1,nil)*200
end
function s.tfil2(c)
	return c:IsSetCard("라일락") and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end
function s.cfil5(c,tp)
	return c:IsSetCard("라일락") and c:IsType(TYPE_TRAP) and c:IsFaceup() and c:IsAbleToGraveAsCost()
		and Duel.IEMCard(s.tfil5,tp,"D",0,1,nil,c:GetCode())
end
function s.tfil5(c,code)
	return c:IsSetCard("라일락") and c:IsType(TYPE_TRAP) and not c:IsCode(code)
end
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil5,tp,"O",0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil5,tp,"O",0,1,1,nil,tp)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetCode())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LSTN("D"),0)
	if ct==0 then
		return
	end
	if ct==1 then
		Duel.ConfirmDecktop(tp,1)
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SMCard(tp,s.tfil5,tp,"D",0,1,1,nil,e:GetLabel()):GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end