--퍼스트쿼터 다르한겔
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	local e1=MakeEff(c,"F","HG")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end
function s.nfil1(c,tp)
	return (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500) and c:IsFaceup() and c:IsAbleToHandAsCost()
		and Duel.GetMZoneCount(tp,c)>0
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.IEMCard(s.nfil1,tp,"M",0,1,nil,tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SMCard(tp,s.nfil1,tp,"M",0,0,1,nil,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then
		return
	end
	Duel.SendtoHand(g,nil,REASON_COST)
	g:DeleteGroup()
	if c:IsLoc("G") then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(3301)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT-RESET_TOFIELD)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1)
	end
end