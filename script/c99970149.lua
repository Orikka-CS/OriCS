--[ The Throne of Destiny ]
local s,id=GetID()
function s.initial_effect(c)

	local e99=MakeEff(c,"FC","M")
	e99:SetCode(EVENT_ADJUST)
	WriteEff(e99,99,"NO")
	c:RegisterEffect(e99)
	
	local e0=MakeEff(c,"S","M")
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetValue(function(e,re) return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_TRAP) end)
	c:RegisterEffect(e0)
	local e00=MakeEff(c,"FG","M")
	e00:SetTargetRange(LOCATION_MZONE,0)
	e00:SetCondition(s.lv3con)
	e00:SetTarget(function(e,c) return c:IsSetCard(0x9d70) and c~=e:GetHandler() end)
	e00:SetLabelObject(e0)
	c:RegisterEffect(e00)
	
end

function s.lv3con(e)
	return e:GetHandler():IsLevelAbove(3)
end

function s.con99(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)==0
end
function s.op99(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		Duel.Hint(HINT_CARD,0,id)
		local atk=YuL.Random(1500,4000)
		Duel.Hint(HINT_NUMBER,tp,atk)
		Duel.Hint(HINT_NUMBER,1-tp,atk)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(atk)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(math.floor(atk/1000))
	c:RegisterEffect(e2)
end
