--[ The Throne of Destiny ]
local s,id=GetID()
function s.initial_effect(c)

	local e99=MakeEff(c,"FC","M")
	e99:SetCode(EVENT_ADJUST)
	WriteEff(e99,99,"NO")
	c:RegisterEffect(e99)
	
	local e1=MakeEff(c,"STo")
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
	
	local ex=MakeEff(c,"S","M")
	ex:SetCode(EFFECT_UPDATE_ATTACK)
	ex:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	ex:SetCondition(s.atkcon)
	ex:SetValue(function(e,c) return YuL.Random(0,2000) end)
	c:RegisterEffect(ex)
	
	local e0=ex:Clone()
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
		local atk=YuL.Random(0,4000)
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

function s.tar1fil(c)
	return c:IsSetCard(0x9d70) and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1fil),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.atkcon(e)
	local bc=Duel.GetAttackTarget()
	return Duel.IsPhase(PHASE_DAMAGE_CAL) and e:GetHandler()==Duel.GetAttacker() and bc and bc:IsControler(1-e:GetHandlerPlayer())
end