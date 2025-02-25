--[ The Throne of Destiny ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	aux.AddModuleProcedure(c,aux.FBF(Card.IsSetCard,0x9d70),nil,1,5,nil)

	local e99=MakeEff(c,"FC","M")
	e99:SetCode(EVENT_ADJUST)
	WriteEff(e99,99,"NO")
	c:RegisterEffect(e99)
	
	local e1=MakeEff(c,"I","M")
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_LVCHANGE)
	e1:SetCL(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local ex=MakeEff(c,"S")
	ex:SetCode(EFFECT_DIRECT_ATTACK)
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

function s.tar1fil(c)
	return c:IsFaceup() and c:IsSetCard(0x9d70)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tar1fil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tar1fil,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tar1fil,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=YuL.Random(0,4000)
		Duel.Hint(HINT_NUMBER,tp,atk)
		Duel.Hint(HINT_NUMBER,1-tp,atk)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(math.floor(atk/1000))
		tc:RegisterEffect(e2)
	end
end
