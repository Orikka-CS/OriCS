--[ The Book of Truth ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.Activate(c)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	
	local e99=Effect.CreateEffect(c)
	e99:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e99:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e99:SetCode(EVENT_TO_GRAVE)
	e99:SetCondition(s.con99)
	e99:SetTarget(s.tar99)
	e99:SetOperation(s.op99)
	c:RegisterEffect(e99)
	
end

function s.op1fil(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsType(TYPE_FUSION) and c:GetSummonLocation()~=LOCATION_EXTRA
		and c:IsFaceup() and c:IsAbleToRemove(c:GetControler(),POS_FACEDOWN,REASON_EFFECT)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.op1fil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end

function s.con2fil(c,ec)
	return ec:GetLinkedGroup():IsContains(c)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	for tc in aux.Next(Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK)) do
		if eg:IsExists(s.con2fil,1,nil,tc) then g:Add(tc) end
	end
	if #g==0 then return end
	if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end

function s.con99(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return e:GetHandler():IsReason(REASON_EFFECT) and rc==e:GetHandler()
end
function s.tar99(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4
		and Duel.GetDecktopGroup(tp,4):FilterCount(Card.IsSSetable,nil)>0 end
	Duel.SetTargetPlayer(tp)
end
function s.op99fil(c)
	return c:IsSetCard(0xe07) and c:IsST() and c:IsSSetable()
end
function s.op99(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.ConfirmDecktop(p,4)
	local g=Duel.GetDecktopGroup(p,4)
		if g:GetCount()>0 and g:IsExists(s.op99fil,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:FilterSelect(p,s.op99fil,1,1,nil)
		Duel.SSet(tp,sg)
		 
		tc=sg:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.ShuffleDeck(p)
end