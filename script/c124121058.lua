--주언의 가면
local s,id=GetID()
function s.initial_effect(c)
	local nulle1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsCode,124121056),Card.IsAbleToDeck,s.pg1,Fusion.ShuffleMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.ntar1)
	local nulle2=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsCode,49064413),nil,nil,s.pg2,s.nop2,Card.IsAbleToDeck,nil,LOCATION_HAND|LOCATION_GRAVE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1(nulle1,nulle2))
	e1:SetOperation(s.op1(nulle1,nulle2))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.afil1)
end
s.listed_names={124121056}
function s.pgfil1(c)
	return c:IsAbleToDeck() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.pg1(e,tp,mg)
	return Duel.GetMatchingGroup(s.pgfil1,tp,LOCATION_GRAVE,LOCATION_MZONE,nil)
end
function s.ntar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
end
function s.pgfil2(c,e)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:GetLevel()>0 and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
function s.pg2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroup(s.pgfil2,tp,LOCATION_GRAVE,LOCATION_MZONE,nil,e)
end
function s.nop2(mat,e,tp,eg,ep,ev,re,r,rp,sc)
	Duel.ConfirmCards(1-tp,mat)
	Duel.SendtoDeck(mat,nil,2,REASON_EFFECT)
end
function s.afil1(c)
	return c:IsRace(RACE_FIEND)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.ctar11)
	Duel.RegisterEffect(e1,tp)
end
function s.ctar11(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_FIEND)
end
function s.tar1(nulle1,nulle2)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local bt={}
		bt[1]=nulle1:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0)
		bt[2]=nulle2:GetTarget()(e,tp,eg,ep,ev,re,r,rp,0)
		bt[3]=Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,c)
		local bsum=0
		for i=1,3 do
			if bt[i] then
				bsum=bsum+1
			end
		end
		if chk==0 then
			return bsum>=2
		end
		local ops=0
		for i=1,2 do
			local opt={}
			for j=1,3 do
				table.insert(opt,{ops&(1<<(j-1))==0 and bt[j],aux.Stringid(id,j-1)})
			end
			local op=Duel.SelectEffect(tp,table.unpack(opt))
			ops=ops|(1<<(op-1))
		end
		e:SetLabel(ops)
		local cat=0
		for i=1,3 do
			if ops&(1<<(i-1))~=0 then
				if i==1 then
					nulle1:GetTarget()(e,tp,eg,ep,ev,re,r,rp,1)
					cat=cat|nulle1:GetCategory()
				elseif i==2 then
					nulle2:GetTarget()(e,tp,eg,ep,ev,re,r,rp,1)
					cat=cat|nulle2:GetCategory()
				elseif i==3 then
					Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
					cat=cat|CATEGORY_TODECK|CATEGORY_DRAW
				end
			end
		end
		e:SetCategory(cat)
	end
end
function s.op1(nulle1,nulle2)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local ops=e:GetLabel()
		for i=1,3 do
			if ops&(1<<(i-1))~=0 then
				if i==1 then
					nulle1:GetOperation()(e,tp,eg,ep,ev,re,r,rp)
				elseif i==2 then
					nulle2:GetOperation()(e,tp,eg,ep,ev,re,r,rp)
				elseif i==3 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
					if #g>0 and Duel.SendtoDeck(g,nil,2,REASON_EFFECT)>0 then
						Duel.ShuffleDeck(tp)
						Duel.BreakEffect()
						Duel.Draw(tp,1,REASON_EFFECT)
					end
				end
			end
		end
	end
end
function s.tfil2(c)
	return c:IsFaceup() and c:GetOriginalCodeRule()==48948935
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfil2(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil2,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tfil2,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(3100)
		e1:SetValue(s.oval21)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.oval21(e,re)
	local c=e:GetHandler()
	return c~=re:GetOwner() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
