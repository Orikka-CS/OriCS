--[ The Throne of Destiny ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(id)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_CANNOT_INACTIVATE)
		ge1:SetValue(s.effectfilter)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EFFECT_CANNOT_DISEFFECT)
		Duel.RegisterEffect(ge2,0)
	end)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x9d70),tp,LOCATION_MZONE,0,1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 or Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)==0 then return end
	local gg=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #gg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		local sg=gg:Select(tp,1,#gg,nil)
		Duel.ChangePosition(sg,POS_FACEUP_ATTACK)
	end
end

function s.fil(c)
	return c:IsFaceup() and c:IsSetCard(0x9d70) and c:IsLevelAbove(3)
end
function s.effectfilter(e,ct)
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te:GetLabel()==id and Duel.IsExistingMatchingCard(s.fil,tp,LOCATION_MZONE,0,1,nil)
end
