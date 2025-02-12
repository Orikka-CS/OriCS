--마력의 태동
local s,id=GetID()
function s.initial_effect(c)
	--	
	local e0=Effect.CreateEffect(c)	
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e0:SetRange(0xf7)
	e0:SetOperation(s.op)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(function(e) e:SetLabel(1) return true end)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),0xf7,0,2,nil,id) then
		Duel.Win(1-tp,0x0)
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK,0,nil)
	local ids={}
	for tc in aux.Next(g) do
		ids[tc:GetCode()]=true
	end
	s.announce_filter={}
	for code,i in pairs(ids) do
		if #s.announce_filter==0 then
			table.insert(s.announce_filter,code)
			table.insert(s.announce_filter,OPCODE_ISCODE)
		else
			table.insert(s.announce_filter,code)
			table.insert(s.announce_filter,OPCODE_ISCODE)
			table.insert(s.announce_filter,OPCODE_OR)
		end
	end
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.rmfilter(c,ac)
	return c:IsCode(ac) and c:IsAbleToRemove()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil,ac)
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED)
		and tc:IsNormalSpell() and tc:CheckActivateEffect(false,true,false)~=nil then
		local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
		if not te then return end
		e:SetType(0)
		e:SetProperty(te:GetProperty())
		local tg=te:GetTarget()
		if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(te)
		Duel.ClearOperationInfo(0)
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		e:SetType(EFFECT_TYPE_ACTIVATE)
	end
end