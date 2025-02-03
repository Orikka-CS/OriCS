--당연한 듯 항상 내 옆엔 네가 있었어
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"SC")
	e2:SetCode(EVENT_TO_GRAVE)
	WriteEff(e2,2,"NO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"Qo","G")
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetCL(1,{id,1})
	e3:SetCondition(aux.exccon)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDiscardDeck(tp,4)
	end
	Duel.SOI(0,CATEGORY_DECKDES,nil,0,tp,4)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re then
		return false
	end
	local rc=re:GetHandler()
	return rc:IsSetCard("라일락") and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LSTN("D"))
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)>0 then
		return
	end
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_LILAC_ADDOP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTR(1,0)
	e1:SetLabel(Duel.GetCurrentChain())
	e1:SetReset(RESET_CHAIN)
	e1:SetCondition(s.ocon21)
	e1:SetOperation(s.oop21)
	Duel.RegisterEffect(e1,tp)
end
function s.onfil21(c)
	return c:IsSetCard("라일락") and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.ocon21(e)
	local tp=e:GetHandlerPlayer()
	local cc=Duel.GetCurrentChain()
	if cc==0 then
		return false
	end
	if cc~=e:GetLabel() then
		return false
	end
	local b1=Duel.IsPlayerCanDiscardDeck(tp,2)
	local b2=Duel.IEMCard(s.onfil21,tp,"D",0,1,nil)
	return Duel.GetFlagEffect(tp,id)==0 and (b1 or b2)
end
function s.oop21(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsPlayerCanDiscardDeck(tp,2)
	local b2=Duel.IEMCard(s.onfil21,tp,"D",0,1,nil)
	if not (b1 or b2) then
		return
	end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		return
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})	
	if op==1 then
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local tc=Duel.SMCard(tp,s.onfil21,tp,"D",0,1,1,nil):GetFirst()
		if tc then
			Duel.SSet(tp,tc)
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0,fid)
			local e1=MakeEff(c,"FC")
			e1:SetCode(EVENT_CHAIN_SOLVING)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetOperation(s.ooop211)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.ooop211(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	local rc=re:GetHandler()
	if tc:GetFlagEffectLabel(id)==fid and rc==tc and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and rc:IsRelateToEffect(re) then
		rc:CancelToGrave()
		Duel.SendtoDeck(rc,nil,0,REASON_EFFECT)
		e:Reset()
	end
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck()
	end
	Duel.SOI(0,CATEGORY_TODECK,c,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,0,REASON_EFFECT)
	end
end