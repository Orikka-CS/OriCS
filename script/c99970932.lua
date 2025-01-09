--[ ReversedCloud ]
local s,id=GetID()
function s.initial_effect(c)

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCountLimit(1,id)
	e4:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCost(s.cost4)
	e4:SetTarget(s.tar4)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
	local e8=e4:Clone()
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e8)
	
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,1))
	e9:SetCategory(CATEGORY_TOHAND)
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

function s.cost4fil(c)
	return c:IsSetCard(0xcd6f) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost4fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost4fil,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar4fil(c)
	return c:IsSetCard(0xcd6f) and c:IsMonster() and c:IsFaceup()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar4fil,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.tar4fil,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
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

function s.tar9fil(c)
	return c:IsAbleToHand() and c:IsFaceup()
end
function s.tar9(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar9fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.tar9fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.op9(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar9fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
