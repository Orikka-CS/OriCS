--항상 네 곁엔 내가 서 있기를
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
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
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
	local b1=Duel.IEMCard(s.onfil21,tp,0,"M",1,nil)
	local ne,np=nil,nil
	if cc-1>0 then
		ne,np=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	end
	local b2=cc-1>0 and Duel.IsChainNegatable(cc-1) and ne and ne:IsActiveType(TYPE_MONSTER) and np~=tp
	return Duel.GetFlagEffect(tp,id)==0 and (b1 or b2)
end
function s.oop21(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IEMCard(s.onfil21,tp,0,"M",1,nil)
	local cc=Duel.GetCurrentChain()
	local ne,np=nil,nil
	if cc-1>0 then
		ne,np=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	end
	local b2=cc-1>0 and Duel.IsChainNegatable(cc-1) and ne and ne:IsActiveType(TYPE_MONSTER) and np~=tp
	if not (b1 or b2) then
		return
	end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		return
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})	
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SMCard(tp,s.onfil21,tp,0,"M",1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==2 then
		local nc=ne:GetHandler()
		if Duel.NegateActivation(cc-1) and nc:IsRelateToEffect(ne) then
			Duel.Destroy(nc,REASON_EFFECT)
		end
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