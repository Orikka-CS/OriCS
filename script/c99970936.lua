--[ ReversedCloud ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(1,1)
	e0:SetOperation(aux.TRUE)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetCode(EFFECT_ADD_TYPE)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetTargetRange(LOCATION_SZONE,0)
	e0a:SetCondition(s.addtypecon)
	e0a:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xcd6f))
	e0a:SetValue(TYPE_MONSTER)
	c:RegisterEffect(e0a)
	
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
	
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	
end

function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xcd6f,lc,sumtype,tp)
end
function s.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xcd6f) and c:GetSequence()<5
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		Duel.RegisterFlagEffect(tp,id,0,0,1)
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			s.curgroup=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_SZONE,0,nil)
			s.curgroup:KeepAlive()
			return s.curgroup
		end
	elseif chk==2 then
		if s.curgroup then
			s.curgroup:DeleteGroup()
		end
		s.curgroup=nil
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end
function s.addtypecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end

function s.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil) 
	return g:GetSum(Card.GetBaseAttack)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local p,loct=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return loct==LOCATION_MZONE and re:IsMonsterEffect() and p==1-tp
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and not rc:IsImmuneToEffect(e)
		and Duel.MoveToField(rc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
		rc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(99970938)
		rc:RegisterEffect(e2)	
	end
end
