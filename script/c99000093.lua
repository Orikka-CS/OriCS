--닝닝냥냥삐뺩쁍!
local s,id=GetID()
function s.initial_effect(c)
	--일반인은 여기서 냉큼 꺼지시지!
	local e1a=Effect.CreateEffect(c)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_STARTUP)
	e1a:SetRange(LOCATION_ALL)
	e1a:SetOperation(s.start_op)
	Duel.RegisterEffect(e1a,0)
end
function s.start_op(e)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	if c:IsLocation(LOCATION_ALL) then
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(c,nil,-2,REASON_RULE)
	end
end

if not NingNingNyangNyang then
	NingNingNyangNyang={}
	function NingNingNyangNyang.PpiPpapPpup(c)
		--이하의 효과를 적용할 수 있다.
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_ALL)
		e1:SetOperation(NingNingNyangNyang.nyaa)
		Duel.RegisterEffect(e1,0)
	end
	function NingNingNyangNyang.nyaa(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4),aux.Stringid(99000094,15))+1
		if op==1 then
			--자신은 함정 카드를 패에서 발동할 수 있다.
			if Duel.GetFlagEffect(tp,id+1000)==0 then
				Duel.RegisterFlagEffect(tp,id+1000,0,0,0)
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,1))
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
				e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetFlagEffect(tp,id+1000)>0 end)
				e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
				Duel.RegisterEffect(e1,tp)
				Debug.Message("[함정 카드를 패에서 발동할 수 있다.] ON")
			else
				Duel.ResetFlagEffect(tp,id+1000)
				Debug.Message("[함정 카드를 패에서 발동할 수 있다.] OFF")
			end
		elseif op==2 then
			--자신은 함정 카드를 세트한 턴에 발동할 수 있다.
			if Duel.GetFlagEffect(tp,id+2000)==0 then
				Duel.RegisterFlagEffect(tp,id+2000,0,0,0)
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(aux.Stringid(id,2))
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e2:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetFlagEffect(tp,id+2000)>0 end)
				e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
				Duel.RegisterEffect(e2,tp)
				Debug.Message("[함정 카드를 세트한 턴에 발동할 수 있다.] ON")
			else
				Duel.ResetFlagEffect(tp,id+2000)
				Debug.Message("[함정 카드를 세트한 턴에 발동할 수 있다.] OFF")
			end
		elseif op==3 then
			--자신은 통상 소환을 1턴에 임의의 수만큼 실행할 수 있다.
			if Duel.GetFlagEffect(tp,id+3000)==0 then
				Duel.RegisterFlagEffect(tp,id+3000,0,0,0)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e3:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
				e3:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetFlagEffect(tp,id+3000)>0 end)
				e3:SetTargetRange(1,1)
				e3:SetValue(100)
				Duel.RegisterEffect(e3,tp)
				Debug.Message("[통상 소환을 1턴에 임의의 수만큼 실행할 수 있다.] ON")
			else
				Duel.ResetFlagEffect(tp,id+3000)
				Debug.Message("[통상 소환을 1턴에 임의의 수만큼 실행할 수 있다.] OFF")
			end
		elseif op==4 then
			--자신은 통상 소환을 1턴에 임의의 수만큼 실행할 수 있다.
			if Duel.GetFlagEffect(tp,id+4000)==0 then
				Duel.RegisterFlagEffect(tp,id+4000,0,0,0)
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_FIELD)
				e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e4:SetCode(EFFECT_LIGHT_OF_INTERVENTION)
				e4:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetFlagEffect(tp,id+4000)>0 end)
				e4:SetTargetRange(1,1)
				Duel.RegisterEffect(e4,tp)
				Debug.Message("[몬스터를 앞면 수비 표시로 일반 소환할 수 있다.] ON")
			else
				Duel.ResetFlagEffect(tp,id+4000)
				Debug.Message("[몬스터를 앞면 수비 표시로 일반 소환할 수 있다.] OFF")
			end
		end
	end
end