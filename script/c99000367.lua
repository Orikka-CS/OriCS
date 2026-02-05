--FINDING_THE_MISSING@SPELL
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--자신의 오더 몬스터가 전투를 실행할 경우, 상대는 데미지 스텝 종료시까지 마법 / 함정 / 몬스터의 효과를 발동할 수 없다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.actcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--그 발동한 카드와는 카드명이 다른, "파인딩 더 미싱" 마법 / 함정 카드 1장 또는 "@SPELL" 마법 카드 1장을 패에 넣는다.
	local g=Group.CreateGroup()
	g:KeepAlive()
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetLabelObject(g)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop2)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_CUSTOM+id)
	e5:SetRange(LOCATION_SZONE)
	e5:SetLabelObject(g)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_series={0xc17,0xc13}
s.listed_names={id}
function s.actcon(e)
	local bc=Duel.GetBattleMonster(e:GetHandlerPlayer())
	return bc and bc:IsFaceup() and (bc:IsCustomType(CUSTOMTYPE_ORDER) or bc:IsType(TYPE_ORDER))
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flageff={c:GetFlagEffectLabel(1)}
	local chainid=ev
	if flageff[1]==nil then return end
	local g=e:GetLabelObject()
	for _,i in ipairs(flageff) do
		if chainid==i then
			if c:GetFlagEffect(2)==0 then
				g:Clear()
				c:RegisterFlagEffect(2,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET)|RESET_CHAIN,0,1)
				Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,0,0,0)
			end
			g:AddCard(re:GetHandler())
			return
		end
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and not re:GetHandler():IsType(TYPE_FIELD)
		and (re:GetHandler():IsSetCard(0xc17) or re:GetHandler():IsSetCard(0xc13))
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(1,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET)|RESET_CHAIN,0,1,ev)
end
function s.thfilter(c,codes)
	return ((c:IsSetCard(0xc17) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or (c:IsSetCard(0xc13) and c:IsType(TYPE_SPELL)))
		and not c:IsCode(codes) and c:IsAbleToHand()
end
function s.chk(c,tp,e)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	if chk==0 then return c:GetFlagEffect(id+1)==0 and g:IsExists(s.chk,1,nil,tp,e) end
	c:RegisterFlagEffect(id+1,RESET_CHAIN,0,1)
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		e:SetLabel(g:Select(tp,1,1,nil):GetFirst():GetCode())
	else
		e:SetLabel(g:GetFirst():GetCode())
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local codes={e:GetLabel()}
	if not #codes==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,e:GetLabelObject(),codes)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_CANNOT_TO_HAND)
		e0:SetDescription(aux.Stringid(tc:GetCode(),5))
		e0:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
		e0:SetTargetRange(1,0)
		e0:SetTarget(s.thlimit)
		e0:SetLabel(tc:GetCode())
		e0:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e0,tp)
	end
end
function s.thlimit(e,c,tp,re)
	return c:IsCode(e:GetLabel()) and re and re:GetHandler():IsCode(99000367)
end