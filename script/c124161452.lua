--격멸의 나바슈파타 바가브
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_WARRIOR),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end

function s.tg1ctfilter(c)
	return c:IsSetCard(0xf3d) and c:IsMonster() and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanBeEffectTarget(e) end
	local ct=math.min(Duel.GetLocationCount(1-tp,LOCATION_SZONE),Duel.GetMatchingGroupCount(s.tg1ctfilter,tp,LOCATION_MZONE,0,nil))
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return ct>0 and #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op1sfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	tg=tg-tg:Filter(Card.IsImmuneToEffect,nil,e)
	local ct=Duel.GetLocationCount(1-tp,LOCATION_SZONE)
	if #tg>0 then
		if #tg>ct then
			local gg=aux.SelectUnselectGroup(tg,e,tp,#tg-ct,#tg-ct,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
			Duel.SendtoGrave(gg,REASON_RULE,nil,PLAYER_NONE)
			tg=tg-gg
		end
		for tc in tg:Iter() do
			Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			tc:RegisterEffect(e1)
		end
		local sg=Duel.GetMatchingGroup(s.op1sfilter,tp,LOCATION_MZONE,0,nil)
		if #sg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.BreakEffect()
			local ssg=aux.SelectUnselectGroup(sg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOFIELD)
			local sc=ssg:GetFirst()
			if sc then
				Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_CHANGE_TYPE)
				e2:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				e2:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
				sc:RegisterEffect(e2)
			end
		end
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return c:IsContinuousSpell() and re:IsActiveType(TYPE_MONSTER) and c:GetColumnGroup():IsContains(rc)
end

function s.tg2mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf3d) and c:IsAbleToGrave()
end

function s.tg2ofilter(c)
	return c:IsAbleToGrave()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.tg2mfilter,tp,LOCATION_ONFIELD,0,nil)
	local og=Duel.GetMatchingGroup(s.tg2ofilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #mg>0 and #og>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,PLAYER_ALL,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.tg2mfilter,tp,LOCATION_ONFIELD,0,nil)
	local og=Duel.GetMatchingGroup(s.tg2ofilter,tp,0,LOCATION_ONFIELD,nil)
	if #mg>0 and #og>0 then
		local msg=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
		local osg=aux.SelectUnselectGroup(og,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
		msg:Merge(osg)
		if Duel.SendtoGrave(msg,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end