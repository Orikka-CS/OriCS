--마과학괴도 카이
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","M")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetD(id,0)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetD(id,1)
	e2:SetCL(1,id)
	WriteEff(e2,1,"C")
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTf","M")
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GMGroup(Card.IsType,tp,"O","O",nil,TYPE_SPELL+TYPE_TRAP)
	local tc=g:GetFirst()
	local eventg=Group.CreateGroup()
	while tc do
		if tc:GetFlagEffect(id*10)==0 then
			tc:RegisterFlagEffect(id*10,RESET_EVENT+RESETS_STANDARD,0,0)
			if tc:GetPreviousLocation()&LOCATION_HAND==0 then
				eventg:AddCard(tc)
				Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+id,e,0,0,0,0)
			end
		end
		tc=g:GetNext()
	end
	if #eventg>0 then
		Duel.RaiseEvent(eventg,EVENT_CUSTOM+id,e,0,0,0,0)
	end
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsControlerCanBeChanged()
	end
	local ct=1
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		ct=2
	end
	Duel.GetControl(c,1-tp,PHASE_STANDBY,1)
end
function s.tfil1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsLoc("OG") and s.tfil1(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil1,tp,0,"OG",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.STarget(tp,s.tfil1,tp,0,"OG",1,1,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsLoc("F") and tc:IsControler(1-tp) then
			Duel.MoveToField(tc,tp,tp,LSTN("F"),POS_FACEDOWN,true)
		elseif tc:IsLoc("S") and tc:IsControler(1-tp) then
			Duel.MoveToField(tc,tp,tp,LSTN("S"),POS_FACEDOWN,true)
		else
			Duel.SSet(tp,tc)
		end
	end
end
function s.tfil2(c)
	return c:IsSetCard("마과학") and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and not c:IsForbidden()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
			and Duel.GetLocCount(tp,"S")>0
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocCount(tp,"S")<1 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		Duel.MoveToField(tc,tp,tp,LSTN("S"),POS_FACEUP,true)
	end
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,"D")
end
function s.ofil3(c,e,tp)
	return c:IsSetCard("마과학") and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local spsum=0
	if Duel.GetLocCount(tp,"M")>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SMCard(tp,s.ofil3,tp,"D",0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
			spsum=spsum+1
		end
	end
	if Duel.GetLocCount(1-tp,"M")>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local g=Duel.SMCard(1-tp,s.ofil3,1-tp,"D",0,1,1,nil,e,1-tp)
		if #g>0 then
			Duel.SpecialSummonStep(g:GetFirst(),0,1-tp,1-tp,false,false,POS_FACEUP)
			spsum=spsum+1
		end
	end
	if spsum>0 then
		Duel.SpecialSummonComplete()
	end
end