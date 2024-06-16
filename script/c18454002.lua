--인투 디 언논 딜레이
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","G")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsFaceup() and chkc:IsLoc("M")
	end
	if chk==0 then
		return Duel.IETarget(Card.IsFaceup,tp,"M","M",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.STarget(tp,Card.IsFaceup,tp,"M","M",1,1,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local delay=1
		if Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LSTN("R"),0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			delay=2
		end
		if not tc:IsImmuneToEffect(e) then
			aux.DelayByTurn(tc,tp,delay)
		end
	end
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost(POS_FACEDOWN)
	end
	Duel.Remove(c,POS_FACEDOWN,REASON_COST)
end
function s.tfil2(c)
	local te=c:IsHasEffect(EFFECT_DELAY_TURN)
	if not te then
		return false
	end
	local val=te:GetValue()
	return (val>0 or (val==0 and Duel.GetCurrentPhase()<=PHASE_STANDBY))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=aux.DelayGroup[tp]:Clone()
	g:Merge(aux.DelayGroup[1-tp])
	local sg=g:Filter(s.tfil2,nil)
	if chk==0 then
		return #sg>0
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local g=aux.DelayGroup[tp]:Clone()
	g:Merge(aux.DelayGroup[1-tp])
	local sg=g:FilterSelect(tp,s.tfil2,1,1,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		if aux.DelayTurnEffect[tc] then
			aux.DelayTurnEffect[tc]:GetOperation()(aux.DelayTurnEffect[tc],tp,eg,ep,ev,re,r,rp)
		end
	end
end