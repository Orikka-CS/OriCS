--[ Outer User ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"I","H")
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"FTo","M")
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	
	local e4=MakeEff(c,"FTo","GR")
	e4:SetD(id,1)
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
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

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x9d6e),tp,LOCATION_MZONE,0,1,nil)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
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
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)>0 and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local bc0,bc1=Duel.GetBattleMonster(tp)
	return bc0 and bc0==e:GetHandler() and bc1 and bc1:IsFacedown()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local _,bc1=Duel.GetBattleMonster(tp)
	if chk==0 then return bc1 and bc1:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local _,bc1=Duel.GetBattleMonster(tp)
	if bc1 and bc1:IsAbleToDeck() then
		Duel.SendtoDeck(bc1,nil,2,REASON_EFFECT)
	end
end

function s.tar4fil(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar4fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	local g=Duel.GetMatchingGroup(s.tar4fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.tar4fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if tc and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsRelateToEffect(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
