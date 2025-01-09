--[ ReversedCloud ]
local s,id=GetID()
function s.initial_effect(c)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end end)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,1))
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCode(EVENT_CUSTOM+id)
	e9:SetCountLimit(1,{id,1})
	e9:SetTarget(s.tar9)
	e9:SetOperation(s.op9)
	c:RegisterEffect(e9)
	
	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
	
end

function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_SZONE,LOCATION_SZONE,nil,TYPE_SPELL+TYPE_TRAP)
	local tc=g:GetFirst()
	local eventg=Group.CreateGroup()
	while tc do
		if tc:GetFlagEffect(id*10)==0 then
			tc:RegisterFlagEffect(id*10,RESET_EVENT+RESETS_STANDARD,0,0)
			if tc:GetSequence()<5 then
				eventg:AddCard(tc)
				Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+id,e,0,0,0,0)
			end
		end
		tc=g:GetNext()
	end
	if #eventg>0 then
		Duel.RaiseEvent(eventg,EVENT_CUSTOM+id,e,0,0,0,0)
	end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e9=Effect.CreateEffect(c)
		e9:SetType(EFFECT_TYPE_SINGLE)
		e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e9:SetCode(EFFECT_CHANGE_TYPE)
		e9:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e9:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
		c:RegisterEffect(e9)
	end
end

function s.tar9fil(c)
	return c:IsSetCard(0xcd6f) and c:IsMonster()
end
function s.tar9(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar9fil,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.op9(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.tar9fil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			tc:RegisterEffect(e1)
		end
	end
end
