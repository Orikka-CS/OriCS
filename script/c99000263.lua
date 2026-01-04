--열흘하고도 사흘의 시간
local s,id=GetID()
function s.initial_effect(c)
	--자신은 2000 LP 회복한다. 발동한 턴을 1턴째로 세어 13턴째의 턴 종료시에 자신의 LP는 0 이 된다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,14))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--덱에서 "종말" 몬스터 1장을 패에 넣는다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,15))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TURN_END)
		ge1:SetCountLimit(1)
		ge1:SetOperation(s.endop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(s.winop)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={0xc10}
s.listed_turn_count=true
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(id)
	e1:SetOperation(s.checkop)
	e1:SetCountLimit(1)
	e1:SetLabel(0)
	e1:SetValue(0)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE|PHASE_END,14)
	Duel.RegisterEffect(e1,p)
	local descnum=c:GetOwner()==p and 0 or 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id+descnum,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(1082946)
	e2:SetLabelObject(e1)
	e2:SetOwnerPlayer(p)
	e2:SetOperation(s.reset)
	e2:SetValue(0)
	e2:SetReset(RESET_PHASE|PHASE_END,14)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	s.checkop(te,tp,eg,ep,ev,e,r,rp)
	local ct=te:GetValue()
	local c=e:GetHandler()
	local descnum=c:GetOwner()==tp and 0 or 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id+descnum,ct))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(1082946)
	e2:SetLabelObject(te)
	e2:SetOwnerPlayer(tp)
	e2:SetOperation(s.reset)
	e2:SetValue(0)
	e2:SetReset(RESET_PHASE|PHASE_END,14)
	c:RegisterEffect(e2)
	e:Reset()
	te:SetLabelObject(e2)
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local eff={Duel.GetPlayerEffect(tp,id)}
	for _,te in ipairs(eff) do
		local tep=te:GetOwnerPlayer()
		s.checkop(te,tep,nil,0,0,nil,0,0)
		local ct=te:GetValue()
		local tc=te:GetHandler()
		local descnum=tc:GetOwner()==tep and 0 or 1
		local le=te:GetLabelObject()
		le:Reset()
		local e2=Effect.CreateEffect(tc)
		e2:SetDescription(aux.Stringid(id+descnum,ct))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(1082946)
		e2:SetLabelObject(te)
		e2:SetOwnerPlayer(tep)
		e2:SetOperation(s.reset)
		e2:SetValue(0)
		e2:SetReset(RESET_PHASE|PHASE_END,14)
		tc:RegisterEffect(e2)
		te:SetLabelObject(e2)
	end
	s.winop(e,tp,eg,ep,ev,re,r,rp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetValue()
	ct=ct+1
	e:GetHandler():SetTurnCounter(ct)
	e:SetValue(ct)
	if ct==13 then
		if re then re:Reset() end
	end
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local t={}
	t[0]=0
	t[1]=0
	local countchk=0
	local eff={Duel.GetPlayerEffect(tp,id)}
	for _,te in ipairs(eff) do
		local p=te:GetOwnerPlayer()
		local ct=te:GetValue()
		if ct>countchk then countchk=ct end
		if ct==13 then
			t[p]=t[p]+1
			local label=te:GetLabel()+1
			if label==3 then
				te:Reset()
			end
		end
	end
	if Duel.GetFlagEffect(0,id)<countchk or Duel.GetFlagEffect(1,id)<countchk then
		Duel.ResetFlagEffect(0,id)
		Duel.ResetFlagEffect(1,id)
		for i=1,countchk do
			Duel.RegisterFlagEffect(0,id,0,0,0)
			Duel.RegisterFlagEffect(1,id,0,0,0)
		end
	end
	if (t[0]>0 or t[1]>0) and Duel.IsPhase(PHASE_END) then
		if t[0]==t[1] then
			Duel.SetLP(PLAYER_NONE,0)
		elseif t[0]>t[1] then
			Duel.SetLP(0,0)
		else
			Duel.SetLP(1,0)
		end
	end
end
function s.thfilter(c)
	return (c:IsSetCard(0xc10) or c:IsCode(28985331)) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local turn_count=1
	if Duel.IsExistingMatchingCard(Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,1,nil,1082946) and Duel.SelectYesNo(tp,aux.Stringid(99000258,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(1082946,0))
		local turn_count_g=Duel.SelectMatchingCard(tp,Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,1,1,nil,1082946)
		local turn_count_tc=turn_count_g:GetFirst()
		local eff={turn_count_tc:GetCardEffect(1082946)}
		local sel={}
		local seld={}
		local turne
		for _,te in ipairs(eff) do
			table.insert(sel,te)
			table.insert(seld,te:GetDescription())
		end
		if #sel==1 then turne=sel[1] elseif #sel>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			local op=Duel.SelectOption(tp,table.unpack(seld))+1
			turne=sel[op]
		end
		if not turne then return end
		local op=turne:GetOperation()
		op(turne,turne:GetOwnerPlayer(),nil,0,1082946,nil,0,0)
		turn_count=turn_count+1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,turn_count,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end