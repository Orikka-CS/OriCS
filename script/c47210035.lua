--리코리스 애쉬블룸
local m=47210035
local cm=_G["c"..m]

function cm.initial_effect(c)
	
	--Link summon method
	c:EnableReviveLimit()
	Link.AddProcedure(c,cm.matfilter,2,3)

	--force mzone
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_FORCE_MZONE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(1,0)
	e0:SetValue(function(e)return ~e:GetHandler():GetLinkedZone() end)
	c:RegisterEffect(e0)

	--Effect_01
	c:SetUniqueOnField(1,0,m)
	
	--Effect_02
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(cm.regop)
	c:RegisterEffect(e2)
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e22:SetCode(EVENT_CHAIN_SOLVED)
	e22:SetRange(LOCATION_MZONE)
	e22:SetCondition(cm.eff02_con)
	e22:SetOperation(cm.eff02_op)
	c:RegisterEffect(e22)

	--Effect_03
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e3:SetCode(EVENT_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(cm.eff03_tar)
	e3:SetOperation(cm.eff03_op)
	c:RegisterEffect(e3)

end

function cm.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0xa7b,lc,sumtype,tp)
end

function cm.eff02_filter(c)
	return c:IsSetCard(0xa7b)
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain(true)
	if ch<3 then return end

	e:GetHandler():RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
function cm.eff02_con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	return ep==1-tp and Duel.GetMatchingGroupCount(cm.eff02_filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>=3 and c:GetFlagEffect(m)~=0
end
function cm.eff02_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,m)
	Duel.Damage(1-tp,1600,REASON_EFFECT)
end


function cm.eff03_filter(c,e,tp)
	return c:IsSetCard(0xa7b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.eff03_tar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.eff03_filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function cm.eff03_op(e,tp,eg,ep,ev,re,r,rp)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,cm.eff03_filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
			Duel.Damage(1-tp,1600,REASON_EFFECT)
		end
	end
end
