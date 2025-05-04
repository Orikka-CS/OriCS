--이차원의 발키리
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,id)
	WriteEff(e2,2,"N")
	WriteEff(e2,1,"CTO")
	Duel.RegisterEffect(e2,0)
	local e3=e2:Clone()
	Duel.RegisterEffect(e3,1)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCL(1,{id,1})
	WriteEff(e4,4,"NTO")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"FTo","M")
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCL(1,{id,1})
	WriteEff(e5,5,"N")
	WriteEff(e5,4,"TO")
	c:RegisterEffect(e5)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return (Duel.GetTurnPlayer()==tp and ph&(PHASE_MAIN1|PHASE_MAIN2)~=0)
		or (Duel.GetTurnPlayer()~=tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(aux.TRUE,tp,"HG",0,1,nil)
	end
	local g=Duel.SMCard(tp,aux.TRUE,tp,"HG",0,1,1,nil)
	local tc=g:GetFirst()
	--temp
	Duel.SendtoDeck(g,nil,-2,REASON_COST)
	table.insert(Auxiliary.BurningZone[tc:GetOwner()],tc)
	Auxiliary.BurningZoneTopCardOperation(e,tp,eg,ep,ev,re,r,rp)
	c:CreateEffectRelation(e)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bz=aux.BurningZone[tp]
	local og=Group.CreateGroup()
	for i=1,#bz do
		og:AddCard(bz[i])
	end
	if c:IsRelateToEffect(e) then
		if og:IsContains(c) then
			aux.EraseFromBurningZone(Group.FromCards(c))
		end
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bz=aux.BurningZone[tp]
	local og=Group.CreateGroup()
	for i=1,#bz do
		og:AddCard(bz[i])
	end
	return Duel.GetCurrentPhase()&(PHASE_MAIN1|PHASE_MAIN2)~=0 and og:IsContains(c)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("M") and chkc:IsControler(1-tp)
	end
	if chk==0 then
		return Duel.IETarget(aux.TRUE,tp,0,"M",1,nil)
	end
	Duel.STarget(tp,aux.TRUE,tp,0,"M",1,1,nil)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		local ctype=c:GetType()
		local ttype=tc:GetType()
		c:Type(ctype|TYPE_TOKEN)
		tc:Type(ttype|TYPE_TOKEN)
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
			if c:GetLocation()==0 then
				table.insert(Auxiliary.BurningZone[c:GetOwner()],c)
				Auxiliary.BurningZoneTopCardOperation(e,tp,eg,ep,ev,re,r,rp)
			end
			if tc:GetLocation()==0 then
				table.insert(Auxiliary.BurningZone[tc:GetOwner()],tc)
				Auxiliary.BurningZoneTopCardOperation(e,tp,eg,ep,ev,re,r,rp)
			end
		end
		c:Type(ctype)
		tc:Type(ttype)
	end
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end