--왕립 보안도서관
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IETarget(s.tfil1,tp,"O",0,1,c)
	local b2=Duel.IETarget(aux.TRUE,tp,"O","O",1,c)
	local b3=Duel.IETarget(Card.IsNegatable,tp,"O","O",1,c)
	if chkc then
		return false
	end
	if chk==0 then
		if e:GetLabel()~=1 then
			return false
		end
		e:SetLabel(0)
		return (b1 or b2 or b3) and Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,1,REASON_COST)
	end
	e:SetLabel(0)
	local ct=1
	for i=2,3 do
		if Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,ct,REASON_COST) then
			ct=i
		end
	end
	local ect=(b1 and 1 or 0)+(b2 and 1 or 0)+(b3 and 1 or 0)
	if ect<ct then
		ct=ect
	end
	local tct={}
	for i=1,ct do
		table.insert(tct,i)
	end
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local ac=Duel.AnnounceNumber(tp,table.unpack(tct))
	Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,ac,REASON_COST)
	local sel=0
	local off=0
	repeat
		local ops={}
		local opval={}
		off=1
		if b1 then
			ops[off]=aux.Stringid(id,0)
			opval[off-1]=1
			off=off+1
		end
		if b2 then
			ops[off]=aux.Stringid(id,1)
			opval[off-1]=2
			off=off+1
		end
		if b3 then
			ops[off]=aux.Stringid(id,2)
			opval[off-1]=3
			off=off+1
		end
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			sel=sel+1
			b1=false
		elseif opval[op]==2 then
			sel=sel+2
			b2=false
		else
			sel=sel+4
			b3=false
		end
		ac=ac-1
	until ac==0
	local tc1,tc2,tc3=nil,nil,nil
	if sel&1~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g1=Duel.STarget(tp,s.tfil1,tp,"O",0,1,1,c)
		tc1=g1:GetFirst()
	end
	if sel&2~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g2=Duel.STarget(tp,aux.TRUE,tp,"O","O",1,1,c)
		tc2=g2:GetFirst()
		Duel.SOI(0,CATEGORY_DESTROY,g2,1,0,0)
	end
	if sel&4~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g3=Duel.STarget(tp,Card.IsNegatable,tp,"O","O",1,1,c)
		tc3=g3:GetFirst()
		Duel.SOI(0,CATEGORY_DISABLE,g3,1,0,0)
	end
	e:SetLabelObject({tc1,tc2,tc3})
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lo=e:GetLabelObject()
	if not lo then
		return
	end
	local tc1,tc2,tc3=lo[1],lo[2],lo[3]
	if tc1 and tc1:IsRelateToEffect(e) and tc1:IsFaceup() then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(s.oval11)
		tc1:RegisterEffect(e1)
		if tc1:IsCanAddCounter(COUNTER_SPELL,1) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			tc1:AddCounter(COUNTER_SPELL,1)
		end
	end
	if tc2 and tc2:IsRelateToEffect(e) then
		Duel.Destroy(tc2,REASON_EFFECT)
	end
	if tc3 and tc3:IsRelateToEffect(e) and tc3:IsFaceup() and tc3:IsNegatable() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e2=MakeEff(c,"S")
		e2:SetCode(EFFECT_DISABLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
		tc3:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc3:RegisterEffect(e3)
		if tc3:IsType(TYPE_TRAPMONSTER) then
			local e4=e2:Clone()
			e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc3:RegisterEffect(e4)
		end
	end
end
function s.oval11(e,te)
	return e:GetOwnerPlayer()~=te:GetHandlerPlayer()
end