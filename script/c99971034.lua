--[ Deadmoon ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"I","H")
	e1:SetCL(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetCost(Cost.AND(Cost.SelfDiscard,s.cost1))
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e3=MakeEff(c,"Qo","G")
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"CTO")
	c:RegisterEffect(e3)

	local e4=MakeEff(c,"I","S")
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCL(1)
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)

end

function s.cost1f(c)
	return c:IsST() and c:IsSetCard(0x9d71) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,true)~=nil
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.cost1f,tp,LOCATION_DECK,0,nil)
		e:SetLabelObject(g)
		return #g>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=e:GetLabelObject():Select(tp,1,1,nil):GetFirst()
	e:SetLabelObject(sc)
	Duel.SendtoGrave(sc,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te,ceg,cep,cev,cre,cr,crp=table.unpack(e:GetLabelObject())
		return te and te:GetTarget() and te:GetTarget()(e,tp,ceg,cep,cev,cre,cr,crp,chk,chkc)
	end
	if chk==0 then
		local res=e:GetLabel()==-100
		e:SetLabel(0)
		return res
	end
	local sc=e:GetLabelObject()
	local te,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		e:SetProperty(te:GetProperty())
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
		Duel.ClearOperationInfo(0)
	end
	e:SetLabel(0)
	e:SetLabelObject({te,ceg,cep,cev,cre,cr,crp})
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local te,ceg,cep,cev,cre,cr,crp=table.unpack(e:GetLabelObject())
	if not te then return end
	local op=te:GetOperation()
	if op then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		op(e,tp,ceg,cep,cev,cre,cr,crp)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end

function s.cost3f(c,tp,ft)
	return c:IsAbleToGraveAsCost() and c:IsOriginalType(TYPE_MONSTER) and (ft>0 or (c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5))
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,1,c)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost3f,tp,LOCATION_ONFIELD,0,1,nil,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost3f,tp,LOCATION_ONFIELD,0,1,1,nil,tp,ft)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_SZONE)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not ec then return end
	Duel.HintSelection(ec,true)
	if Duel.Equip(tp,c,ec,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e1:SetLabelObject(ec)
		c:RegisterEffect(e1)
		if c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_DECK,1,nil) or Duel.IsPlayerCanSpecialSummon(tp))
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT,OPCODE_AND}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,ac)
	if #g<1 then return end
	local tc=g:Select(1-tp,1,1,nil):GetFirst()
	if tc then
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,1-tp,true,false,POS_FACEUP,1-tp) then
			Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
