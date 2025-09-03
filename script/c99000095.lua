--죽은 자를 위한 실망
local s,id=GetID()
function s.initial_effect(c)
	--일반인은 여기서 냉큼 꺼지시지!
	local e1a=Effect.CreateEffect(c)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_STARTUP)
	e1a:SetRange(LOCATION_ALL)
	e1a:SetOperation(s.start_op)
	Duel.RegisterEffect(e1a,0)
	--(대상) 필드 / 묘지 / 제외 상태
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_ALL)
	e2:SetTarget(s.silmang_tg)
	e2:SetOperation(s.silmang_op)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	--(비대상) 필드 / 묘지 / 제외 상태
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetLabel(2)
	c:RegisterEffect(e3)
	--패 / 덱 / 엑스트라 덱
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetLabel(3)
	c:RegisterEffect(e4)
end
function s.start_op(e)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	if c:IsLocation(LOCATION_ALL) then
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(c,nil,-2,REASON_RULE)
	end
end
function s.silmang_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local loc=LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED
	if chkc then return chkc:IsLocation(loc) end
	if chk==0 then return true end
	if e:GetLabel()==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local tc=Duel.SelectTarget(tp,aux.TRUE,tp,loc,loc,0,99,nil)
	end
end
function s.silmang_op(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	if e:GetLabel()==1 then
		g=Duel.GetTargetCards(e)
	elseif e:GetLabel()==2 then
		g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,99,nil)
		if g then Duel.HintSelection(g) end
	elseif e:GetLabel()==3 then
		g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,0,99,nil)
	end
	if (not g) or (#g<1) then return end
	--파괴한다 / 제외한다 / 묘지로 보낸다 / 릴리스한다 / 패에 넣는다 / 덱에 넣는다 / 소멸시킨다 / 발동 취소
	op=Duel.SelectOption(tp,aux.Stringid(99000098,3),aux.Stringid(99000098,4),aux.Stringid(99000098,5),aux.Stringid(99000098,6),aux.Stringid(99000098,7),aux.Stringid(99000098,8),aux.Stringid(99000098,9),aux.Stringid(99000094,15))+10
	--파괴한다
	if op==10 then
		Duel.Destroy(g,REASON_EFFECT)
	--제외한다
	elseif op==11 then
		op=Duel.SelectOption(tp,aux.Stringid(99000098,10),aux.Stringid(99000098,11))+20
	--묘지로 보낸다
	elseif op==12 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	--릴리스한다
	elseif op==13 then
		Duel.Release(g,REASON_EFFECT)
	--패에 넣는다
	elseif op==14 then
		op=Duel.SelectOption(tp,aux.Stringid(99000098,12),aux.Stringid(99000098,13))+30
	--덱에 넣는다
	elseif op==15 then
		op=Duel.SelectOption(tp,aux.Stringid(99000098,14),aux.Stringid(99000098,15))+40
	--소멸시킨다
	elseif op==16 then
		Duel.SendtoDeck(g,nil,-2,REASON_RULE)
	end
	--
	--앞면 표시로 제외
	if op==20 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	--뒷면 표시로 제외
	elseif op==21 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	--자신의 패에 넣는다
	elseif op==30 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	--상대의 패에 넣는다
	elseif op==31 then
		Duel.SendtoHand(g,1-tp,REASON_EFFECT)
	--자신의 덱에 넣는다
	elseif op==40 then
		Duel.SendtoDeck(g,tp,2,REASON_EFFECT)
	--상대의 덱에 넣는다
	elseif op==41 then
		Duel.SendtoDeck(g,1-tp,2,REASON_EFFECT)
	end
end