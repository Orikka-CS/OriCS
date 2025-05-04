--재의 마녀 일레이나
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","M")
	e2:SetCode(id)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetTR(1,0)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_STARTUP)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_MOVE)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	aux.GlobalFullList()
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local tc=eg:GetFirst()
		while tc do
			if aux.GlobalOCGTokens[p]:IsContains(tc) then
				local tcode=tc:GetOriginalCode()
				aux.GlobalOCGTokens[p]:RemoveCard(tc)
				local token=Duel.CreateToken(p,tcode)
				aux.GlobalOCGTokens[p]:AddCard(token)
			end
			tc=eg:GetNext()
		end
	end
end
function s.tfil1(c)
	return c:IsCode(18454326) and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

local diemc=Duel.IsExistingMatchingCard
local dsmc=Duel.SelectMatchingCard
local dgmg=Duel.GetMatchingGroup
local dgmgc=Duel.GetMatchingGroupCount
local dgfmc=Duel.GetFirstMatchingCard
function Duel.IsExistingMatchingCard(filter,player,self,enemy,count,exception,...)
	local ce,cp=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if Duel.IsPlayerAffectedByEffect(player,id) and self&LOCATION_DECK==LOCATION_DECK
		and ce and cp==player then
		local cc=ce:GetHandler()
		if cc:IsType(TYPE_FIELD) and cc:IsType(TYPE_SPELL) then
			local g=dgmg(filter,player,self,enemy,count,exception,...)
			local sg=aux.GlobalOCGTokens[player]:Filter(filter,nil)
			g:Merge(sg)
			return #g>0
		end
	end
	return diemc(filter,player,self,enemy,count,exception,...)
end
function Duel.SelectMatchingCard(picker,filter,player,self,enemy,minc,maxc,exception,...)
	local ce,cp=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if Duel.IsPlayerAffectedByEffect(player,id) and self&LOCATION_DECK==LOCATION_DECK
		and ce and cp==player then
		local cc=ce:GetHandler()
		if cc:IsType(TYPE_FIELD) and cc:IsType(TYPE_SPELL) then
			local g=dgmg(filter,player,self,enemy,count,exception,...)
			local sg=aux.GlobalOCGTokens[player]:Filter(filter,nil)
			g:Merge(sg)
			local tg=g:Select(picker,minc,maxc,exception)
			return tg
		end
	end
	return dsmc(picker,filter,player,self,enemy,minc,maxc,exception,...)
end
function Duel.GetMatchingGroup(filter,player,self,enemy,exception,...)
	local ce,cp=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if Duel.IsPlayerAffectedByEffect(player,id) and self&LOCATION_DECK==LOCATION_DECK
		and ce and cp==player then
		local cc=ce:GetHandler()
		if cc:IsType(TYPE_FIELD) and cc:IsType(TYPE_SPELL) then
			local g=dgmg(filter,player,self,enemy,count,exception,...)
			local sg=aux.GlobalOCGTokens[player]:Filter(filter,nil)
			g:Merge(sg)
			return g
		end
	end
	return dgmg(filter,player,self,enemy,exception,...)
end
function Duel.GetMatchingGroupCount(filter,player,self,enemy,exception,...)
	local ce,cp=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if Duel.IsPlayerAffectedByEffect(player,id) and self&LOCATION_DECK==LOCATION_DECK
		and ce and cp==player then
		local cc=ce:GetHandler()
		if cc:IsType(TYPE_FIELD) and cc:IsType(TYPE_SPELL) then
			local g=dgmg(filter,player,self,enemy,count,exception,...)
			local sg=aux.GlobalOCGTokens[player]:Filter(filter,nil)
			g:Merge(sg)
			return #g
		end
	end
	return dgmgc(filter,player,self,enemy,exception,...)
end
function Duel.GetFirstMatchingCard(filter,player,self,enemy,exception,...)
	local ce,cp=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if Duel.IsPlayerAffectedByEffect(player,id) and self&LOCATION_DECK==LOCATION_DECK
		and ce and cp==player then
		local cc=ce:GetHandler()
		if cc:IsType(TYPE_FIELD) and cc:IsType(TYPE_SPELL) then
			local g=dgmg(filter,player,self,enemy,count,exception,...)
			local sg=aux.GlobalOCGTokens[player]:Filter(filter,nil)
			g:Merge(sg)
			return tg:GetFirst()
		end
	end
	return dgfmc(filter,player,self,enemy,exception,...)
end