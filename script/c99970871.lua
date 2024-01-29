--[ Outer User ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"I","H")
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(s.con3)
	e3:SetValue(aux.ChangeBattleDamage(1,3200))
	c:RegisterEffect(e3)

	local e4=MakeEff(c,"FTo","HG")
	e4:SetD(id,1)
	e4:SetCategory(CATEGORY_SEARCH_CARD+CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCL(1,{id,1})
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)

	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_CHAIN_ACTIVATING)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
		local ge3=MakeEff(c,"FC")
		ge3:SetCode(EVENT_CHAIN_SOLVED)
		ge3:SetOperation(s.gop3)
		Duel.RegisterEffect(ge3,0)
	end
	
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return c:IsSetCard(0x9d6e) end)
	
end

function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	if cc>0 then
		local ce=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_EFFECT)
		if re==ce and re:IsActivated() then
			Duel.RegisterFlagEffect(0,id,RESET_CHAIN,0,0,cc)
		end
	end
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(0,id)
end
function s.gop3(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	if Duel.GetFlagEffectLabel(0,id)~=cc and re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then
		Duel.RaiseEvent(Group.CreateGroup(),EVENT_CUSTOM+id,re,r,rp,ep,ev)
	end
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST|REASON_DISCARD)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9d6e)
end
function s.tar1fil(c,ft,e,tp)
	return c:IsSetCard(0x9d6e) and ((c:IsM() and ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)) or c:IsAbleToHand())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tar1fil(chkc,e,tp,ft) end
	if chk==0 then return Duel.IsExistingTarget(s.tar1fil,tp,LOCATION_GRAVE,0,1,nil,ft,e,tp) end
	local g=Duel.GetMatchingGroup(s.tar1fil,tp,LOCATION_GRAVE,0,nil,ft,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local sg=g:Select(tp,1,1,nil)
		Duel.SetTargetCard(sg)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
		if sg:GetFirst():IsMonster() then 
			Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
			Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
		else
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
		end
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sc=Duel.GetFirstTarget()
	if sc and sc:IsRelateToEffect(e) then
		aux.ToHandOrElse(sc,tp,function(c)
			return sc:IsM() and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and ft>0 end,
		function(c)
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,0))
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end

function s.tar4fil(c)
	return c:IsSetCard(0x9d6e) and c:IsM() and c:IsAbleToHand()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar4fil,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.tar4fil,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsRelateToEffect(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.ConfirmCards(1-tp,tc)
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
