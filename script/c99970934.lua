--[ ReversedCloud ]
local s,id=GetID()
function s.initial_effect(c)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drawcon)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)

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

function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

function s.tar9fil(c)
	return c:IsSetCard(0xcd6f) and c:IsAbleToHand()
end
function s.tar9(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar9fil,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.op9(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar9fil,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
