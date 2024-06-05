--[ Remnantria ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	
end

function s.tar1fil(c,e,tp)
	return c:IsSetCard(0x6d6f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED|LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1fil),tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=g:GetFirst()
		Duel.BreakEffect()
		tc:RegisterFlagEffect(id,RESET_PHASE|PHASE_END|RESET_EVENT|RESETS_STANDARD,0,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetTargetRange(0,LOCATION_ONFIELD)
		e3:SetTarget(s.distg)
		e3:SetReset(RESET_PHASE|PHASE_END)
		e3:SetLabelObject(tc)
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		Duel.RegisterEffect(e4,tp)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_CHAIN_SOLVING)
		e5:SetOperation(s.disop)
		e5:SetReset(RESET_PHASE|PHASE_END)
		e5:SetLabelObject(tc)
		Duel.RegisterEffect(e5,tp)
	end
end
function s.distg(e,c)
	local ob=e:GetLabelObject()
	local seq=ob:GetSequence()
	if c:IsControler(1-e:GetHandlerPlayer()) then seq=4-seq end
	return c:IsFaceup() and seq==c:GetSequence() and ob:GetFlagEffect(id)~=0
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local ob=e:GetLabelObject()
	local cseq=ob:GetSequence()
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if ob:GetFlagEffect(id)==0 or ob:IsControler(p) then return end
	if loc&LOCATION_ONFIELD==0 or rc:IsControler(1-p) then
		seq=rc:GetPreviousSequence()
	end
	if loc&LOCATION_ONFIELD==0 then
		local val=re:GetValue()
		if val==nil or val==LOCATION_SZONE or val==LOCATION_FZONE or val==LOCATION_PZONE or val==LOCATION_MZONE or val==LOCATION_ONFIELD then
			loc=LOCATION_ONFIELD
		end
	end
	if ep~=e:GetHandlerPlayer() then cseq=4-cseq end
	if loc&LOCATION_ONFIELD~=0 and cseq==seq then
		Duel.NegateEffect(ev)
	end
end

function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
