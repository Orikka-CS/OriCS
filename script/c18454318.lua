--프린세스자쿠
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddBraveProcedure(c,nil,2,6,aux.dncheck)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
s.custom_type=CUSTOMTYPE_BRAVE
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--not fully implemented
	return c:GetSummonLocation()&LSTN("E")==LSTN("E")
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local bz=aux.BurningZone[tp]
	local og=Group.CreateGroup()
	for i=1,#bz do
		og:AddCard(bz[i])
	end
	if chk==0 then
		return og:IsExists(Card.IsAbleToDeckAsCost,1,nil)
	end
	local tg=og:FilterSelect(tp,Card.IsAbleToDeckAsCost,1,1,nil)
	aux.EraseFromBurningZone(tg)
	Duel.SendtoDeck(tg,nil,1,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField()
	end
	if chk==0 then
		return Duel.IETarget(aux.TRUE,tp,"O","O",1,nil)
	end
	Duel.STarget(tp,aux.TRUE,tp,"O","O",1,1,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD,0,1,fid)
		c:SetCardTarget(tc)
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
		e1:SetLabel(fid)
		e1:SetCondition(s.ocon11)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=MakeEff(c,"FC")
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetLabelObject(tc)
		e2:SetOperation(s.oop12)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.ocon11(e)
	local owner=e:GetOwner()
	local handler=e:GetHandler()
	local fid=e:GetLabel()
	return owner:IsHasCardTarget(handler) and handler:GetFlagEffectLabel(id)==fid
end
function s.oop12(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsHasCardTarget(tc) then
		c:CancelCardTarget(tc)
	end
	e:Reset()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToExtraAsCost()
	end
	Duel.SendtoDeck(c,nil,2,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LSTN("D"),0)>0
	end
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.DisableShuffleCheck()
	local tc=Duel.GetFirstMatchingCard(Card.IsSequence,tp,LSTN("D"),0,nil,0)
	if tc then
		Duel.ConfirmCards(tp,tc)
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsSummonableCard() and (tc:IsAttribute(ATTRIBUTE_FIRE) or tc:IsType(TYPE_NORMAL)) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			local ttype=tc:GetType()
			tc:Type(ttype|TYPE_TOKEN)
			if Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
				if tc:GetLocation()==0 then
					table.insert(Auxiliary.BurningZone[tc:GetOwner()],tc)
					Auxiliary.BurningZoneTopCardOperation(e,tp,eg,ep,ev,re,r,rp)
				end
			end
			tc:Type(ttype)
		end
	end
end