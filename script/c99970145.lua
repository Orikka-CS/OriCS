--[ The Throne of Destiny ]
local s,id=GetID()
function s.initial_effect(c)

	local e99=MakeEff(c,"FC","M")
	e99:SetCode(EVENT_ADJUST)
	WriteEff(e99,99,"NO")
	c:RegisterEffect(e99)
	
	local e1=MakeEff(c,"STo")
	e1:SetCategory(CATEGORY_DESTROY)
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
	
	local e0=MakeEff(c,"F","HG")
	e0:SetD(id,0)
	e0:SetCL(1,{id,1})
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	WriteEff(e0,0,"NO")
	c:RegisterEffect(e0)
	
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

function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetLevel()-2
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return ct>0 and #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local ct=c:GetLevel()-2
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,ct,nil)
		if #dg==0 then return end
		Duel.HintSelection(dg,true)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

function s.con0fil(c)
	return c:IsSetCard(0x9d70) and c:IsFaceup()
end
function s.con0(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.con0fil,tp,LOCATION_MZONE,0,1,nil)
end
function s.op0(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then 
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end