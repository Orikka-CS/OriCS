--[ The Throne of Destiny ]
local s,id=GetID()
function s.initial_effect(c)

	local e99=MakeEff(c,"FC","M")
	e99:SetCode(EVENT_ADJUST)
	WriteEff(e99,99,"NO")
	c:RegisterEffect(e99)
	
	local e1=MakeEff(c,"I","M")
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SUMMON)
	e1:SetCondition(aux.NOT(s.lv3con))
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.lv3con)
	c:RegisterEffect(e2)
		
	local ex=MakeEff(c,"F","M")
	ex:SetCode(EFFECT_CANNOT_INACTIVATE)
	ex:SetValue(s.effectfilter)
	c:RegisterEffect(ex)
	local ey=ex:Clone()
	ey:SetCode(EFFECT_CANNOT_DISEFFECT)
	c:RegisterEffect(ey)
	local ez=MakeEff(c,"S","M")
	ez:SetCode(EFFECT_UPDATE_LEVEL)
	ez:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	ez:SetValue(1)
	c:RegisterEffect(ez)
	
	local e0=ex:Clone()
	local e01=ey:Clone()
	local e02=ez:Clone()
	local e00=MakeEff(c,"FG","M")
	e00:SetTargetRange(LOCATION_MZONE,0)
	e00:SetCondition(s.lv3con)
	e00:SetTarget(function(e,c) return c:IsSetCard(0x9d70) and c~=e:GetHandler() end)
	e00:SetLabelObject(e0)
	c:RegisterEffect(e00)
	local e001=e00:Clone()
	e001:SetLabelObject(e01)
	c:RegisterEffect(e001)
	local e002=e00:Clone()
	e002:SetLabelObject(e02)
	c:RegisterEffect(e002)

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

function s.cost1fil(c)
	return c:IsSetCard(0x9d70) and c:IsAbleToRemoveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost1fil,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cost1fil,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,0)
end
function s.op1fil(c)
	return c:IsSetCard(0x9d70) and c:IsSummonable(true,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.op1fil,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local tc=Duel.SelectMatchingCard(tp,s.op1fil,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			Duel.BreakEffect()
			Duel.Summon(tp,tc,true,nil)
		end
	end
end

function s.effectfilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end