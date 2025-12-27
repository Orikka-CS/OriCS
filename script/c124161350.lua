--폴루스턴 리프레시먼트
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LVCHANGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end

--effect 1
function s.tg1filter(c,e)
	return c:IsSetCard(0xf36) and c:IsFaceup() and c:GetOriginalLevel()>c:GetLevel() and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() then
		local diff=tg:GetOriginalLevel()-tg:GetLevel()
		if diff>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(diff)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tg:RegisterEffect(e1) 
			local dct=diff//2
			if dct>0 and Duel.IsPlayerCanDraw(tp,dct) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Draw(tp,dct,REASON_EFFECT)
			end
		end
	end
end