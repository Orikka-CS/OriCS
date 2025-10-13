--[ N Corp. Fanatic ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tar)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	
end

function s.tarf(c,e,tp,zone_chk)
	return c:IsSetCard(0x3d72) and c:IsM() and (c:IsAbleToHand() or (zone_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.tarf,tp,LOCATION_DECK,0,1,nil,e,tp,zone_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,8))
	local sc=Duel.SelectMatchingCard(tp,s.tarf,tp,LOCATION_DECK,0,1,1,nil,e,tp,zone_chk):GetFirst()
	if sc then
		aux.ToHandOrElse(sc,tp,
			function(c)
				return zone_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			end,
			function(c)
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end,
			aux.Stringid(id,0)
		)
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(aux.Stringid(id,sc:GetCode()-99971059))
		e0:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e0)
	end
	
	
	if Duel.GetFlagEffect(tp,id)==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_ADD_RACE)
		e1:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE)
		e1:SetValue(RACE_MACHINE)
		Duel.RegisterEffect(e1,tp)
		
		local e1a=Effect.CreateEffect(c)
		e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1a:SetCode(EVENT_CHAINING)
		e1a:SetRange(LOCATION_MZONE)
		e1a:SetCondition(s.con)
		e1a:SetOperation(aux.chainreg)
		Duel.RegisterEffect(e1a,tp)
		local e1b=Effect.CreateEffect(c)
		e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1b:SetProperty(EFFECT_FLAG_DELAY)
		e1b:SetCode(EVENT_CHAIN_SOLVED)
		e1b:SetRange(LOCATION_MZONE)
		e1b:SetCondition(function(e) return e:GetHandler():HasFlagEffect(1) end)
		e1b:SetOperation(s.opop)
		Duel.RegisterEffect(e1b,tp)

		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetTarget(function(e,c) return c:GetCounter(0x1d72)>0 end)
		e3:SetValue(POS_FACEUP)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e4:SetTargetRange(LOCATION_HAND,0)
		e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3d72))
		e4:SetLabelObject(e3)
		Duel.RegisterEffect(e4,tp)
		
		local e5=Effect.CreateEffect(c)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e5:SetDescription(aux.Stringid(id,1))
		e5:SetTargetRange(0,1)
		Duel.RegisterEffect(e5,tp)
	end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	
end
function s.opop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x3d72),tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	local ct=1+Duel.GetFlagEffect(tp,id)
	if rp==1-tp then
		Duel.Hint(HINT_CARD,0,id)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(200*ct)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	local trig_race,trig_ctrl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE,CHAININFO_TRIGGERING_CONTROLER)
	return trig_race and trig_race&RACE_MACHINE>0 and trig_ctrl==1-tp
end
