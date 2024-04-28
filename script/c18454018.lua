--마과학천사 새턴
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"FTo","H")
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SEARCH)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_CUSTOM+id)
	WriteEff(e4,4,"N")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"FTo","M")
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetCL(1,{id,2})
	WriteEff(e5,5,"TO")
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_LEAVE_GRAVE)
	c:RegisterEffect(e6)
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
function s.tfil1(c)
	return c:IsAbleToRemove() and (c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsLoc("G"))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLoc("OG") and s.tfil1(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil1,tp,"OG","OG",1,nil)
			and Duel.GetLocCount(tp,"M")>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.STarget(tp,s.tfil1,tp,"OG","OG",1,1,nil)
	Duel.SOI(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.tfil2(c,tp)
	return c:IsSetCard("마과학") and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and not c:IsForbidden()
		and (Duel.GetLocCount(tp,"S")>0 or c:IsAbleToHand())
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil,tp)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,
			function(sc)
				return Duel.GetLocCount(tp,"S")>0
			end,
			function(sc)
				local e1=MakeEff(c,"S")
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				sc:RegisterEffect(e1)
				Duel.MoveToField(sc,tp,tp,LSTN("S"),POS_FACEUP,true)
			end,
			aux.Stringid(id,0)
		)
	end
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetType()&(TYPE_SPELL+TYPE_CONTINUOUS)==(TYPE_SPELL+TYPE_CONTINUOUS)
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLoc("OG") and s.tfil1(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil1,tp,"OG","OG",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.STarget(tp,s.tfil1,tp,"OG","OG",1,1,nil)
	Duel.SOI(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end