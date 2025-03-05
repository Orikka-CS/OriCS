--나우프라테 디렉터 사무엘
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,4,s.linkfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_MATERIAL_CHECK)
	e1a:SetValue(s.e1aval)
	c:RegisterEffect(e1a)
	e1a:SetLabelObject(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--link
function s.linkfilter(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_LINK,lc,sumtype,tp)
end

--effect 1
function s.e1aval(e,c)
	local ct=c:GetMaterial():FilterCount(Card.IsSetCard,nil,0xf28)
	e:GetLabelObject():SetLabel(ct)
end

function s.con1filter(c,tp)
	return c:IsTrapMonster() and c:IsContinuousTrap() and c:IsControler(tp) 
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con1filter,1,nil,tp) and not eg:IsContains(e:GetHandler()) and not e:GetHandler():HasFlagEffect(id,e:GetLabel())
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
end

function s.op1filter(c)
	return c:IsSpellTrap() and c:IsSSetable()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_HAND,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
		Duel.SSet(tp,sg,tp,false) 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		if sg:IsQuickPlaySpell() then
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		elseif sg:IsTrap() then
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		end
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:RegisterEffect(e1)
	end
end

--effect 2
function s.con2filter(c)
	return c:IsTrapMonster() and c:IsContinuousTrap()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	return c:IsSummonType(SUMMON_TYPE_LINK) and g:FilterCount(s.con2filter,nil)>0 and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.tg2(e,c)
	local oc=e:GetHandler()
	return c==oc or oc:GetLinkedGroup():IsContains(c)
end

function s.val2(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end